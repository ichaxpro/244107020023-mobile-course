import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:week3_todo/pages/stats_page.dart';
import 'package:week3_todo/providers/stats_provider.dart';
import 'package:week3_todo/main.dart';

class FixedRandom implements Random {
  FixedRandom(this.value);

  final double value;

  @override
  bool nextBool() => value >= 0.5;

  @override
  double nextDouble() => value;

  @override
  int nextInt(int max) => (value * max).floor();
}

void main() {
  testWidgets('menambah tugas baru', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: MyApp()));
    expect(find.text('Belum ada tugas'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.add));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), 'Kerjakan PR minggu 3');
    await tester.tap(find.text('Tambah'));
    await tester.pumpAndSettle();

    expect(find.text('Kerjakan PR minggu 3'), findsOneWidget);
  });

  testWidgets('menampilkan statistik setelah pengambilan data berhasil', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          statsProvider.overrideWith(
            () => StatsNotifier(random: FixedRandom(0.5), delay: Duration.zero),
          ),
        ],
        child: const MaterialApp(home: StatsPage()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Total tugas: 0'), findsOneWidget);
    expect(find.text('Tugas selesai: 0'), findsOneWidget);
    expect(find.text('Belum selesai: 0'), findsOneWidget);
  });
}
