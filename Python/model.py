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


    df = pd.read_csv(dataset_path)
    df.dropna(subset=['description', 'priority'], inplace=True)
    
    X = df['description']
    y = df['priority']


    tfidf_vectorizer = TfidfVectorizer(stop_words='english', max_features=2000, ngram_range=(1, 2))
    X_tfidf = tfidf_vectorizer.fit_transform(X)
    

    X_train, X_test, y_train, y_test = train_test_split(X_tfidf, y, test_size=0.25, random_state=42, stratify=y)
    

    print("\nFinding the best model parameters with GridSearchCV...")

    param_grid = {
        'C': [0.1, 1, 10, 100],
        'solver': ['liblinear', 'saga'],
        'penalty': ['l1', 'l2']
    }
    

    model = LogisticRegression(random_state=42, max_iter=1000)
    

    grid_search = GridSearchCV(estimator=model, param_grid=param_grid, cv=5, n_jobs=-1, verbose=1)
    

    grid_search.fit(X_train, y_train)
    
    print(f"Best parameters found: {grid_search.best_params_}")
    

    best_model = grid_search.best_estimator_
    

    print("\nEvaluating model performance on the test set...")
    y_pred = best_model.predict(X_test)
    accuracy = accuracy_score(y_test, y_pred)
    print(f"\nModel Accuracy: {accuracy:.4f}")
    print("\nClassification Report:")
    print(classification_report(y_test, y_pred))
    

    print("\nSaving the trained model and TF-IDF vectorizer...")
    joblib.dump(best_model, 'priority_classifier.pkl')
    joblib.dump(tfidf_vectorizer, 'tfidf_vectorizer.pkl')
    print("Model and vectorizer saved successfully as 'priority_classifier.pkl' and 'tfidf_vectorizer.pkl'.")


if __name__ == '__main__':
    create_and_train_model()
