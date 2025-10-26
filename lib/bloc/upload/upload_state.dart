part of 'upload_bloc.dart';

class UploadState extends Equatable {
  final List<UploadItem> items;
  final int uploadedCount;

  const UploadState({this.items = const [], this.uploadedCount = 0});

  UploadState copyWith({List<UploadItem>? items, int? uploadedCount}) =>
      UploadState(
        items: items ?? this.items,
        uploadedCount: uploadedCount ?? this.uploadedCount,
      );

  @override
  List<Object?> get props => [items, uploadedCount];
}
