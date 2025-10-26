import 'package:equatable/equatable.dart';

enum UploadStatus { queued, uploading, success, failure }

class UploadItem extends Equatable {
  const UploadItem({
    required this.id,
    required this.name,
    required this.localPath,
    this.totalBytes,
    this.transferred = 0,
    this.status = UploadStatus.queued,
    this.downloadUrl,
    this.error,
  });

  final String id;
  final String name;
  final String localPath;
  final int? totalBytes;
  final int transferred;
  final UploadStatus status;
  final String? downloadUrl;
  final String? error;

  double get progress =>
      (totalBytes == null || totalBytes == 0) ? 0 : transferred / totalBytes!;

  UploadItem copyWith({
    int? totalBytes,
    int? transferred,
    UploadStatus? status,
    String? downloadUrl,
    String? error,
  }) => UploadItem(
    id: id,
    name: name,
    localPath: localPath,
    totalBytes: totalBytes ?? this.totalBytes,
    transferred: transferred ?? this.transferred,
    status: status ?? this.status,
    downloadUrl: downloadUrl ?? this.downloadUrl,
    error: error ?? this.error,
  );

  @override
  List<Object?> get props => [
    id,
    name,
    localPath,
    totalBytes,
    transferred,
    status,
    downloadUrl,
    error,
  ];
}
