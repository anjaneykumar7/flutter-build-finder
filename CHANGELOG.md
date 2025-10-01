## 0.0.1

* Initial release of Flutter Build Finder
* Features:
  - Recursive scanning of Flutter build directories
  - Smart detection of Flutter projects
  - Interactive CLI interface
  - Selective or bulk deletion of build directories
  - Safe operations with permission handling

## 0.1.0

* Enhancements:
  - Group results by project: show a single `📱 project` entry with multiple `📍 Location` lines
  - Attach platform build folders (`android/build`, `ios/build`, `web/build`) alongside root `build`
  - Deduplicate build entries and improve labeling for clarity
* UX:
  - Updated delete flow: select project first, then choose specific location to delete