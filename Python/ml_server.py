from flask import Flask, request, jsonify
import joblib # A common library for saving/loading trained ML models

# Initialize the Flask application
app = Flask(__name__)

# --- MODEL LOADING (REAL) ---
# These lines load your actual trained model and vectorizer from the .pkl files.
# Make sure these files are in the same directory as this script.
try:
    model = joblib.load('priority_classifier.pkl')
    tfidf_vectorizer = joblib.load('tfidf_vectorizer.pkl')
    print("Model and vectorizer loaded successfully.")
except FileNotFoundError:
    print("Error: Model or vectorizer files not found.")
    print("Please run train_model.py first to generate the .pkl files.")
    model = None
    tfidf_vectorizer = None
# -----------------------------------------

@app.route('/predict', methods=['POST'])
def predict():
    """
    Receives an issue description and returns a predicted priority level using the trained model.
    """
    if not model or not tfidf_vectorizer:
        return jsonify({'error': 'Model not loaded. Please check server logs.'}), 500

    # Get the JSON data sent from the Node.js server
    data = request.get_json()
    issue_description = data.get('description', '')

    if not issue_description:
        return jsonify({'error': 'Issue description is required.'}), 400

    # --- ACTUAL PREDICTION LOGIC ---
    # 1. Process the incoming text using the loaded TF-IDF vectorizer.
    processed_text = tfidf_vectorizer.transform([issue_description])
    
    # 2. Predict the priority using the loaded classification model.
    prediction = model.predict(processed_text)
    
    # 3. Get the first (and only) prediction from the array.
    priority = prediction[0]
    # -------------------------------

    print(f"Received description: '{issue_description}'. Predicted priority: {priority}")

    # Return the prediction in a JSON format
    return jsonify({'priority': priority})

if __name__ == '__main__':
    # Run the server on port 5000
    print("Starting Python ML server on http://localhost:5000")
    app.run(port=5000, debug=True)