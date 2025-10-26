import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../models/upload_item.dart';
import '../../repository/upload_repository.dart';

part 'upload_event.dart';

part 'upload_state.dart';

class UploadBloc extends Bloc<UploadEvent, UploadState> {
  UploadBloc(this._repo) : super(const UploadState()) {
    on<PickAndUploadRequested>(_onPickAndUpload);
    on<ProgressEvent>(_onProgress);
    on<StatusEvent>(_onStatus);
    on<RemoveEvent>(_onRemove);
    _countSub = _repo.uploadedCountStream().listen((n) {
      add(CountUpdateEvent(count: n));
    });
    on<CountUpdateEvent>(_countUpdate);
  }


  final UploadRepository _repo;
  final Map<String, StreamSubscription<TaskSnapshot>> _subs = {};
  String _id(String path) => path.hashCode.toString();
  StreamSubscription<int>? _countSub;


  void _countUpdate(CountUpdateEvent e, Emitter<UploadState>emit) =>
      emit(state.copyWith(uploadedCount: e.count));

  Future<void> _onPickAndUpload(PickAndUploadRequested e,
      Emitter<UploadState> emit) async {
    final picked = await _repo.pickCsvs();
    if (picked.isEmpty) return;

    final items = List<UploadItem>.from(state.items);
    for (final (path, name) in picked) {
      final id = _id(path + DateTime
          .now()
          .microsecondsSinceEpoch
          .toString());
      items.add(UploadItem(
          id: id, name: name, localPath: path, status: UploadStatus.queued));
    }
    emit(state.copyWith(items: items));


    for (final it in items.where((x) => x.status == UploadStatus.queued)) {
      final storagePath = _repo.pathFor(it.name);
      final task = _repo.putFile(it.localPath, storagePath);


      _subs[it.id]?.cancel();
      _subs[it.id] = task.snapshotEvents.listen((snap) async {
        add(ProgressEvent(id: it.id,
            transferred: snap.bytesTransferred,
            total: snap.totalBytes));
        if (snap.state == TaskState.success) {
          final url = await _repo.urlFor(storagePath);
          unawaited(_repo.logSuccess(name: it.name, storagePath: storagePath, downloadUrl: url));
          add(StatusEvent(it.id, UploadStatus.success, downloadUrl: url));
        } else if (snap.state == TaskState.error) {
          add(StatusEvent(it.id, UploadStatus.failure, error: 'Upload failed'));
        } else if (snap.state == TaskState.running) {
          add(StatusEvent(it.id, UploadStatus.uploading));
        }
      });
    }
  }


  void _onProgress(ProgressEvent e, Emitter<UploadState> emit) {
    final upd = state.items.map((it) =>
    it.id == e.id
        ? it.copyWith(transferred: e.transferred, totalBytes: e.total)
        : it).toList();
    emit(state.copyWith(items: upd));
  }


  void _onStatus(StatusEvent e, Emitter<UploadState> emit) {
    final upd = state.items.map((it) =>
    it.id == e.id
        ? it.copyWith(
        status: e.status, downloadUrl: e.downloadUrl, error: e.error)
        : it).toList();
    emit(state.copyWith(items: upd));


    if (e.status == UploadStatus.success) {
      Future.delayed(const Duration(seconds: 2), () {
        if (isClosed) return;
        final current = state.items.firstWhere(
              (it) => it.id == e.id,
          orElse: () => const UploadItem(id: '', name: '', localPath: ''),
        );
        if (current.id.isNotEmpty && current.status == UploadStatus.success) {
          add(RemoveEvent(id: e.id));
        }
      });
    }
  }

  void _onRemove(RemoveEvent e, Emitter<UploadState>emit) {
    _subs.remove(e.id)?.cancel();
    final filtered = state.items.where((it) => it.id != e.id).toList();
    emit(state.copyWith(items: filtered));
  }


  @override
  Future<void> close() async {
    for (final s in _subs.values) {
      await s.cancel();
    }
    await _countSub?.cancel();

    return super.close();
  }
}