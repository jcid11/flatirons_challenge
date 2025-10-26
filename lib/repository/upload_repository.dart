import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';

import '../models/uploaded_file.dart';

class UploadRepository {
  UploadRepository({FirebaseStorage? storage, FirebaseFirestore? firestore})
    : _storage = storage ?? FirebaseStorage.instance,
      _db = firestore ?? FirebaseFirestore.instance;
  final FirebaseStorage _storage;
  final FirebaseFirestore _db;

  Future<List<(String path, String name)>> pickCsvs() async {
    final r = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      type: FileType.custom,
      allowedExtensions: ['csv'],
    );
    if (r == null) return [];
    return r.files
        .where((f) => f.path != null)
        .map((f) => (f.path!, f.name))
        .toList();
  }

  UploadTask putFile(String localPath, String storagePath) {
    return _storage
        .ref(storagePath)
        .putFile(File(localPath), SettableMetadata(contentType: 'text/csv'));
  }

  String pathFor(String name) {
    final now = DateTime.now();
    final safe = name.replaceAll(' ', '_');
    return 'uploads/${now.year}/${now.month.toString().padLeft(2, '0')}/${now.day.toString().padLeft(2, '0')}/$safe';
  }

  Future<String> urlFor(String storagePath) =>
      _storage.ref(storagePath).getDownloadURL();

  Future<void> logSuccess({
    required String name,
    required String storagePath,
    required String downloadUrl,
  }) async {
    await _db.collection('csv_uploads').add({
      'name': name,
      'storagePath': storagePath,
      'url': downloadUrl,
      'uploadedAt': FieldValue.serverTimestamp(),
    });
  }

  Stream<int> uploadedCountStream() {
    return _db.collection('csv_uploads').snapshots().map((s) => s.size);
  }

  Stream<List<UploadedFile>> streamUploadedFiles() {
    return _db
        .collection('csv_uploads')
        .orderBy('uploadedAt', descending: true)
        .snapshots()
        .map((qs) => qs.docs.map((d) => UploadedFile.fromDoc(d)).toList());
  }

  Future<void> deleteUploadedFile({
    required String docId,
    required String storagePath,
  }) async {
    await _storage.ref(storagePath).delete();
    await _db.collection('csv_uploads').doc(docId).delete();
  }
}
