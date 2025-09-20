require('dotenv').config();
const express = require('express');
const admin = require('firebase-admin');
const cors = require('cors');
const axios = require('axios');

const serviceAccount = require('./serviceAccountKey.json');
admin.initializeApp({
  credential: admin.credential.cert(serviceAccount)
});
const db = admin.firestore();


const app = express();
app.use(cors());
app.use(express.json({ limit: '10mb' }));

const PORT = 3001;

// Helper function to correctly format Firestore data to JSON
const firestoreToJson = (doc) => {
    const data = doc.data();
    const json_data = { id: doc.id };
    for (const key in data) {
        if (data.hasOwnProperty(key)) {
            const value = data[key];
            if (value && typeof value.toDate === 'function') {
                json_data[key] = value.toDate().toISOString();
            } else {
                json_data[key] = value;
            }
        }
    }
    return json_data;
};

// --- IMAGE ANALYSIS ENDPOINT (No Changes) ---
app.post('/api/issues/describe-image', async (req, res) => {
    const { imageBase64 } = req.body;
    const apiKey = process.env.GEMINI_API_KEY;
    
    if (!apiKey) return res.status(500).json({ error: 'Gemini API key is not configured.' });
    if (!imageBase64) return res.status(400).json({ error: 'No image data provided.' });

    const url = `https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash-preview-05-20:generateContent?key=${apiKey}`;
    const payload = {
        contents: [{
            parts: [
                { text: "Analyze this image of a civic issue in an urban Indian context. Based on the image, provide a brief, factual title for the issue, a detailed one-paragraph description, and suggest the most relevant municipal department from this list: ['Public Works', 'Utilities', 'Sanitation', 'Parks & Recreation', 'Emergency Services', 'Road', 'Water Works']. Return ONLY a valid JSON object with the keys 'title', 'description', and 'department'." },
                { inline_data: { mime_type: "image/jpeg", data: imageBase64 } }
            ]
        }]
    };

    try {
        const response = await axios.post(url, payload);
        let textResponse = response.data.candidates[0].content.parts[0].text;
        textResponse = textResponse.replace(/```json/g, '').replace(/```/g, '').trim();
        const jsonData = JSON.parse(textResponse);
        res.status(200).json(jsonData);
    } catch (error) {
        console.error("Error calling Gemini API:", error.response ? error.response.data : error.message);
        res.status(500).json({ error: 'Failed to analyze image with AI.' });
    }
});


// --- DATA FETCHING ENDPOINTS (No Changes) ---
app.get('/api/issues', async (req, res) => {
    try {
        const snapshot = await db.collection('issues')
            .where('flagged', '==', false)
            .orderBy('timestamp', 'desc')
            .get();
        const issues = snapshot.docs.map(firestoreToJson);
        res.status(200).json(issues);
    } catch (error) {
        console.error("Error fetching issues:", error);
        res.status(500).json({ error: 'Failed to fetch issues.' });
    }
});

app.get('/api/issues/flagged', async (req, res) => {
    try {
        const snapshot = await db.collection('issues')
            .where('flagged', '==', true)
            .orderBy('timestamp', 'desc')
            .get();
        const issues = snapshot.docs.map(firestoreToJson);
        res.status(200).json(issues);
    } catch (error) {
        console.error("Error fetching flagged issues:", error);
        res.status(500).json({ error: 'Failed to fetch flagged issues.' });
    }
});


// --- DATA MODIFICATION ENDPOINTS ---

// UPDATED: New issues now start with a rejectionCount of 0.
app.post('/api/issues', async (req, res) => {
    try {
        const newIssue = req.body;
        if (!newIssue.description || !newIssue.location) {
            return res.status(400).json({ error: 'Description and location are required.' });
        }

        if (typeof newIssue.location === 'string' && newIssue.location.includes(',')) {
            const openCageApiKey = process.env.OPENCAGE_API_KEY;
            if (openCageApiKey) {
                const [lat, lng] = newIssue.location.split(',');
                const url = `https://api.opencagedata.com/geocode/v1/json?q=${lat}+${lng}&key=${openCageApiKey}`;
                try {
                    const geocodeResponse = await axios.get(url);
                    if (geocodeResponse.data.results && geocodeResponse.data.results.length > 0) {
                        newIssue.readableLocation = geocodeResponse.data.results[0].formatted;
                    } else {
                        newIssue.readableLocation = newIssue.location;
                    }
                } catch (geocodeError) {
                    console.error("Error calling OpenCage API:", geocodeError.message);
                    newIssue.readableLocation = newIssue.location;
                }
            }
        } else {
            newIssue.readableLocation = newIssue.location;
        }
        
        const mlResponse = await axios.post('http://127.0.0.1:5000/predict', { description: newIssue.description });
        const { priority, confidence } = mlResponse.data;
        
        const CONFIDENCE_THRESHOLD = 75;

        // Set initial properties
        newIssue.priority = priority || 'Medium';
        newIssue.status = 'Pending';
        newIssue.timestamp = new Date();
        newIssue.modelConfidence = confidence;
        newIssue.rejectionCount = 0; // NEW: Initialize rejection count

        // Automatically flag if confidence is low
        if (confidence < CONFIDENCE_THRESHOLD) {
            newIssue.flagged = true;
            newIssue.flagReason = `Low model confidence (${confidence}%)`;
        } else {
            newIssue.flagged = false;
        }
        
        const docRef = await db.collection('issues').add(newIssue);
        const savedDoc = await docRef.get();
        res.status(201).json(firestoreToJson(savedDoc));

    } catch (error) {
        console.error("Error creating new issue:", error.message);
        if (error.code === 'ECONNREFUSED') {
            return res.status(500).json({ error: 'Could not connect to the ML prediction service.' });
        }
        res.status(500).json({ error: 'Failed to create issue.' });
    }
});

// BULK UPDATE (No Changes)
app.post('/api/issues/bulk-update', async (req, res) => {
    const { ids, payload } = req.body;

    if (!Array.isArray(ids) || ids.length === 0 || !payload) {
        return res.status(400).json({ error: 'Invalid request: "ids" array and "payload" object are required.' });
    }

    try {
        const batch = db.batch();
        ids.forEach(id => {
            const docRef = db.collection('issues').doc(id);
            batch.update(docRef, payload);
        });
        await batch.commit();
        res.status(200).json({ message: `${ids.length} issues updated successfully.` });
    } catch (error) {
        console.error("Error during bulk update:", error);
        res.status(500).json({ error: 'Failed to perform bulk update.' });
    }
});

// UPDATED: This endpoint now intelligently handles the rejection count.
app.put('/api/issues/:issueId', async (req, res) => {
    try {
        const { issueId } = req.params;
        const updateData = req.body;

        const docRef = db.collection('issues').doc(issueId);
        const doc = await docRef.get();
        if (!doc.exists) {
            return res.status(404).json({ error: 'Issue not found.' });
        }
        const currentData = doc.data();

        // When an admin manually updates a flagged issue, it's considered reviewed.
        updateData.flagged = false;
        updateData.flagReason = null;

        // NEW LOGIC: If the issue was flagged because it was rejected, increment the rejection count.
        if (currentData.flagReason && currentData.flagReason.toLowerCase().includes('rejected')) {
            updateData.rejectionCount = admin.firestore.FieldValue.increment(1);
        }

        await docRef.update(updateData);
        res.status(200).json({ message: 'Issue updated successfully' });
    } catch (error) {
        console.error(`Error updating issue ${req.params.issueId}:`, error);
        res.status(500).json({ error: 'Failed to update issue.' });
    }
});


app.listen(PORT, '0.0.0.0', () => {
    console.log(`Server is running on http://0.0.0.0:${PORT}`);
});