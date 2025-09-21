from flask import Flask, request, jsonify
import joblib
import numpy as np
import pandas as pd
from sentence_transformers import SentenceTransformer, util

app = Flask(__name__)

print("Loading priority prediction model and vectorizer...")
try:
    model = joblib.load('priority_classifier.pkl')
    tfidf_vectorizer = joblib.load('tfidf_vectorizer.pkl')
    print("ML model and vectorizer loaded successfully.")
except FileNotFoundError:
    print("Error: Model or vectorizer files not found. Run model.py first.")
    model = None
    tfidf_vectorizer = None


print("Loading chatbot sentence model...")

chatbot_model = SentenceTransformer("sentence-transformers/all-MiniLM-L6-v2")

print("Loading and embedding civic issues data...")

CSV_URL = "https://docs.google.com/spreadsheets/d/1W97h1PCryakGrIkIX-cDyij9_RUywGF1g31fwX9oD9Y/export?format=csv"
issues_df = pd.read_csv(CSV_URL)


issue_texts = issues_df.apply(
    lambda row: f"{row.get('Issue','')} at {row.get('Location','')}", axis=1
).tolist()
issue_embeddings = chatbot_model.encode(issue_texts, convert_to_tensor=True)
print("Civic issues data loaded and embedded.")




@app.route('/predict', methods=['POST'])
def predict():
    """Receives an issue description and returns a predicted priority."""
    if not model or not tfidf_vectorizer:
        return jsonify({'error': 'ML model is not loaded.'}), 500

    data = request.get_json()
    if not data or 'description' not in data:
        return jsonify({'error': 'Request must be JSON with a "description" key.'}), 400

    issue_description = data['description']
    processed_text = tfidf_vectorizer.transform([issue_description])
    
    prediction = model.predict(processed_text)[0]
    probabilities = model.predict_proba(processed_text)
    confidence = int(np.max(probabilities) * 100)

    print(f"Prediction for '{issue_description}' -> Priority: {prediction}")
    return jsonify({'priority': prediction, 'confidence': confidence})


@app.route('/chatbot', methods=['GET'])
def chatbot():
    """Receives a query and finds the most relevant civic issues."""

    query = request.args.get('query')

    if not query:
        return jsonify({'error': 'A "query" parameter is required.'}), 400
    

    query_embedding = chatbot_model.encode(query, convert_to_tensor=True)


    similarities = util.cos_sim(query_embedding, issue_embeddings)[0]
    top_indices = similarities.argsort(descending=True)[:3]


    replies = []
    for idx in top_indices:
        row = issues_df.iloc[int(idx)]
        replies.append(
            f"🔹 {row.get('Issue', 'N/A')} at {row.get('Location', 'N/A')}\n"
            f"   📌 Status: {row.get('Status', 'N/A')}\n"
            f"   🗓 Last updated: {row.get('LastUpdated', 'N/A')}\n"
            f"   💬 Remarks: {row.get('Remarks', 'N/A')}"
        )
    
    final_reply = "Here are the most relevant issues I found:\n\n" + "\n\n".join(replies)
    

    return jsonify({"reply": final_reply})


if __name__ == '__main__':
    print("Starting combined Flask server on http://localhost:5000")

    app.run(host='0.0.0.0', port=5000)
