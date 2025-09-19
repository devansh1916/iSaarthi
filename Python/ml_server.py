from flask import Flask, request, jsonify
import joblib
import numpy as np

app = Flask(__name__)

# --- MODEL LOADING ---
try:
    model = joblib.load('priority_classifier.pkl')
    tfidf_vectorizer = joblib.load('tfidf_vectorizer.pkl')
    print("Model and vectorizer loaded successfully.")
except FileNotFoundError:
    print("Error: Model or vectorizer files not found. Run train_model.py first.")
    model = None
    tfidf_vectorizer = None
# ---------------------

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

    # --- PREDICTION LOGIC WITH CONFIDENCE ---
    # 1. Process the text
    processed_text = tfidf_vectorizer.transform([issue_description])
    
    # 2. Predict the priority
    prediction = model.predict(processed_text)[0]
    
    # 3. Get prediction probabilities to calculate confidence
    probabilities = model.predict_proba(processed_text)
    
    # 4. The confidence is the highest probability score, rounded
    confidence = int(np.max(probabilities) * 100)
    # ------------------------------------------

    print(f"Description: '{issue_description}' -> Priority: {prediction}, Confidence: {confidence}%")

    # Return both priority and confidence
    return jsonify({
        'priority': prediction,
        'confidence': confidence
    })

if __name__ == '__main__':
    print("Starting Python ML server on http://localhost:5000")
    app.run(port=5000)