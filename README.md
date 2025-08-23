# Clipo Mobile

Clipo is a feature-rich, cross-platform link management application built with Flutter. It allows you to save, organize, and quickly access your links from anywhere, with a focus on local-first data storage and a clean, intuitive user experience.

## 📱 Screenshots

<table>
  <tr>
    <td><img src="assets/screenshots/home_screen.png" width="200" alt="Home Screen"/></td>
    <td><img src="assets/screenshots/share_menu.png" width="200" alt="Share Menu"/></td>
    <td><img src="assets/screenshots/link_management.png" width="200" alt="Link Management"/></td>
  </tr>
  <tr>
    <td align="center"><b>Home Screen</b></td>
    <td align="center"><b>Share Menu</b></td>
    <td align="center"><b>New link</b></td>
  </tr>
</table>

## ✨ Key Features

-   **Save from Anywhere**: Natively receive and save links shared from other apps on your device via the share menu.
-   **Advanced Organization**: Categorize links, mark items as favorites for quick access, and archive old links.
-   **Powerful Search**: Find links with a comprehensive search that filters by keywords, categories, date ranges, and favorite/archived status.
-   **Intuitive UI**: A modern interface with smooth animations and convenient slidable list items for quick actions like editing, sharing, and deleting.
-   **Offline First**: All your data is stored locally on your device using a robust SQLite database, ensuring fast and reliable access.
-   **Dynamic Theming**: Category cards are dynamically styled with unique colors and icons for easy visual identification.

## Architecture & Tech Stack

-   **Framework**: Flutter
-   **Database**: `drift` (a reactive persistence library for Dart and Flutter built on top of SQLite) for local data persistence.
-   **Core Plugins**:
    -   `receive_sharing_intent`: To capture links shared from other applications.
    -   `url_launcher`: To open saved links in the browser.
    -   `share_plus`: To share links from within the app.
    -   `flutter_slidable`: For intuitive swipe actions on list items.
    -   `awesome_snackbar_content`: For clean, informative in-app notifications.

## Project Structure

The project follows a standard Flutter structure, with the core logic located in the `lib` directory:

```
lib/
├── database/     # Drift database setup, table definitions, and repositories
├── mixins/       # Reusable logic for link actions and pagination
├── models/       # Data models for Link and Category
├── ui/           # All UI components, organized by screens and widgets
├── utils/        # Utility functions for validation and category management
└── main.dart     # Application entry point and shared intent handling
```

## Getting Started

To run this project locally, follow these steps:

### Prerequisites

Ensure you have the Flutter SDK installed on your machine.

### Installation & Setup

1.  **Clone the repository:**
    ```sh
    git clone https://github.com/AhmedDevST/clipo_mobile.git
    ```

2.  **Navigate to the project directory:**
    ```sh
    cd clipo_mobile
    ```

3.  **Install dependencies:**
    ```sh
    flutter pub get
    ```

4.  **Generate Database Code:**
    The project uses `drift` for database management, which requires code generation. Run the following command to generate the necessary files:
    ```sh
    flutter pub run build_runner build --delete-conflicting-outputs
    ```

5.  **Run the app:**
    ```sh
    flutter run