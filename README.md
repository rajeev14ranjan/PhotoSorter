# PhotoSorter

A beautiful native macOS application for efficiently sorting and selecting photos from large collections. Built with SwiftUI and SwiftData, PhotoSorter helps photographers and content creators quickly curate their best shots from hundreds or thousands of images.

## ✨ Features

### Project Management
- **Project-based Organization**: Create and manage multiple independent projects, each with its own photos and selection criteria
- **Multiple Source Folders**: Import photos from multiple directories into a single project for unified sorting
- **Security-Scoped Bookmarks**: Maintains secure access to source folders across app sessions
- **Persistent Storage**: All project data and categorizations stored locally using SwiftData

### Photo Categorization
Sort photos into four distinct categories:
- 💚 **Selected** (Key: `1`) - Your definite keepers
- 🔵 **Shortlisted** (Key: `2`) - Strong candidates for selection
- 🟠 **Unsure** (Key: `3`) - Photos you're undecided about
- 🔴 **Rejected** (Key: `4`) - Photos to exclude

### Viewing Experience
- **Full-Screen Immersive Display**: Distraction-free photo viewing with elegant overlay controls
- **Smart Image Loading**: Supports JPG, JPEG, PNG, and HEIC formats with multiple fallback loading methods
- **Chronological Sorting**: Photos automatically sorted by creation date
- **Real-time Statistics**: Live counters showing photos in each category
- **Progress Tracking**: See how many photos remain to reach your target selection

### Filtering & Navigation
- **Dynamic Filtering**: View photos by category or see all unrated photos
- **Keyboard Navigation**: Fast arrow key navigation between photos
- **Category Switching**: Quickly jump between filtered views
- **Photo Info Overlay**: Displays filename and position in current filter

### Export Capabilities
- **Selective Export**: Choose which categories to export
- **Organized Output**: Exports to a timestamped folder with proper naming
- **Duplicate Handling**: Automatically handles filename conflicts
- **Progress Tracking**: Real-time export progress with file counts
- **Finder Integration**: One-click to reveal exported photos in Finder

### Additional Features
- **Target Goals**: Set and track a target number of photos to select for each project
- **Bucket Reset**: Reset individual photos back to unrated status (Key: `0`)
- **Data Management**: Built-in reset all data option (⌘⇧⌥R) for fresh starts
- **Hidden Title Bar**: Clean, modern interface with windowless design
- **Context Menus**: Right-click project for quick deletion

## 🖥️ Requirements

- **macOS**: 14.0 (Sonoma) or later
- **Xcode**: 15.0 or later (for building from source)
- **Disk Space**: Minimal - only stores metadata, not actual photo files

## 📦 Installation

### Option 1: Pre-built DMG (Recommended)
1. Download `PhotoSorter.dmg` from the `Installer/` directory
2. Open the DMG file
3. Drag `PhotoSorter.app` to the Applications folder
4. **First launch**: Right-click the app → select "Open" → click "Open" in the security dialog
   - (Required because the app is not notarized by Apple)
5. Subsequent launches work normally from Applications or Spotlight

### Option 2: Build from Source
1. Clone the repository:
   ```bash
   git clone https://github.com/rajeev14ranjan/PhotoSorter.git
   cd PhotoSorter
   ```

2. Open `PhotoSorter.xcodeproj` in Xcode

3. Select your development team in the project settings (Signing & Capabilities)

4. Build and run (⌘R)

## 🚀 Usage Guide

### Getting Started
1. **Launch PhotoSorter** and click "New Project" at the bottom of the sidebar
2. **Name Your Project** and set your target selection count
3. **Add Source Folders** containing the photos you want to sort (supports multiple folders)
4. **Create** - PhotoSorter will scan and import all supported images

### Sorting Photos
1. **Select a Project** from the sidebar to begin sorting
2. **View your photos** in full-screen with elegant controls
3. **Categorize quickly**:
   - Use number keys `1-4` to assign categories
   - Or click the category buttons at the bottom
   - Press `0` to reset a photo to unrated
4. **Navigate** with arrow keys or on-screen chevron buttons
5. **Filter views** using the picker in the top bar to review specific categories

### Exporting Results
1. Click the **Export button** (↑) in the top-right corner
2. **Select categories** you want to export (can export multiple)
3. **Review total** photo count
4. Click **Export** and choose destination folder name and location
5. **Open in Finder** to view your curated collection

### Keyboard Shortcuts

#### Navigation
- `←` - Previous photo
- `→` - Next photo

#### Categorization
- `1` - Mark as Selected
- `2` - Mark as Shortlisted
- `3` - Mark as Unsure
- `4` - Mark as Rejected
- `0` - Reset to Unrated (only available when viewing filtered categories)

#### Application
- `⌘⇧⌥R` - Reset all data (requires app restart)

## 🏗️ Architecture

### Tech Stack
- **SwiftUI**: Modern declarative UI framework
- **SwiftData**: Apple's native data persistence layer
- **AppKit**: Integration for native macOS features (file panels, workspace)
- **Combine**: Reactive programming for view model updates

### Project Structure
```
PhotoSorter/
├── PhotoSorterApp.swift          # Main app entry point
├── ContentView.swift             # Root view wrapper
├── Models/
│   ├── Project.swift             # Project data model with SwiftData
│   ├── Photo.swift               # Photo metadata model
│   └── SelectionBucket.swift     # Category enum with UI properties
├── ViewModels/
│   ├── PhotoSortingViewModel.swift   # Core sorting logic & state
│   └── ExportViewModel.swift         # Export workflow management
├── Views/
│   ├── ProjectListView.swift     # Master list of projects
│   ├── CreateProjectView.swift   # Project creation form
│   ├── PhotoSortingView.swift    # Main sorting interface
│   ├── PhotoDisplayView.swift    # Full-screen photo viewer
│   ├── BucketSelectionView.swift # Category selection buttons
│   ├── StatsBarView.swift        # Statistics display
│   ├── FilterControlsView.swift  # Filter picker
│   └── ExportView.swift          # Export configuration sheet
└── Database/
    └── DatabaseManager.swift     # SwiftData helper utilities
```

### Key Design Patterns
- **MVVM Architecture**: Separation of UI and business logic
- **Observable Objects**: Reactive state management with `@Published` properties
- **Security-Scoped Resources**: Proper handling of folder access permissions
- **SwiftData Relationships**: Cascade deletion of photos when projects are removed
- **Lazy Loading**: Photos loaded on demand with multiple fallback strategies

## 🔐 Privacy & Security

- **Local-Only Storage**: All data stored in local SwiftData database
- **No Network Access**: App works completely offline
- **Security-Scoped Bookmarks**: Maintains folder access while respecting macOS sandboxing
- **No Photo Copying**: Only metadata stored; original photos remain untouched until export

## 🐛 Troubleshooting

### Photos Not Loading
- Ensure source folders are still accessible
- Check file permissions on source directories
- Verify image formats are supported (JPG, JPEG, PNG, HEIC)

### Export Fails
- Make sure destination folder is writable
- Check available disk space
- Try a different export location

### Database Issues
- Use Reset All Data (⌘⇧⌥R) to clear database and start fresh
- Database location: `~/Library/Application Support/default.store`

## 🛣️ Roadmap

Potential future enhancements:
- [ ] Batch operations on multiple photos
- [ ] Custom category names and colors
- [ ] Rating system (1-5 stars) in addition to categories
- [ ] EXIF metadata display
- [ ] Side-by-side photo comparison
- [ ] Undo/redo functionality
- [ ] Export with custom folder structure
- [ ] Import from Photos.app library

## 📄 License

MIT License - see [LICENSE](LICENSE) file for details

## 👨‍💻 Author

**Rajeev Ranjan**
- GitHub: [@rajeev14ranjan](https://github.com/rajeev14ranjan)

## 🙏 Acknowledgments

Built with ❤️ for photographers, content creators, and anyone who needs to efficiently curate large photo collections.

---

*Last Updated: December 2025*