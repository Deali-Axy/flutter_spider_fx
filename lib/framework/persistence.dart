import 'dart:io';

import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Persistence {
  static bool isInit = false;
  static SharedPreferences _preferences;
  static String _applicationDocumentsDirectory;
  static String _externalStorageDirectory;
  static String _downloadsDirectory;
  static String _libraryDirectory;
  static String _temporaryDirectory;
  static String _applicationSupportDirectory;

  static SharedPreferences get preferences => _preferences;

  static String get applicationDocumentsDirectory => _applicationDocumentsDirectory;

  static String get externalStorageDirectory => _externalStorageDirectory;

  static String get downloadsDirectory => _downloadsDirectory;

  static String get libraryDirectory => _libraryDirectory;

  static String get temporaryDirectory => _temporaryDirectory;

  static String get applicationSupportDirectory => _applicationSupportDirectory;

  static bool exists(String path) => FileSystemEntity.typeSync(path) != FileSystemEntityType.notFound;

  static Future init() async {
    _preferences = await SharedPreferences.getInstance();

    if (Platform.isAndroid) {
      _applicationDocumentsDirectory = (await getApplicationDocumentsDirectory()).path;
      _externalStorageDirectory = (await getExternalStorageDirectory()).path;
      _temporaryDirectory = (await getTemporaryDirectory()).path;
      _applicationSupportDirectory = (await getApplicationSupportDirectory()).path;
    }

    if (Platform.isIOS) {
      _downloadsDirectory = (await getDownloadsDirectory()).path;
      _libraryDirectory = (await getLibraryDirectory()).path;
    }
  }
}
