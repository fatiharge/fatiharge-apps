import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// The layering, made checkable.
///
/// Nothing in the tree used to say which side of the line a file was on: you
/// had to open it and read its imports. The whole test strategy rests on
/// `DayRun` being engine-free — its own header says so and most of the suite
/// depends on it — and the only thing stopping somebody importing Flame into
/// it tomorrow was that they might remember.
void main() {
  /// Where a layer is allowed to look. Dependencies point inwards:
  /// presentation may know everything, domain may know nothing but itself.
  ///
  /// `route` and `config` are the composition root and are left out — they
  /// exist to be reached for from anywhere, which is what a composition root
  /// is. `infrastructure` may see `presentation` for one reason, named in
  /// `world.dart`: it holds the art bootstrap pre-renders, and a blurred
  /// silhouette is a drawing.
  const crossCutting = {'route', 'config'};
  const allowed = {
    'domain': {'domain'},
    'application': {'domain', 'application', 'infrastructure'},
    'infrastructure': {'domain', 'infrastructure', 'presentation'},
    'presentation': {'domain', 'application', 'infrastructure', 'presentation'},
  };

  /// Packages a layer may not reach for at all.
  const banned = {
    'domain': ['package:flutter/', 'package:flame', 'package:bloc'],
    'application': ['package:flutter/', 'package:flame'],
  };

  final files = Directory('lib')
      .listSync(recursive: true)
      .whereType<File>()
      .where((f) => f.path.endsWith('.dart'))
      .where((f) => !f.path.endsWith('.g.dart'))
      .where((f) => !f.path.endsWith('.gr.dart'))
      .where((f) => !f.path.endsWith('.config.dart'));

  final imports = <String, List<String>>{};
  for (final file in files) {
    imports[file.path] = file
        .readAsLinesSync()
        .where((l) => l.startsWith('import '))
        .toList();
  }

  test('every layer only looks inwards', () {
    final offenders = <String>[];
    for (final entry in imports.entries) {
      final layer = entry.key.split('/')[1];
      final may = allowed[layer];
      if (may == null) continue;
      for (final line in entry.value) {
        final match = RegExp('package:kiyma/([a-z_]+)/').firstMatch(line);
        if (match == null) continue;
        final target = match.group(1)!;
        if (!may.contains(target) && !crossCutting.contains(target)) {
          offenders.add('${entry.key} -> $target');
        }
      }
    }
    expect(offenders, isEmpty);
  });

  test('the rules stay free of the engine and the framework', () {
    final offenders = <String>[];
    for (final entry in imports.entries) {
      final layer = entry.key.split('/')[1];
      for (final package in banned[layer] ?? const <String>[]) {
        for (final line in entry.value) {
          if (line.contains(package)) offenders.add('${entry.key}: $line');
        }
      }
    }
    expect(offenders, isEmpty);
  });

  test('the layers that should exist do, and nothing else', () {
    final dirs = Directory('lib')
        .listSync()
        .whereType<Directory>()
        .map((d) => d.path.split('/').last)
        .toSet();
    expect(dirs, {
      'domain',
      'application',
      'presentation',
      'infrastructure',
      'route',
      'config',
    });
  });
}
