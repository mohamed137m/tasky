// import 'dart:io';

// import 'package:path_provider/path_provider.dart';

// class FileStorageManager {
//   static final FileStorageManager _instance = FileStorageManager._();
//   FileStorageManager._();
//   factory FileStorageManager() {
//     return _instance;
//   }
//   late final Directory _applicationDocumentsDirectory;
//   late final File _path;
//   void init() async {
//     _applicationDocumentsDirectory = await getApplicationDocumentsDirectory();
//     _path = File("${_applicationDocumentsDirectory.path}/tasks.json");
//   }
// }
