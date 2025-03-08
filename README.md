
# Flutter Build Finder

A command-line tool to find and manage Flutter build directories across your system.

[![pub package](https://img.shields.io/pub/v/flutter_build_finder.svg)](https://pub.dev/packages/flutter_build_finder)

## Features

- 🔍 Recursively scans your system for Flutter build directories
- ✨ Identifies genuine Flutter project build folders
- 🧹 Allows selective or bulk deletion of build directories
- 💡 Smart filtering to skip system directories
- 🚀 Easy-to-use interactive CLI interface

## Installation

```bash
dart pub global activate flutter_build_finder
```

## Usage

Simply run the command in your terminal:

```bash
flutter_build_finder
```

The tool will:
1. Scan your system for Flutter build directories
2. Display a list of found build directories
3. Provide options to:
   - Delete a specific build directory
   - Delete all found build directories
   - Exit the program

## Screenshots

[Add screenshots of your CLI tool in action]

## Features in Detail

- **Smart Detection**: Identifies Flutter projects by checking for:
  - pubspec.yaml with Flutter SDK dependency
  - .flutter-plugins file
  - .metadata file

- **Safe Operations**: 
  - Skips system directories
  - Handles permissions gracefully
  - Confirms before bulk deletions

- **User-Friendly Interface**:
  - Colored output for better readability
  - Clear numbering system
  - Interactive prompts

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

```
MIT License

Copyright (c) 2024 Anjaney Kumar

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
```

## Author

**Anjaney Kumar** - [@anjaneykumar7](https://github.com/anjaneykumar7)

## Links

- [GitHub Repository](https://github.com/anjaneykumar7/flutter-build-finder)
- [Bug Reports](https://github.com/anjaneykumar7/flutter-build-finder/issues)
- [Pub.dev Package](https://pub.dev/packages/flutter_build_finder)