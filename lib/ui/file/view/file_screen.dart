part of 'file_form.dart';

class FileScreen extends StatelessWidget {
  const FileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final repo = context.read<UploadRepository>();
    final messenger = ScaffoldMessenger.of(context); // <— stable messenger

    return Scaffold(
      appBar: AppBar(title: const Text('Uploaded Files')),
      body: StreamBuilder<List<UploadedFile>>(
        stream: repo.streamUploadedFiles(),
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final files = snap.data ?? const <UploadedFile>[];
          if (files.isEmpty) {
            return const Center(child: Text('No uploaded files yet.'));
          }

          return ListView.separated(
            padding: const EdgeInsets.all(12),
            itemCount: files.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, i) {
              final f = files[i];
              return Card(
                child: ListTile(
                  leading: const Icon(Icons.insert_drive_file),
                  title: Text(
                    f.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  subtitle: Text(
                    f.storagePath,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  trailing: IconButton(
                    tooltip: 'Delete file',
                    icon: const Icon(Icons.delete_forever),
                    onPressed: () async {
                      final ok = await showDialog<bool>(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          title: const Text('Delete file?'),
                          content: Text(
                            'This will remove "${f.name}" from storage and from the list.',
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(ctx, false),
                              child: const Text('Cancel'),
                            ),
                            FilledButton(
                              onPressed: () => Navigator.pop(ctx, true),
                              child: const Text('Delete'),
                            ),
                          ],
                        ),
                      );
                      if (ok != true) return;

                      if (context.mounted) {
                        messenger.hideCurrentSnackBar();
                      }

                      try {
                        await repo.deleteUploadedFile(
                          docId: f.id,
                          storagePath: f.storagePath,
                        );
                        messenger.showSnackBar(const SnackBar(
                          content: Text('File deleted'),
                          behavior: SnackBarBehavior.floating,
                        ));
                      } catch (e) {
                          messenger.showSnackBar(
                            SnackBar(
                              content: Text('Delete failed: $e'),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                      }
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
