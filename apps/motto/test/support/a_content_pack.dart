/// A content package built here, not read from a file.
///
/// Nothing in this repository holds the product's words — they are rows in the
/// service's database — so a test that needs a package builds one. It is also
/// the honest arrangement: a test asserting on real sentences fails when
/// somebody corrects a typo, and one built to a shape proves the assembler
/// works for any number of archetypes, which is what the shape has to survive.
library;

const packDays = 14;

Map<String, dynamic> aContentPackJson({
  List<String>? ids,
  int archetypes = 3,
  int days = packDays,
  int mottosEach = 4,
  int connectors = 5,
  int fragmentsEach = packDays,
}) {
  final names = ids ?? [for (var i = 1; i <= archetypes; i++) 'arketip_$i'];
  return {
    'version': 'test${names.length}x$days',
    'archetypes': [
      for (final id in names)
        {
          'id': id,
          'name': 'Arketip $id',
          'summary': '$id özeti. Bedeli şu: bir bedel cümlesi.',
          'motto': '$id mottosu',
        },
    ],
    'skeletons': [
      for (var day = 1; day <= days; day++)
        {
          'day': day,
          'title': 'Gün $day başlığı',
          'body': 'Gün $day gövdesi.',
          'action': 'Gün $day eylemi.',
        },
    ],
    'fragments': [
      for (final id in names)
        for (var index = 1; index <= fragmentsEach; index++)
          {'archetypeId': id, 'index': index, 'text': '$id parça $index.'},
    ],
    'connectors': [
      for (var i = 1; i <= connectors; i++) {'id': 'c$i', 'text': 'bağlaç $i'},
    ],
    'mottos': [
      for (final id in names)
        for (var i = 1; i <= mottosEach; i++)
          {
            'id': '${id}_$i',
            'archetypeId': id,
            'motto': '$id motto $i',
            'detail': '$id motto $i ayrıntısı.',
            'reminder': '$id motto $i hatırlatması.',
          },
    ],
  };
}
