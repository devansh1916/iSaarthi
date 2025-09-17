import pandas as pd
import joblib
from sklearn.model_selection import train_test_split
from sklearn.feature_extraction.text import TfidfVectorizer
from sklearn.linear_model import LogisticRegression
from sklearn.metrics import accuracy_score, classification_report
import os

def create_and_train_model():
    """
    This function handles the entire model training pipeline:
    1. Creates a sample dataset if one doesn't exist.
    2. Loads the data.
    3. Preprocesses the text data.
    4. Splits data into training and testing sets.
    5. Trains a logistic regression model.
    6. Evaluates the model's performance.
    7. Saves the trained model and the vectorizer to disk.
    """
    
    # --- 1. Create a sample dataset ---
    dataset_path = 'civic_issues_dataset.csv'
    if not os.path.exists(dataset_path):
        print(f"Dataset not found. Creating a sample dataset at '{dataset_path}'...")
        data = {
            'description': [
                'Major water pipe burst on main street, flooding the area.', 'Exposed electrical wires sparking from the pole.', 'A large tree has fallen and is completely blocking the road.', 'Sewage is overflowing from a manhole cover.', 'Emergency fire hydrant is broken and leaking heavily.',
                'There is a huge pothole in the middle of the road causing traffic.', 'Streetlight on corner has been out for a week.', 'Drainage is clogged, causing minor waterlogging after rain.', 'The traffic signal at the junction is not working properly.', 'Broken pavement on the sidewalk is a tripping hazard.',
                'The park bench is broken.', 'Garbage bin is full and needs to be emptied.', 'Faded road markings need repainting.', 'Missed garbage collection on my street.', 'Graffiti on public wall.'
            ],
            'priority': [
                'High', 'High', 'High', 'High', 'High',
                'Medium', 'Medium', 'Medium', 'Medium', 'Medium',
                'Low', 'Low', 'Low', 'Low', 'Low'
            ]
        }
        df = pd.DataFrame(data)
        df.to_csv(dataset_path, index=False)
        print("Sample dataset created successfully.")
    else:
        print(f"Using existing dataset from '{dataset_path}'.")

    # --- 2. Load the data ---
    df = pd.read_csv(dataset_path)
    print("\nDataset Head:")
    print(df.head())
    
    # Define features (X) and target (y)
    X = df['description']
    y = df['priority']

    # --- 3. Preprocess the text data ---
    # TfidfVectorizer converts text into a matrix of TF-IDF features.
    # This helps the model understand which words are important.
    tfidf_vectorizer = TfidfVectorizer(stop_words='english', max_features=1000)
    X_tfidf = tfidf_vectorizer.fit_transform(X)
    
    # --- 4. Split data into training and testing sets ---
    # 80% for training, 20% for testing
    X_train, X_test, y_train, y_test = train_test_split(X_tfidf, y, test_size=0.2, random_state=42, stratify=y)
    
    # --- 5. Train a logistic regression model ---
    print("\nTraining the model...")
    model = LogisticRegression(random_state=42)
    model.fit(X_train, y_train)
    print("Model training complete.")
    
    # --- 6. Evaluate the model's performance ---
    print("\nEvaluating model performance...")
    y_pred = model.predict(X_test)
    
    accuracy = accuracy_score(y_test, y_pred)
    print(f"Model Accuracy: {accuracy:.2f}")
    
    print("\nClassification Report:")
    print(classification_report(y_test, y_pred, zero_division=0))

    # --- 7. Save the trained model and the vectorizer ---
    model_filename = 'priority_classifier.pkl'
    vectorizer_filename = 'tfidf_vectorizer.pkl'
    
    joblib.dump(model, model_filename)
    joblib.dump(tfidf_vectorizer, vectorizer_filename)
    
    print(f"\nModel saved to '{model_filename}'")
    print(f"Vectorizer saved to '{vectorizer_filename}'")
    print("\nTraining process finished. You can now move these .pkl files to your ml_server directory.")

if __name__ == '__main__':
    create_and_train_model()
