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

  // Recursively scan directories safely
  void scanDirectory(Directory dir) {
    try {
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

      dir.listSync().forEach((entity) {
        if (entity is Directory) {
          if (entity.path.endsWith('/build')) {
            // Check if this is a Flutter project build directory
            if (isFlutterProject(entity)) {
              print(green('✅ Found Flutter build: ${entity.path}'));
              buildDirs.add(entity);
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

  print(bold('🎯 Found ${buildDirs.length} Flutter build directories:\n'));

  int index = 1;
  for (var dir in buildDirs) {
    String projectName =
        Directory(dir.path).parent.path.split(Platform.pathSeparator).last;
    print(green('$index. 📱 $projectName'));
    print(gray('   📍 Location: ${dir.path}\n'));
    index++;
  }

  // User interaction for deleting directories
  print(bold('⚙️  Options:'));
  print('1️⃣  Delete specific build directory (enter the number)');
  print('2️⃣  Delete all build directories');
  print('3️⃣  Exit');
  stdout.write('🔹 Enter your choice (1-3): ');
  String? choice = stdin.readLineSync();

  switch (choice) {
    case '1':
      stdout.write('🔢 Enter the number of the build directory to delete: ');
      String? dirNumStr = stdin.readLineSync();
      int? dirNum = int.tryParse(dirNumStr ?? '');
      if (dirNum != null && dirNum > 0 && dirNum <= buildDirs.length) {
        Directory dirToDelete = buildDirs[dirNum - 1];
        print(yellow('🗑️  Deleting: ${dirToDelete.path}'));
        dirToDelete.deleteSync(recursive: true);
        print(green('✅ Successfully deleted: ${dirToDelete.path}'));
      } else {
        print(red('❌ Invalid number selected'));
      }
      break;
    case '2':
      print(
          yellow('⚠️  Warning: This will delete all listed build directories'));
      stdout.write('❓ Are you sure? (y/N): ');
      String? confirm = stdin.readLineSync();
      if (confirm != null && confirm.toLowerCase() == 'y') {
        for (var dir in buildDirs) {
          print(yellow('🗑️  Deleting: ${dir.path}'));
          dir.deleteSync(recursive: true);
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
