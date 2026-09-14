import 'dart:math';

import 'package:flutter_test/flutter_test.dart';

import 'package:ai_verification/pages/stats_page.dart';

// Random deterministik ini membuat test dapat memilih hasil sukses atau gagal.
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
  test('notifier mengembalikan tiga statistik saat berhasil', () async {
    // Delay nol membuat unit test cepat tanpa mengubah delay produksi.
    final notifier = StatsNotifier(
      random: FixedRandom(0.5),
      delay: Duration.zero,
    );
    final stats = await notifier.build();

    expect(stats, hasLength(3));
    expect(stats.first, contains('Total pengguna'));
  });

  test('notifier menjadi error ketika simulasi server gagal', () async {
    // Nilai 0.2 berada di bawah ambang kegagalan 30 persen.
    final notifier = StatsNotifier(
      random: FixedRandom(0.2),
      delay: Duration.zero,
    );

    // Future build meneruskan exception dari simulasi server.
    try {
      await notifier.build();
      fail('Provider seharusnya menghasilkan error');
    } catch (error) {
      expect(error, isA<Exception>());
    }
  });
}
