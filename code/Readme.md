## ✅ Tasks Accomplished

- [x] **Task 1:** Implemented a cross-platform mobile app using Flutter for citizen issue reporting.
- [x] **Task 2:** Developed a dynamic web dashboard with React for officials to manage and track issues.
- [x] **Task 3:** Built and deployed a Python backend to serve an ML model for issue prioritization.
- [x] **Task 4:** Set up a Node.js backend to handle core API logic and data management.

---

## 💻 Technology Stack

This project leverages the following technologies:

* **Flutter:** Chosen for its cross-platform capabilities, enabling a single codebase for both Android and iOS.
* **Dart:** The modern, client-optimized programming language used to build the Flutter application.
* **React:** Used for its component-based architecture to build a dynamic and interactive admin dashboard.
* **Tailwind CSS:** A utility-first CSS framework used to rapidly design and style the React web portal.
* **Node.js:** Selected for its efficient, non-blocking I/O to handle the main API logic and data management.
* **Python:** The standard for AI/ML integration, chosen to serve machine learning models and interact with external APIs.
* **Firebase:** A comprehensive backend-as-a-service (BaaS) platform used for user authentication and core services.
* **Cloud Firestore:** A flexible, scalable NoSQL cloud database used to store and sync app data in real-time.
* **Gemini API:** Leveraged for its generative AI capabilities to pre-fill issue reports from user-uploaded images.
* **MapTiler:** Provides reliable and customizable maps for displaying issue locations within the app.
* **OpenCage:** An API for forward and reverse geocoding to convert coordinates to addresses and vice-versa.
* **OpenWeather:** Used to fetch and display relevant weather data for a reported issue's location.
* **Render:** A cloud platform used for deploying the Python backend service, offering auto-deploys from Git.

---

## ✨ Key Features

* **Mobile First Reporting**: Allows citizens to easily submit civic issues with images directly from their phones.
* **AI-Assisted Forms**: Uses image analysis to automatically suggest a title and description for new reports.
* **ML-Powered Prioritization**: Predicts the urgency of an issue to help officials focus on critical problems first.
* **Semantic Search Chatbot**: Helps users find existing reports on similar issues to avoid duplicate submissions.
* **Admin Dashboard**: Provides officials a web-based interface to track, manage, and update issue statuses.

---

## 🚀 Local Setup Instructions

Follow these steps to run the project locally. These instructions are compatible with both macOS and Windows.

**1. Clone the Repository**
Open your terminal and run the following command. This will be the main folder for all subsequent steps.
```sh
git clone [https://github.com/your_username/your_repo_name.git](https://github.com/your_username/your_repo_name.git)
```

### File 3: `Step_2_Python.md`

**2. Setup the Python ML/Chatbot Server**
Navigate into the correct directory.
  ```sh
  cd your_repo_name/code/Python
```

Create and activate a virtual environment (replace python with python3 if needed):
```sh
# For macOS/Linux:
python -m venv venv && source venv/bin/activate
# For Windows:
python -m venv venv && .\\venv\\Scripts\\activate
```

Install dependencies and run the server:
```sh
pip install -r requirements.txt
python model.py  # Run this only the first time
python app.py
```
### File 4: `Step_3_NodeJS.md`

**4. Setup the React Web Portal**
* In a **new terminal**, navigate into the correct directory:
    ```sh
  cd your_repo_name/code/react
    ```
  Install dependencies and run the server:
  ```sh
  npm install
  npm start
  ```
### File 6: `Step_5_Flutter.md`
**5. Setup the Flutter Mobile App**
* In a **new terminal**, navigate into the correct directory:
  ```sh
  cd your_repo_name/code/flutter_map_app
  ```
Install dependencies and run the app (make sure an emulator is running):
```sh
flutter pub get
flutter run
```

## 🚀 Deployed Links
**Note:** Make sure all these links are open on some device or another to make ensure they aren't asleep. This allows for proper flow of the app
* Web App: https://isaarthi.onrender.com
* Web Portal: https://isaarthi-gov-portal.onrender.com
* Node Backend Server: https://isaarthi-node-api.onrender.com
* Flask Server for Python Models: https://isaarth-python-model.onrender.com
