import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'todo_provider.dart';

final statsProvider = AsyncNotifierProvider<StatsNotifier, List<String>>(
  StatsNotifier.new,
);

class StatsNotifier extends AsyncNotifier<List<String>> {
  StatsNotifier({Random? random, Duration? delay})
    : _random = random ?? Random(),
      _delay = delay ?? const Duration(seconds: 2);

  final Random _random;
  final Duration _delay;

  @override
  Future<List<String>> build() async {
    await Future<void>.delayed(_delay);

    if (_random.nextDouble() < 0.3) {
      throw Exception('Gagal mengambil statistik dari server');
    }

    final todos = ref.watch(todoListProvider);
    final completedCount = todos.where((todo) => todo.done).length;

    return [
      'Total tugas: ${todos.length}',
      'Tugas selesai: $completedCount',
      'Belum selesai: ${todos.length - completedCount}',
    ];
  }
}
