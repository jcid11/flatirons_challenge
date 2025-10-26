import 'package:cloud_firestore/cloud_firestore.dart';

class UploadedFile {
  UploadedFile({
    required this.id,
    required this.name,
    required this.storagePath,
    required this.url,
    required this.uploadedAt,
  });

  final String id;
  final String name;
  final String storagePath;
  final String url;
  final DateTime? uploadedAt;

  factory UploadedFile.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data()!;
    return UploadedFile(
      id: doc.id,
      name: d['name'] as String? ?? '',
      storagePath: d['storagePath'] as String? ?? '',
      url: d['url'] as String? ?? '',
      uploadedAt: (d['uploadedAt'] as Timestamp?)?.toDate(),
    );
  }
}
