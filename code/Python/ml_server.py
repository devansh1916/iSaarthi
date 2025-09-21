from flask import Flask, request, jsonify
import joblib
import numpy as np


app = Flask(__name__)


print("Loading priority prediction model and vectorizer...")
try:
    model = joblib.load('priority_classifier.pkl')
    tfidf_vectorizer = joblib.load('tfidf_vectorizer.pkl')
    print("ML model and vectorizer loaded successfully.")
except FileNotFoundError:
    print("Error: Model or vectorizer files not found.")
    model = None
    tfidf_vectorizer = None



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


if __name__ == '__main__':
    print("Starting Flask server on http://localhost:5000")
    app.run(host='0.0.0.0', port=5000)
