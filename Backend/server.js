const express = require('express');
const admin = require('firebase-admin');
const cors = require('cors');
const axios = require('axios');

// --- Firebase Setup ---
const serviceAccount = require('./serviceAccountKey.json'); 
admin.initializeApp({
  credential: admin.credential.cert(serviceAccount)
});
const db = admin.firestore();
// ----------------------

const app = express();
app.use(cors());
app.use(express.json());

const PORT = 3001;

/**
 * Helper function to safely convert Firestore data to JSON,
 * ensuring timestamps are in a standard ISO string format.
 */
const firestoreToJson = (doc) => {
    const data = doc.data();
    const json_data = { id: doc.id };
    for (const key in data) {
        if (data.hasOwnProperty(key)) {
            const value = data[key];
            // Convert Firestore Timestamps to ISO strings
            if (value && typeof value.toDate === 'function') {
                json_data[key] = value.toDate().toISOString();
            } else {
                json_data[key] = value;
            }
        }
    }
    return json_data;
};


/**
 * @api {get} /api/issues Get all issues
 * @description Retrieves a list of all civic issues from Firestore, sorted by timestamp (newest first).
 */
app.get('/api/issues', async (req, res) => {
    try {
        const snapshot = await db.collection('issues').orderBy('timestamp', 'desc').get();
        
        if (snapshot.empty) {
            return res.status(200).json([]);
        }
        
        // Use the new helper to ensure correct date formatting
        const issues = snapshot.docs.map(firestoreToJson);
        res.status(200).json(issues);
    } catch (error) {
        console.error("Error fetching issues:", error);
        res.status(500).json({ error: 'Failed to fetch issues.' });
    }
});


/**
 * @api {post} /api/issues Create a new issue
 * @description Creates a new issue, gets its priority from the ML model, and saves it to Firestore.
 */
app.post('/api/issues', async (req, res) => {
    const newIssue = req.body;

    if (!newIssue.issue || !newIssue.department || !newIssue.location || !newIssue.description || !newIssue.reportedBy) {
         return res.status(400).json({ error: 'Missing required issue fields.' });
    }
    
    try {
        console.log(`Sending description to ML server: "${newIssue.description}"`);
        const mlResponse = await axios.post('http://localhost:5000/predict', {
            description: newIssue.description
        });
        
        newIssue.priority = mlResponse.data.priority || 'Medium'; 
        newIssue.status = 'Pending';
        
        // Use a single, precise timestamp from the server.
        newIssue.timestamp = new Date(); 
        // The simple 'date' field is no longer needed as timestamp is more accurate.
        delete newIssue.date;

        const docRef = await db.collection('issues').add(newIssue);
        console.log(`New issue created with ID: ${docRef.id} and predicted priority: ${newIssue.priority}`);
        
        const savedIssueDoc = await docRef.get();
        // Use the new helper to ensure correct date formatting in the response
        res.status(201).json(firestoreToJson(savedIssueDoc));

    } catch (error) {
        console.error("Error creating new issue or calling ML model:", error);
        res.status(500).json({ error: 'Failed to create issue or connect to ML model.' });
    }
});


/**
 * @api {put} /api/issues/:issueId Update an issue's status
 * @description Updates the status of a specific issue in Firestore.
 */
app.put('/api/issues/:issueId', async (req, res) => {
    const { issueId } = req.params;
    const { status } = req.body;

    if (!status) {
        return res.status(400).json({ error: 'Status is required for an update.' });
    }

    try {
        const issueRef = db.collection('issues').doc(issueId);
        await issueRef.update({ status: status });
        console.log(`Issue ${issueId} status updated to: ${status}`);
        res.status(200).json({ id: issueId, message: 'Status updated successfully.' });
    } catch (error) {
        console.error(`Error updating issue ${issueId}:`, error);
        res.status(500).json({ error: 'Failed to update issue.' });
    }
});


app.listen(PORT, () => {
  console.log(`Civic Watch backend server is running on http://localhost:${PORT}`);
});