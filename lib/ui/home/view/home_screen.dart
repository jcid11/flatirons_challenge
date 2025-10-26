part of 'home_form.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('CSV Uploader (Simple)'),
        actions: [
          BlocBuilder<UploadBloc, UploadState>(
            buildWhen: (p, n) => p.uploadedCount != n.uploadedCount,
            builder: (context, state) {
              return Padding(
                padding: const EdgeInsets.only(right: 12),
                child: CounterBadge(
                  icon: Icons.file_copy,
                  count: state.uploadedCount,
                  tooltip: 'Total uploaded',
                ),
              );
            },
          ),
        ],
      ),

      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            FilledButton.icon(
              icon: const Icon(Icons.add),
              label: const Text('Pick & Upload CSVs'),
              onPressed: () =>
                  context.read<UploadBloc>().add(PickAndUploadRequested()),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: BlocBuilder<UploadBloc, UploadState>(
                builder: (context, state) {
                  if (state.items.isEmpty) {
                    return const Center(
                      child: Text('Pick CSV files to start uploading.'),
                    );
                  }
                  return ListView.separated(
                    itemCount: state.items.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (context, i) => Tile(item: state.items[i]),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
