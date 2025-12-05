# PhotoSorter

A beautiful macOS app for efficiently sorting and selecting photos from large collections.

## Features

- **Project-based Organization**: Create multiple projects, each with its own set of photos and selection criteria
- **Multiple Source Folders**: Import photos from multiple directories into a single project
- **Smart Categorization**: Sort photos into categories:
  - ✅ Definitely Selected
  - 🏁 Selection Candidate
  - ❓ Not Sure
  - ❌ Rejected
- **Keyboard Shortcuts**: Quick selection using keys 1-4 for categories
- **Full-Screen Viewing**: Immersive photo viewing experience with elegant overlay controls
- **Target Goals**: Set a target number of photos to select for each project
- **Flexible Filtering**: View photos by category or see all unrated photos
- **Export**: Export selected photos organized by category

## Requirements

- macOS 14.0 or later
- Xcode 15.0 or later (for building from source)

## Installation

1. Clone the repository:
   ```bash
   git clone https://github.com/rajeev14ranjan/PhotoSorter.git
   ```

2. Open `PhotoSorter.xcodeproj` in Xcode

3. Build and run the project

## Usage

1. **Create a Project**: Click "Create New Project" and add source folders containing your photos
2. **Set Target**: Define how many photos you want to select
3. **Start Sorting**: Navigate through photos using arrow keys or on-screen buttons
4. **Categorize**: Use keyboard shortcuts (1-4) or click buttons to categorize each photo
5. **Export**: Export your selected photos when done

### Keyboard Shortcuts

- `←/→` - Navigate between photos
- `1` - Definitely Selected
- `2` - Selection Candidate
- `3` - Not Sure
- `4` - Rejected
- `0` - Reset to Unrated

## Tech Stack

- SwiftUI
- SwiftData (for local data persistence)
- AppKit integration

## License

MIT License - see [LICENSE](LICENSE) file for details

## Author

Rajeev Ranjan

---

Made with ❤️ for photographers and anyone dealing with large photo collections