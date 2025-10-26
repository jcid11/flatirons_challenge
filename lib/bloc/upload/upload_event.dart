part of 'upload_bloc.dart';

abstract class UploadEvent extends Equatable {
  const UploadEvent();

  @override
  List<Object?> get props => [];
}

class PickAndUploadRequested extends UploadEvent {}

class ProgressEvent extends UploadEvent {
  final String id;
  final int transferred;
  final int? total;

  const ProgressEvent({required this.id,required this.transferred,required this.total});
}

class StatusEvent extends UploadEvent {
  final String id;
  final UploadStatus status;
  final String? downloadUrl;
  final String? error;
  const StatusEvent(this.id, this.status, {this.downloadUrl, this.error});
}

class RemoveEvent extends UploadEvent{
  final String id;

  const RemoveEvent({required this.id});
}

class CountUpdateEvent extends UploadEvent {
  const CountUpdateEvent({required this.count});
  final int count;
  @override
  List<Object?> get props => [count];
}
