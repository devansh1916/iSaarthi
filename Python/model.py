import pandas as pd
import joblib
from sklearn.model_selection import train_test_split, GridSearchCV
from sklearn.feature_extraction.text import TfidfVectorizer
from sklearn.linear_model import LogisticRegression
from sklearn.metrics import accuracy_score, classification_report
import os

def create_and_train_model():
    """
    Handles the entire model training pipeline, now with a more robust dataset
    and hyperparameter tuning for better accuracy.
    """
    
    dataset_path = 'civic_issues_dataset.csv'
    if not os.path.exists(dataset_path):
        raise FileNotFoundError(f"Dataset file not found at {dataset_path}. Please create it first.")

    # --- 1. Load the data ---
    df = pd.read_csv(dataset_path)
    df.dropna(subset=['description', 'priority'], inplace=True) # Ensure no missing values
    
    # Define features (X) and target (y)
    X = df['description']
    y = df['priority']

    # --- 2. Preprocess the text data ---
    # Using more features to capture more information from the expanded dataset
    tfidf_vectorizer = TfidfVectorizer(stop_words='english', max_features=2000, ngram_range=(1, 2))
    X_tfidf = tfidf_vectorizer.fit_transform(X)
    
    # --- 3. Split data ---
    # Stratify ensures that the distribution of priorities is the same in train and test sets
    X_train, X_test, y_train, y_test = train_test_split(X_tfidf, y, test_size=0.25, random_state=42, stratify=y)
    
    # --- 4. Hyperparameter Tuning with GridSearchCV ---
    print("\nFinding the best model parameters with GridSearchCV...")
    # Define the parameter grid to search
    param_grid = {
        'C': [0.1, 1, 10, 100],
        'solver': ['liblinear', 'saga'],
        'penalty': ['l1', 'l2']
    }
    
    # Initialize the model
    model = LogisticRegression(random_state=42, max_iter=1000)
    
    # Set up GridSearchCV
    grid_search = GridSearchCV(estimator=model, param_grid=param_grid, cv=5, n_jobs=-1, verbose=1)
    
    # Fit GridSearchCV to find the best parameters
    grid_search.fit(X_train, y_train)
    
    print(f"Best parameters found: {grid_search.best_params_}")
    
    # Use the best estimator found by GridSearchCV
    best_model = grid_search.best_estimator_
    
    # --- 5. Evaluate ---
    print("\nEvaluating model performance on the test set...")
    y_pred = best_model.predict(X_test)
    accuracy = accuracy_score(y_test, y_pred)
    print(f"\nModel Accuracy: {accuracy:.4f}")
    print("\nClassification Report:")
    print(classification_report(y_test, y_pred))
    
    # --- 6. Save the final model and vectorizer ---
    print("\nSaving the trained model and TF-IDF vectorizer...")
    joblib.dump(best_model, 'priority_classifier.pkl')
    joblib.dump(tfidf_vectorizer, 'tfidf_vectorizer.pkl')
    print("Model and vectorizer saved successfully as 'priority_classifier.pkl' and 'tfidf_vectorizer.pkl'.")


if __name__ == '__main__':
    create_and_train_model()
