import 'package:hive_ce_flutter/hive_flutter.dart';
import 'package:wallet/infrastructure/storage/wallet_storage.dart';

/// A typed, stream-backed view over one Hive box.
///
/// Exists so the three repositories do not each re-implement "read every
/// record, decode it, and re-emit whenever the box changes".
class HiveCollection<T> {
  const HiveCollection({
    required this.box,
    required this.decode,
    required this.encode,
    required this.idOf,
  });

  final Box<HiveRecord> box;
  final T Function(Map<String, dynamic> record) decode;
  final Map<String, dynamic> Function(T item) encode;
  final String Function(T item) idOf;

  /// Current contents, then a fresh list on every change.
  ///
  /// The first value is emitted synchronously-ish so a listener never has to
  /// render an empty screen while waiting for the first write.
  Stream<List<T>> watchAll() async* {
    yield readAll();
    yield* box.watch().map((_) => readAll());
  }

  List<T> readAll() => box.values
      .map((record) => decode(record.cast<String, dynamic>()))
      .toList();

  T? read(String id) {
    final record = box.get(id);
    return record == null ? null : decode(record.cast<String, dynamic>());
  }

  Future<void> put(T item) => box.put(idOf(item), encode(item));

  Future<void> putAll(Iterable<T> items) => box.putAll(<String, HiveRecord>{
    for (final item in items) idOf(item): encode(item),
  });

  Future<void> delete(String id) => box.delete(id);

  bool get isEmpty => box.isEmpty;
}
