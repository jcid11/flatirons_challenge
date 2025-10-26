import 'package:flatirons_challenge/ui/file/file_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../bloc/upload/upload_bloc.dart';
import '../../../models/upload_item.dart';

part 'home_screen.dart';

class CounterBadge extends StatelessWidget {
  const CounterBadge({
    super.key,
    required this.icon,
    required this.count,
    this.tooltip,
  });

  final IconData icon;
  final int count;
  final String? tooltip;

  @override
  Widget build(BuildContext context) {
    final badge = Badge.count(
      count: count,
      isLabelVisible: count > 0,
      child: RawMaterialButton(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => FilePage()),
        ),
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        constraints: const BoxConstraints(minWidth: 0),
        child: Icon(Icons.folder),
      ),
    );
    return tooltip == null ? badge : Tooltip(message: tooltip!, child: badge);
  }
}

class Tile extends StatelessWidget {
  const Tile({super.key, required this.item});

  final UploadItem item;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.insert_drive_file),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    item.name,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
                _statusIcon(item.status),
              ],
            ),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: item.status == UploadStatus.success
                  ? 1
                  : (item.progress == 0 ? null : item.progress),
            ),
            const SizedBox(height: 6),
            Text(
              _statusText(item),
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }

  Widget _statusIcon(UploadStatus s) {
    return switch (s) {
      UploadStatus.uploading => const SizedBox(
        width: 24,
        height: 24,
        child: CircularProgressIndicator(strokeWidth: 2),
      ),
      UploadStatus.success => const Icon(
        Icons.check_circle,
        color: Colors.green,
      ),
      UploadStatus.failure => const Icon(Icons.error, color: Colors.red),
      _ => const SizedBox.shrink(),
    };
  }

  String _statusText(UploadItem i) {
    switch (i.status) {
      case UploadStatus.queued:
        return 'Queued';
      case UploadStatus.uploading:
        return 'Uploading ${(i.progress * 100).toStringAsFixed(1)}%';
      case UploadStatus.success:
        return 'Uploaded ✔';
      case UploadStatus.failure:
        return 'Failed${i.error != null ? ': ${i.error}' : ''}';
    }
  }
}
