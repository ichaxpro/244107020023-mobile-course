import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Provider ini menjadi satu-satunya sumber state statistik untuk halaman.
final statsProvider = AsyncNotifierProvider<StatsNotifier, List<String>>(
  StatsNotifier.new,
);

// Notifier ini mengelola proses mengambil data dan tiga kemungkinan state UI.
class StatsNotifier extends AsyncNotifier<List<String>> {
  // Random dan delay dapat diganti saat test tanpa mengubah perilaku produksi.
  StatsNotifier({Random? random, Duration? delay})
    : _random = random ?? Random(),
      _delay = delay ?? const Duration(seconds: 2);

  final Random _random;
  final Duration _delay;

  @override
  Future<List<String>> build() async {
    // Delay ini mensimulasikan waktu yang diperlukan untuk menghubungi server.
    await Future<void>.delayed(_delay);

    // Kemungkinan gagal 30% mensimulasikan server atau jaringan bermasalah.
    if (_random.nextDouble() < 0.3) {
      throw Exception('Gagal mengambil data statistik');
    }

    // Data sukses selalu berisi tiga item statistik untuk ditampilkan.
    return [
      'Total pengguna: 1.240',
      'Pesanan hari ini: 86',
      'Pendapatan: Rp12,5 jt',
    ];
  }
}

// Halaman ini membaca state provider dan menampilkan UI sesuai state async.
class StatsPage extends ConsumerWidget {
  const StatsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // watch membuat halaman rebuild ketika loading, error, atau data berubah.
    final statsAsync = ref.watch(statsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Statistik')),
      body: statsAsync.when(
        // Spinner memberi tanda bahwa data sedang diambil.
        loading: () => const Center(child: CircularProgressIndicator()),
        // Pesan error dan tombol retry ditampilkan saat pengambilan gagal.
        error: (error, _) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Gagal memuat statistik: $error'),
              const SizedBox(height: 12),
              FilledButton(
                onPressed: () => ref.invalidate(statsProvider),
                child: const Text('Coba lagi'),
              ),
            ],
          ),
        ),
        // ListView menampilkan tiga item ketika data berhasil diperoleh.
        data: (stats) => ListView.builder(
          itemCount: stats.length,
          itemBuilder: (context, index) => ListTile(
            leading: const Icon(Icons.analytics_outlined),
            title: Text(stats[index]),
          ),
        ),
      ),
    );
  }
}
