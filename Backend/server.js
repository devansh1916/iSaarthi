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

app.post('/api/issues/describe-image', async (req, res) => {
    const { imageBase64 } = req.body;
    const apiKey = process.env.GEMINI_API_KEY; 
    
    if (!apiKey) {
        return res.status(500).json({ error: 'Gemini API key is not configured on the server.' });
    }
    if (!imageBase64) {
        return res.status(400).json({ error: 'No image data provided.' });
    }

    const url = `https://generativelanguage.googleapis.com/v1beta/models/gemini-pro-vision:generateContent?key=${apiKey}`;

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


app.get('/api/issues', async (req, res) => {
    try {
        const snapshot = await db.collection('issues').orderBy('timestamp', 'desc').get();
        if (snapshot.empty) {
            return res.status(200).json([]);
        }
        const issues = snapshot.docs.map(firestoreToJson);
        res.status(200).json(issues);
    } catch (error) {
        console.error("Error fetching issues:", error);
        res.status(500).json({ error: 'Failed to fetch issues.' });
    }
});

app.post('/api/issues', async (req, res) => {
    try {
        const newIssue = req.body;
        if (!newIssue.description) {
            return res.status(400).json({ error: 'Issue description is required.' });
        }

        
        const mlResponse = await axios.post('http://127.0.0.1:5000/predict', { description: newIssue.description });
        const { priority, confidence } = mlResponse.data;
        
    
        const CONFIDENCE_THRESHOLD = 75;

        
        newIssue.priority = priority || 'Medium';
        newIssue.status = 'Pending';
        newIssue.timestamp = new Date();
        newIssue.modelConfidence = confidence;

        if (confidence < CONFIDENCE_THRESHOLD) {
            console.log(`Low confidence (${confidence}%) for issue. Flagging for review.`);
            newIssue.flagged = true;
            newIssue.flagReason = `Low model confidence (${confidence}%)`;
        } else {
            console.log(`High confidence (${confidence}%) for issue. Processing normally.`);
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

app.put('/api/issues/:issueId', async (req, res) => {
    try {
        const { issueId } = req.params;
        const updateData = req.body;

        if (updateData.priority || updateData.status) {
            updateData.flagged = false;
            updateData.flagReason = null;
        }

        const docRef = db.collection('issues').doc(issueId);
        await docRef.update(updateData);
        const updatedDoc = await docRef.get();

        res.status(200).json(firestoreToJson(updatedDoc));
    } catch (error) {
        console.error(`Error updating issue ${req.params.issueId}:`, error);
        res.status(500).json({ error: 'Failed to update issue.' });
    }
});

app.listen(PORT, '0.0.0.0', () => {
    console.log(`Server is running on http://0.0.0.0:${PORT}`);
});
