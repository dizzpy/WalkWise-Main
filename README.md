
# Walkwise - Simple Guide

### **How to Run the App**

1. **Clone the repo:**
   ```bash
   https://github.com/dizzpy/WalkWise-Main.git
   ```

2. **Get the environment file:**
   Make sure you have the `.env` file in the project.

3. **Install dependencies:**
   ```bash
   cd walkwise
   flutter pub get
   ```

4. **Run the app:**
   ```bash
   flutter run
   ```

---

### **Folder Structure**

Here’s how things are organized:

```
lib/
 ┣ auth/         # Auth stuff
 ┣ components/   # Buttons, text fields, etc.
 ┣ const/         # Colors and other constants
 ┣ pages/         # App screens
 ┣ providers/     # State management (like user info)
 ┣ services/      # Firebase and other services
 ┣ theme/         # App-wide theme
 ┣ utils/         # Utility functions
 ┣ firebase_options.dart  # Firebase setup
 ┣ main.dart      # App entry point
test/
 ┣ widget_test.dart   # Tests for widgets
.env               # Environment variables
firebase.json      # Firebase setup
.gitignore         # Git ignore settings
README.md          # This file
pubspec.yaml       # Dependencies
```

---

### **Contributing**

- Pull the latest changes before you start.
- Add your features or fix bugs!
- Remember to create a new branch if you're adding something big.
