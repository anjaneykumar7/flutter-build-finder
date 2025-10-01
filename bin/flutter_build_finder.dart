import 'dart:io';
import 'package:ansicolor/ansicolor.dart';

void main() {
  // Initialize ANSI color codes
  AnsiPen bold = AnsiPen()..white(bold: true);
  AnsiPen green = AnsiPen()..green();
  AnsiPen yellow = AnsiPen()..yellow();
  // Remove the unused 'blue' variable
  AnsiPen gray = AnsiPen()..gray();
  AnsiPen red = AnsiPen()..red();

  String homeDir = Platform.environment['HOME'] ?? '';
  List<Directory> buildDirs = [];
  // Track seen build directory paths to avoid duplicates
  final Set<String> seenBuildPaths = {};

  print('🔍 Scanning for Flutter build directories in: $homeDir');

  // Check if directory is a Flutter project
  bool isFlutterProject(Directory dir) {
    Directory parentDir = Directory(dir.path).parent;

    // Check for pubspec.yaml which is present in Flutter projects
    File pubspecFile = File('${parentDir.path}/pubspec.yaml');
    if (pubspecFile.existsSync()) {
      try {
        String content = pubspecFile.readAsStringSync();
        // Check if the pubspec contains Flutter SDK dependency
        return content.contains('flutter:') || content.contains('sdk: flutter');
      } catch (e) {
        return false;
      }
    }

    // Check for .flutter-plugins or .metadata files which are also indicators
    File flutterPluginsFile = File('${parentDir.path}/.flutter-plugins');
    File metadataFile = File('${parentDir.path}/.metadata');

    return flutterPluginsFile.existsSync() || metadataFile.existsSync();
  }

  // Check if the given directory is a Flutter project root
  bool isFlutterProjectRoot(Directory dir) {
    File pubspecFile = File('${dir.path}/pubspec.yaml');
    if (pubspecFile.existsSync()) {
      try {
        String content = pubspecFile.readAsStringSync();
        return content.contains('flutter:') || content.contains('sdk: flutter');
      } catch (e) {
        return false;
      }
    }
    File flutterPluginsFile = File('${dir.path}/.flutter-plugins');
    File metadataFile = File('${dir.path}/.metadata');
    return flutterPluginsFile.existsSync() || metadataFile.existsSync();
  }

  // Skip known non-project locations (plugin symlinks, SDK, integration_test, etc.)
  bool isSkippedPath(String inputPath) {
    final path = inputPath.replaceAll('\\', '/');
    // iOS plugin symlinks
    if (path.contains('/ios/.symlinks/plugins/')) return true;
    // Generic symlinked plugins (covers macOS Flutter ephemeral symlinks)
    if (path.contains('/.symlinks/plugins/')) return true;
    // Generic plugin symlinks across desktop platforms
    if (path.contains('/.plugin_symlinks/')) return true;
    // Linux plugin symlinks (explicit)
    if (path.contains('/linux/flutter/ephemeral/.plugin_symlinks/'))
      return true;
    // Windows plugin symlinks
    if (path.contains('/windows/flutter/ephemeral/.plugin_symlinks/'))
      return true;
    // macOS plugin symlinks (Flutter dir can be capitalized)
    if (path.contains('/macos/Flutter/ephemeral/.plugin_symlinks/'))
      return true;
    if (path.contains('/macos/flutter/ephemeral/.plugin_symlinks/'))
      return true;
    // FVM-managed Flutter SDK or version caches
    if (path.contains('/.fvm/')) return true;
    if (path.contains('/fvm/')) return true;
    // Flutter SDK packages like integration_test
    if (path.contains('/packages/integration_test/')) return true;
    return false;
  }

  // Add platform-specific build directories for a Flutter project root
  void addPlatformBuildDirs(Directory projectRoot) {
    List<String> candidates = [
      '${projectRoot.path}/build',
      '${projectRoot.path}/android/build',
      '${projectRoot.path}/ios/build',
      '${projectRoot.path}/web/build',
    ];

    for (final path in candidates) {
      final d = Directory(path);
      if (d.existsSync()) {
        if (seenBuildPaths.add(d.path)) {
          print(green('✅ Found Flutter build: ${d.path}'));
          buildDirs.add(d);
        }
      }
    }
  }

  // Recursively scan directories safely
  void scanDirectory(Directory dir) {
    try {
      if (isSkippedPath(dir.path)) {
        return;
      }
      // Skip Xcode directories on macOS
      if (Platform.isMacOS && dir.path.contains('Library/Developer')) {
        // print(gray('⏩ Skipping Xcode directory: ${dir.path}'));
        return;
      }

      // Skip pub cache hosted directories
      if (dir.path.contains('/.pub-cache/hosted/')) {
        // print(gray('⏩ Skipping pub cache directory: ${dir.path}'));
        return;
      }

      // If current dir is a Flutter project root, gather known build dirs
      if (isFlutterProjectRoot(dir)) {
        addPlatformBuildDirs(dir);
      }

      dir.listSync().forEach((entity) {
        if (entity is Directory) {
          if (isSkippedPath(entity.path)) {
            return;
          }
          if (entity.path.endsWith('/build')) {
            // Check if this is a Flutter project build directory
            if (isFlutterProject(entity)) {
              if (seenBuildPaths.add(entity.path)) {
                print(green('✅ Found Flutter build: ${entity.path}'));
                buildDirs.add(entity);
                // Also attempt to add platform build dirs based on project root
                Directory parentDir = Directory(entity.path).parent;
                Directory projectRoot = parentDir;
                // If pubspec not at parent, try grandparent
                if (!File('${parentDir.path}/pubspec.yaml').existsSync() &&
                    File('${parentDir.parent.path}/pubspec.yaml')
                        .existsSync()) {
                  projectRoot = parentDir.parent;
                }
                if (isFlutterProjectRoot(projectRoot)) {
                  addPlatformBuildDirs(projectRoot);
                }
              }
            } else {
              // print(gray('⏩ Skipping non-Flutter build: ${entity.path}'));
            }
          } else {
            // Skip Xcode directories on macOS
            if (Platform.isMacOS && entity.path.contains('Library/Developer')) {
              // print(gray('⏩ Skipping Xcode directory: ${entity.path}'));
              return;
            }
            // Skip Xcode directories on macOS
            if (Platform.isMacOS &&
                entity.path.contains('Library/Containers')) {
              // print(gray('⏩ Skipping Xcode directory: ${entity.path}'));
              return;
            }

            // Skip pub cache hosted directories
            if (entity.path.contains('/.pub-cache/hosted/')) {
              // print(gray('⏩ Skipping pub cache directory: ${entity.path}'));
              return;
            }

            scanDirectory(entity);
          }
        }
      });
    } on FileSystemException catch (_) {
      // print(gray('⚠️ Skipping inaccessible directory: ${dir.path}'));
    } catch (e) {
      print(red('❌ Unexpected error: $e'));
    }
  }

  scanDirectory(Directory(homeDir));

  if (buildDirs.isEmpty) {
    print(red('❌ No Flutter build directories found.'));
    return;
  }

  // Helper: find the Flutter project root for a given build directory
  Directory? findProjectRootForBuildDir(Directory dir) {
    Directory current = Directory(dir.path);
    for (int i = 0; i < 5; i++) {
      if (isFlutterProjectRoot(current)) {
        return current;
      }
      current = current.parent;
    }
    return null;
  }

  // Group build directories by project root
  final Map<String, List<Directory>> projectLocations = {};
  final Map<String, String> projectNames = {};
  for (var dir in buildDirs) {
    final rootDir =
        findProjectRootForBuildDir(dir) ?? Directory(dir.path).parent;
    final rootPath = rootDir.path;
    final projectName = rootPath.split(Platform.pathSeparator).last;
    projectNames[rootPath] = projectName;
    final list = projectLocations.putIfAbsent(rootPath, () => []);
    if (!list.any((d) => d.path == dir.path)) {
      list.add(dir);
    }
  }

  print(bold(
      '🎯 Found ${projectLocations.length} Flutter projects with build directories:\n'));

  int index = 1;
  final List<String> projectRootsInOrder = projectLocations.keys.toList();
  for (final root in projectRootsInOrder) {
    final projectName =
        projectNames[root] ?? root.split(Platform.pathSeparator).last;
    print(green('$index. 📱 $projectName'));
    for (final loc in projectLocations[root]!) {
      print(gray('   📍 Location: ${loc.path}'));
    }
    print('');
    index++;
  }

  // User interaction for deleting directories
  print(bold('⚙️  Options:'));
  print('1️⃣  Delete specific build directory (select project then location)');
  print('2️⃣  Delete all build directories');
  print('3️⃣  Exit');
  stdout.write('🔹 Enter your choice (1-3): ');
  String? choice = stdin.readLineSync();

  switch (choice) {
    case '1':
      stdout.write('🔢 Enter the number of the project to manage: ');
      String? projNumStr = stdin.readLineSync();
      int? projNum = int.tryParse(projNumStr ?? '');
      if (projNum != null &&
          projNum > 0 &&
          projNum <= projectRootsInOrder.length) {
        final selectedRoot = projectRootsInOrder[projNum - 1];
        final locations = projectLocations[selectedRoot] ?? [];
        if (locations.isEmpty) {
          print(red('❌ No build locations found for the selected project'));
          break;
        }
        print(bold(
            '📦 Locations for ${projectNames[selectedRoot] ?? selectedRoot}:'));
        for (int i = 0; i < locations.length; i++) {
          print(green('   ${i + 1}. ${locations[i].path}'));
        }
        stdout.write('🗑️  Enter the location number to delete: ');
        String? locNumStr = stdin.readLineSync();
        int? locNum = int.tryParse(locNumStr ?? '');
        if (locNum != null && locNum > 0 && locNum <= locations.length) {
          final dirToDelete = locations[locNum - 1];
          print(yellow('🗑️  Deleting: ${dirToDelete.path}'));
          dirToDelete.deleteSync(recursive: true);
          print(green('✅ Successfully deleted: ${dirToDelete.path}'));
        } else {
          print(red('❌ Invalid location number selected'));
        }
      } else {
        print(red('❌ Invalid project number selected'));
      }
      break;
    case '2':
      print(
          yellow('⚠️  Warning: This will delete all listed build directories'));
      stdout.write('❓ Are you sure? (y/N): ');
      String? confirm = stdin.readLineSync();
      if (confirm != null && confirm.toLowerCase() == 'y') {
        for (final root in projectRootsInOrder) {
          for (final dir in projectLocations[root]!) {
            print(yellow('🗑️  Deleting: ${dir.path}'));
            dir.deleteSync(recursive: true);
          }
        }
        print(green('✅ All build directories deleted.'));
      } else {
        print('🚫 Operation cancelled');
      }
      break;
    case '3':
      print('👋 Exiting...');
      exit(0);
    default:
      print(red('❌ Invalid choice'));
  }
}
