from flask import Flask, request, jsonify
import joblib
import numpy as np

app = Flask(__name__)


try:
    model = joblib.load('priority_classifier.pkl')
    tfidf_vectorizer = joblib.load('tfidf_vectorizer.pkl')
    print("Model and vectorizer loaded successfully.")
except FileNotFoundError:
    print("Error: Model or vectorizer files not found. Run train_model.py first.")
    model = None
    tfidf_vectorizer = None


@app.route('/predict', methods=['POST'])
def predict():
    """
    Receives an issue description and returns a predicted priority and a confidence score.
    """
    if not model or not tfidf_vectorizer:
        return jsonify({'error': 'Model not loaded.'}), 500

    data = request.get_json()
    issue_description = data.get('description', '')

    if not issue_description:
        return jsonify({'error': 'Issue description is required.'}), 400


    processed_text = tfidf_vectorizer.transform([issue_description])
    

    prediction = model.predict(processed_text)[0]
    

    probabilities = model.predict_proba(processed_text)
    

    confidence = int(np.max(probabilities) * 100)


    print(f"Description: '{issue_description}' -> Priority: {prediction}, Confidence: {confidence}%")


    return jsonify({
        'priority': prediction,
        'confidence': confidence
    })

if __name__ == '__main__':
    print("Starting Python ML server on http://localhost:5000")
    app.run(port=5000)