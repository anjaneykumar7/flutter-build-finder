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

## 0.1.1

* Fixes:
  - Skip plugin symlink build paths across platforms:
    - `ios/.symlinks/plugins/...`
    - `*/flutter/ephemeral/.plugin_symlinks/...` (windows, macos, linux)
    - generic `/.plugin_symlinks/...`
  - Skip FVM SDK caches: `/.fvm/...` and `/fvm/...`
  - Skip Flutter SDK package builds like `packages/integration_test/...`
* Result:
  - Only real project builds are listed under their project with clean locations, avoiding plugin and SDK noise.

## 0.1.2

* Fixes:
  - Skip macOS Flutter ephemeral symlinked plugins: `macos/Flutter/ephemeral/.symlinks/plugins/...`
  - Added generic `/.symlinks/plugins/...` filter to catch similar paths across platforms.
* Result:
  - Further reduces noise from non-project build directories; lists only real project build folders.