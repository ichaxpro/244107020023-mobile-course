import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'data/local/note.dart';
import 'providers/notes_provider.dart';

void main() {
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Offline Notes',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
        useMaterial3: true,
      ),
      home: const NotesPage(),
    );
  }
}

class NotesPage extends ConsumerWidget {
  const NotesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filteredNotes = ref.watch(filteredNotesProvider);
    final dirtyCount = ref.watch(dirtyNotesCountProvider);
    final forceOffline = ref.watch(forceOfflineProvider);
    final currentQuery = ref.watch(searchQueryProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Catatan Offline'),
        actions: [
          IconButton(
            tooltip: 'Tambah catatan',
            onPressed: () => _showAddNoteDialog(context, ref),
            icon: const Icon(Icons.add),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => ref.read(notesProvider.notifier).reload(),
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _OfflineControls(forceOffline: forceOffline, ref: ref),
            const SizedBox(height: 16),
            dirtyCount.when(
              data: (count) => _DirtyBadge(count: count),
              loading: () => const LinearProgressIndicator(),
              error: (error, _) => Text('Gagal membaca status sync: $error'),
            ),
            const SizedBox(height: 16),
            const _SearchInput(),
            const SizedBox(height: 16),
            filteredNotes.when(
              data: (items) => _NotesList(
                notes: items,
                query: currentQuery,
              ),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, _) => Text('Gagal memuat catatan: $error'),
            ),
          ],
        ),
      ),
    );
  }
}

class _SearchInput extends ConsumerStatefulWidget {
  const _SearchInput();

  @override
  ConsumerState<_SearchInput> createState() => _SearchInputState();
}

class _SearchInputState extends ConsumerState<_SearchInput> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: ref.read(searchQueryProvider));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final query = ref.watch(searchQueryProvider);
    if (_controller.text != query) {
      _controller.text = query;
    }

    return TextField(
      controller: _controller,
      decoration: InputDecoration(
        hintText: 'Cari judul catatan...',
        prefixIcon: const Icon(Icons.search),
        suffixIcon: query.isNotEmpty
            ? IconButton(
                icon: const Icon(Icons.clear),
                onPressed: () {
                  _controller.clear();
                  ref.read(searchQueryProvider.notifier).clear();
                },
              )
            : null,
        filled: true,
        fillColor: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
      onChanged: (value) {
        ref.read(searchQueryProvider.notifier).setQuery(value);
      },
    );
  }
}

class _OfflineControls extends StatelessWidget {
  const _OfflineControls({required this.forceOffline, required this.ref});

  final AsyncValue<bool> forceOffline;
  final WidgetRef ref;

  @override
  Widget build(BuildContext context) {
    final isOffline = forceOffline.value ?? false;
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          children: [
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Paksa mode offline'),
              subtitle: Text(
                isOffline
                    ? 'Sync ditahan untuk demo offline'
                    : 'Koneksi tersedia untuk sinkronisasi',
              ),
              value: isOffline,
              onChanged: forceOffline.isLoading
                  ? null
                  : (value) => ref
                      .read(forceOfflineProvider.notifier)
                      .setForceOffline(value),
            ),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: isOffline
                    ? null
                    : () async {
                        final count =
                            await ref.read(notesProvider.notifier).sync();
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('$count catatan tersinkron')),
                          );
                        }
                      },
                icon: const Icon(Icons.sync),
                label: const Text('Sync sekarang'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DirtyBadge extends StatelessWidget {
  const _DirtyBadge({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    final color = count == 0 ? Colors.green : Colors.orange;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Row(
        children: [
          Icon(count == 0 ? Icons.cloud_done : Icons.cloud_upload, color: color),
          const SizedBox(width: 12),
          Text(
            'Belum tersinkron: $count',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}

class _NotesList extends StatelessWidget {
  const _NotesList({required this.notes, required this.query});

  final List<Note> notes;
  final String query;

  @override
  Widget build(BuildContext context) {
    if (notes.isEmpty) {
      if (query.isNotEmpty) {
        return Padding(
          padding: const EdgeInsets.only(top: 40, bottom: 20),
          child: Center(
            child: Column(
              children: [
                const Icon(Icons.search_off, size: 48, color: Colors.grey),
                const SizedBox(height: 8),
                Text(
                  'Tidak ada catatan dengan judul "$query"',
                  style: const TextStyle(fontSize: 14, color: Colors.black54),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        );
      }
      return const Padding(
        padding: EdgeInsets.only(top: 48),
        child: Center(child: Text('Belum ada catatan. Tekan + untuk menambah.')),
      );
    }

    final headerText = query.isNotEmpty
        ? 'Hasil pencarian (${notes.length})'
        : 'Catatan tersimpan';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(headerText, style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        ...notes.map((note) => _NoteCard(note: note)),
      ],
    );
  }
}

class _NoteCard extends StatelessWidget {
  const _NoteCard({required this.note});

  final Note note;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: Icon(
          note.dirty ? Icons.cloud_upload : Icons.cloud_done,
          color: note.dirty ? Colors.orange : Colors.green,
        ),
        title: Text(note.title),
        subtitle: Text(note.body.isEmpty ? 'Tanpa isi' : note.body),
        trailing: note.dirty
            ? const Chip(label: Text('Dirty'))
            : const Chip(label: Text('Synced')),
      ),
    );
  }
}

Future<void> _showAddNoteDialog(BuildContext context, WidgetRef ref) async {
  final titleController = TextEditingController();
  final bodyController = TextEditingController();

  await showDialog<void>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: const Text('Tambah catatan'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: titleController,
            autofocus: true,
            decoration: const InputDecoration(labelText: 'Judul'),
          ),
          TextField(
            controller: bodyController,
            decoration: const InputDecoration(labelText: 'Isi'),
            maxLines: 3,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(dialogContext),
          child: const Text('Batal'),
        ),
        FilledButton(
          onPressed: () async {
            final title = titleController.text.trim();
            if (title.isEmpty) return;
            await ref.read(notesProvider.notifier).addNote(
                  title: title,
                  body: bodyController.text.trim(),
                );
            if (dialogContext.mounted) Navigator.pop(dialogContext);
          },
          child: const Text('Simpan'),
        ),
      ],
    ),
  );
  titleController.dispose();
  bodyController.dispose();
}
