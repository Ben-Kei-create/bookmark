# iOS Bookmark App - Local Setup Instructions

This document provides step-by-step instructions to set up the Bookmark app on macOS for development and testing.

## Overview

All source code is in place and properly organized. You need to create an Xcode project to build and run the app.

## Prerequisites

- macOS 12.0 or later
- Xcode 15.0 or later (install from App Store or download from Apple)

## Setup Steps

### 1. Navigate to Project Directory

```bash
cd /Users/[your-username]/bookmark  # or wherever you cloned the repo
git checkout claude/mobile-bookmark-feature-D49Q5
```

### 2. Create New Xcode Project

1. Open Xcode
2. Select **File → New → Project**
3. Choose **iOS → App**
4. Click **Next**
5. Fill in the form:
   - **Product Name**: `Bookmark`
   - **Team**: Your Apple Developer Team (or None for local testing)
   - **Organization Identifier**: `com.example` (use your domain or `com.local`)
   - **Bundle Identifier**: `com.example.bookmark`
   - **Interface**: SwiftUI
   - **Life Cycle**: SwiftUI App
   - **Language**: Swift
   - **Storage**: None (we'll use Core Data)
6. Click **Next**
7. **Choose location**: Select the `/Bookmark/` directory
8. **Create Git repository**: Uncheck (repo already exists)
9. Click **Create**

### 3. Remove Auto-Generated Files

After Xcode creates the project:
1. Delete `Bookmark/Views/ContentView.swift` (auto-generated)
2. Delete `Bookmark/Models/` if created (we have our own)
3. Delete `Bookmark/Preview Content/` (optional, can keep)

### 4. Add Source Files to Project

1. Right-click on the **Bookmark** group in Xcode's Project Navigator
2. Select **Add Files to "Bookmark"**
3. Navigate to `/Bookmark/Bookmark/` directory
4. Select all folders:
   - `App/`
   - `Models/`
   - `ViewModels/`
   - `Views/`
   - `Services/`
   - `Utilities/`
   - `Data/`
5. **Important Options**:
   - ✓ Copy items if needed (UNCHECK - we want references)
   - ✓ Create groups (CHECK)
   - ✓ Add to targets: Bookmark (CHECK)
6. Click **Add**

### 5. Add Core Data Model

1. In Xcode, select **File → New → Data Model**
2. Name it **Bookmark**
3. Open the new `Bookmark.xcdatamodeld` file
4. Delete the auto-generated `Bookmark` entity (if any)
5. Right-click in the data model editor
6. Select **Add Entity**
7. Name it **BookmarkEntity**
8. Add the following attributes:
   ```
   - id: UUID (Optional)
   - url: String (Required)
   - title: String (Required)
   - descriptionText: String (Optional)
   - dateCreated: Date (Required)
   - lastModified: Date (Required)
   - isArchived: Boolean (Optional, default: false)
   ```

**Alternative (Easier):** Copy the existing data model:
1. In Finder, copy `/Bookmark/Bookmark/Data/Bookmark.xcdatamodeld` folder
2. In Xcode, select **File → Add Files to "Bookmark"**
3. Paste the copied folder and add to Bookmark target
4. Delete the empty `Bookmark.xcdatamodeld` created in step 5

### 6. Configure Build Settings

1. Select the **Bookmark** project in Project Navigator
2. Select the **Bookmark** target
3. Go to **Build Settings** tab
4. Search for "iOS Deployment Target"
5. Set to **iOS 15.0** (or later)
6. Search for "Bundle Identifier"
7. Verify it's set to `com.example.bookmark`

### 7. Verify Settings

1. Go to **Info** tab
2. Add any missing keys from `/Bookmark/Bookmark/Info.plist`:
   - Bundle Display Name: "Bookmark"
   - Minimum iOS Version: 15.0

### 8. Build and Run

1. Select a simulator from the top toolbar (e.g., iPhone 15 Pro)
2. Press **Cmd + R** to build and run
3. If building fails, check **Build Issues** navigator (Cmd + 5)

## Troubleshooting

### "No such module" errors
- Clean build folder: **Cmd + Shift + K**
- Delete derived data: `rm -rf ~/Library/Developer/Xcode/DerivedData/*`
- Rebuild: **Cmd + B**

### Core Data errors
- Verify the `BookmarkEntity` is created in the data model
- Check that file references are correct in Build Phases
- Ensure `Bookmark.xcdatamodeld` is in the project's targets

### Missing files errors
- Go to **Project Settings → Build Phases → Copy Bundle Resources**
- Verify all source files and data model are listed
- If missing, drag files from Navigator to this list

### Git conflicts
- After creating the project, add `.gitignore` entries:
  ```
  *.pbxproj
  xcuserdata/
  ```

## Next Steps

After successful build and run:
1. Test the app on simulator
2. Try adding, editing, and deleting bookmarks
3. Test search and sort functionality
4. Push changes to git if needed:
   ```bash
   git add .
   git commit -m "feat: Create Xcode project structure"
   git push origin claude/mobile-bookmark-feature-D49Q5
   ```

## Notes

- The source files are organized in the git repository but not tracked as part of the .xcodeproj file (by design)
- You may need to recreate the project structure if you switch branches or pull updates
- For App Store submission, update the bundle identifier to your actual app identifier
- Remember to add your Apple Developer Team in project settings

## File Structure Reference

```
Bookmark/
├── Bookmark/
│   ├── App/
│   │   └── BookmarkApp.swift
│   ├── Models/
│   │   └── Bookmark.swift
│   ├── ViewModels/
│   │   ├── BookmarkListViewModel.swift
│   │   ├── BookmarkFormViewModel.swift
│   │   └── BookmarkDetailViewModel.swift
│   ├── Views/
│   │   ├── Main/
│   │   │   ├── ContentView.swift
│   │   │   ├── BookmarkListView.swift
│   │   │   └── SettingsView.swift
│   │   ├── Bookmarks/
│   │   │   ├── BookmarkDetailView.swift
│   │   │   └── BookmarkFormView.swift
│   │   └── Components/
│   │       ├── BookmarkRow.swift
│   │       └── EmptyStateView.swift
│   ├── Services/
│   │   ├── BookmarkService.swift
│   │   ├── CoreDataManager.swift
│   │   └── URLValidator.swift
│   ├── Utilities/
│   │   ├── Extensions/
│   │   │   └── String+Formatting.swift
│   │   └── Constants.swift
│   ├── Data/
│   │   └── Bookmark.xcdatamodeld
│   └── Info.plist
├── BookmarkTests/
│   └── BookmarkTests.swift
└── README.md
```

Good luck with your Bookmark app! 🚀
