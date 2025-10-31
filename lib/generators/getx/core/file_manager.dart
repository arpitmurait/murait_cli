import 'dart:io';

/// Handles all file operations for the GetX generator
class GetXFileManager {
  /// Create a file with content, ensuring parent directories exist
  Future<void> createFile({
    required String path,
    required String content,
    bool overwrite = false,
  }) async {
    final file = File(path);
    
    if (await file.exists() && !overwrite) {
      print('⚠️ File already exists: $path');
      return;
    }

    // Ensure directory exists
    await file.parent.create(recursive: true);
    await file.writeAsString(content);
    print('✅ Created file: $path');
  }

  /// Create a directory if it doesn't exist
  Future<void> createDirectory(String path) async {
    final directory = Directory(path);
    if (!await directory.exists()) {
      await directory.create(recursive: true);
      print('✅ Created directory: $path');
    }
  }

  /// Check if a file exists
  Future<bool> fileExists(String path) async {
    return await File(path).exists();
  }

  /// Check if a directory exists
  Future<bool> directoryExists(String path) async {
    return await Directory(path).exists();
  }

  /// Read file content
  Future<String> readFile(String path) async {
    final file = File(path);
    if (!await file.exists()) {
      throw FileSystemException('File not found: $path');
    }
    return await file.readAsString();
  }

  /// Write file content
  Future<void> writeFile(String path, String content) async {
    final file = File(path);
    await file.parent.create(recursive: true);
    await file.writeAsString(content);
  }

  /// Get project root directory
  Directory getProjectRoot() => Directory.current;
}

