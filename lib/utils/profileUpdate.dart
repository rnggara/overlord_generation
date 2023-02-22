import 'dart:convert';
import 'dart:io';

import 'package:overlord_generation/models/profile.dart';
import 'package:path_provider/path_provider.dart';

class ProfileUpdate {
  Future updateProfile(data) async {
    final path = await getApplicationDocumentsDirectory();
    final file_path = await path.path;
    File file = File('$file_path/.profile');
    String json = jsonEncode(data);
    file.writeAsString('$json');
  }

  Future<Profile?> getProfile() async {
    Profile? _profile;
    String fileName = ".profile";
    String dir = (await getApplicationDocumentsDirectory()).path;
    String savePath = '$dir/$fileName';

    //for a directory: await Directory(savePath).exists();
    if (await File(savePath).exists()) {
      print("File exists");
    } else {
      print("File don't exists");
    }

    final path = await getApplicationDocumentsDirectory();
    final file_path = await path.path;
    File file = File('$file_path/.profile');

    final profile = file.readAsString();
    print(profile);
    profile.then((value) {
      var _json = jsonDecode(value);
      print(_json);
      _profile = new Profile(_json['id'], _json['name']);
      print(_profile);
    });

    print(_profile);
    return _profile;
  }
}
