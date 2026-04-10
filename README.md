# DevSync - AI-Powered Developer Matching Platform

DevSync is a modern Flutter application designed to connect Developers with Project Owners through intelligent AI-driven matching. The app features a premium Glassmorphism UI and is powered by Google Gemini AI for skill matching and project assistance.

## 🚀 Recent Architectural Overhaul (Refactor)

We have recently completed a major restructuring of the application to support a robust, role-based system.

### 1. Unified MainShell Navigation
The app now uses a central `MainShell` to handle navigation. This includes:
- **Dynamic Bottom Navigation**: The tabs automatically switch between **Developer** and **Owner** sets based on the logged-in user's role.
- **Improved Routing**: All authentication flows now converge into a single entry point (`/main-shell`), simplifying state management and navigation history.

### 2. Feature-Based Modules
The project architecture has been reorganized into feature-based modules. We have scaffolded the following views for both roles:
- **Developer Flow**: 
  - 🏠 **Dashboard**: AI-recommended projects and stats.
  - 📂 **Projects**: Browse all available projects.
  - 🤖 **Matches**: View AI-calculated match scores.
  - 👤 **Profile**: Manage developer skills and GitHub info.
- **Owner Flow**:
  - 🏠 **Dashboard**: Overview of posted projects.
  - ➕ **Create Project**: Post new opportunities.
  - 📊 **My Projects**: Manage your projects and see matched developers.
  - 👤 **Profile**: Company and personal information.

### 3. Global AI Assistant
A **Global Floating AI Button** (⭕) is now present on every screen.
- Tapping the button opens the **DevSync AI Assistant** (Chat interface).
- Powered by **Gemini AI**, this assistant helps users with project suggestions, profile improvements, and general matching questions.

### 4. AI Matching & UI System
- **Match Score Badge**: Updated to a 4-tier color system:
  - 🟢 **90-100**: Perfect Match
  - 🔵 **70-89**: Strong Match
  - 🟠 **50-69**: Medium Match
  - 🔴 **<50**: Weak Match
- **UI Language**: Consistent use of **Glassmorphism**, soft shadows, and a blue primary color palette.

---

## 🛠 Tech Stack
- **Framework**: [Flutter](https://flutter.dev)
- **State Management**: [GetX](https://pub.dev/packages/get)
- **Backend/Database**: [Firebase](https://firebase.google.com) (Auth, Firestore)
- **AI Integration**: [Google Gemini AI](https://deepmind.google/technologies/gemini/)
- **Animations**: [Flutter Animate](https://pub.dev/packages/flutter_animate)

## 📁 Project Structure
```text
lib/
├── app/          # Routes and Global Config
├── core/         # Theme, Constants, Patterns
├── data/         # Models, Providers, Services
├── presentation/ # Modules, Widgets, UI Components
│   ├── modules/  # Feature-based folders (Auth, MainShell, etc.)
│   └── widgets/  # Shared reusable UI elements
└── main.dart     # Entry point
```
