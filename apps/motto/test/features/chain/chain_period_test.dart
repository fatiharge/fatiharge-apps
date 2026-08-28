import 'package:flutter_test/flutter_test.dart';
import 'package:motto/features/chain/domain/chain.dart';

void main() {
  // The product is fourteen days. Before this the fifteenth silently became
  // the first again, so nothing ever finished.
  test('a chain carries which run it is on', () {
    const chain = Chain(period: 2, mottoId: 'qb3', periodDone: true);

    expect(chain.period, 2);
    expect(chain.mottoId, 'qb3');
    expect(chain.periodDone, isTrue);
  });

  test('a fresh chain is on its first run, under no chosen motto', () {
    const chain = Chain();

    expect(chain.period, 1);
    expect(chain.mottoId, isNull);
    expect(chain.periodDone, isFalse);
  });
}
