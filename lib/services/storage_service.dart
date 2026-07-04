import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:uuid/uuid.dart';

class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final _uuid = const Uuid();

  Future<String> uploadGemImage(File file, String sellerId) async {
    final fileName = '${_uuid.v4()}.jpg';
    final ref = _storage.ref().child('gem_images/$sellerId/$fileName');
    final uploadTask = await ref.putFile(file);
    return await uploadTask.ref.getDownloadURL();
  }

  Future<List<String>> uploadGemImages(List<File> files, String sellerId) async {
    final urls = <String>[];
    for (final f in files) {
      urls.add(await uploadGemImage(f, sellerId));
    }
    return urls;
  }

  Future<String> uploadUserAvatar(File file, String uid) async {
    final ref = _storage.ref().child('avatars/$uid.jpg');
    final uploadTask = await ref.putFile(file);
    return await uploadTask.ref.getDownloadURL();
  }
}
