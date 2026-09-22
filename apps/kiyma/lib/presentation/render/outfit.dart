/// What the people at the counter are wearing.
///
/// Every one of the fourteen used to wear the same shirt: one collar, one
/// placket, three buttons, and a colour rolled off the seed. Fourteen
/// silhouettes in one garment is not fourteen people, it is one person in
/// fourteen colours — and standing next to an usta with an apron, a towel and
/// a collar of his own, it showed.
///
/// So the garment is its own axis now. The body outline does not change: a
/// shirt and a hoodie are the same torso with different things drawn on it,
/// which is what keeps the silhouette readable at 102 px and the arms
/// attached where they were.
///
/// Patterns are clipped to that outline with `Path.combine` rather than drawn
/// inside a guess at where the edge is. It is done once, when the figure's
/// parts are built, so a striped shirt costs a stripe-shaped path per figure
/// and nothing per frame.
library;

import 'dart:ui';

import 'package:kiyma/presentation/render/figure.dart';

/// The cut. Shape only — every colour is rolled per customer.
enum Kiyafet {
  /// Collar, placket, three buttons. The one everybody used to wear.
  gomlek,

  /// Round neck, nothing else. The plainest thing a person can have on, and
  /// the one that lets a pattern do all the talking.
  tisort,

  /// A waistcoat over a shirt.
  yelek,

  /// A hoodie: the hood bunched behind the neck, a kangaroo pocket, two
  /// drawstrings. The hood is what makes it read from across the room.
  kapsonlu,

  /// A cardigan, open, over whatever is underneath.
  hirka,

  /// A jacket with lapels.
  ceket,

  /// Shirt and tie.
  kravat,

  /// A tracksuit: zip to the throat, a stripe down each side.
  esofman,

  /// Dungarees: a bib and two straps over a tee.
  tulum,

  /// A scoop neck.
  bluz,

  /// A short placket and a small collar.
  polo,

  /// A jumper: a thick ribbed collar and a ribbed hem, no opening at all.
  kazak,
}

/// What is printed on it.
enum Desen {
  yok,

  /// Bands across. Four of them, thick enough to read at this size.
  cizgili,

  /// Check: bands both ways, the crossings darker because two thicknesses of
  /// cloth are.
  ekose,

  /// Small dots, scattered rather than gridded — a grid reads as a fabric
  /// sample and a scatter reads as a print.
  benekli,

  /// One round patch on the chest. A child's t-shirt has a thing on it.
  baski,
}

/// Where the torso ends. Everything below is behind the counter.
const _alt = 142.0;

/// Builds the clothes.
///
/// `govde` is the body outline the rest of the rig already built; it is the
/// clip for every pattern. `arka` takes what belongs *behind* the figure — a
/// hood is the only one so far, and it has to go under the head.
({List<Sekil> arka, List<Sekil> on}) kiyafetParcalari({
  required Kiyafet kesim,
  required Desen desen,
  required List<Offset> govde,
  required double oy,
  required double omuzYari,
  required double altYari,
  required double boyunYari,
}) {
  final arka = <Sekil>[];
  final on = <Sekil>[];
  final govdeYolu = yoldan(govde);

  switch (kesim) {
    case Kiyafet.gomlek:
      for (final s in const [-1.0, 1.0]) {
        on.add(sekil(yakaSekli(oy, boyunYari, s), 'govdeK', ince));
      }
      on.add(sekil(_pat(oy), 'govdeG', ince));
      for (var i = 0; i < 3; i++) {
        on.add(sekil(elips(cx, oy + 27 + i * 18, 2, 2), 'govdeK', ince));
      }

    case Kiyafet.tisort:
      on.add(sekil(_yakaBandi(oy, boyunYari, 5.5), 'govdeG', ince));

    case Kiyafet.yelek:
      for (final s in const [-1.0, 1.0]) {
        on.add(sekil(yakaSekli(oy, boyunYari, s), 'govdeK', ince));
      }
      for (final s in const [-1.0, 1.0]) {
        final k = _yelekKanat(oy, omuzYari, altYari, s);
        on.add(sekil(k, 'yelek', orta));
        if (s > 0) {
          on.add(
            sekil(hilal(k, a0: -72, a1: 62, kalinlik: .24), 'yelekG', yok),
          );
        }
      }

    case Kiyafet.kapsonlu:
      // Behind, and wide: a hood lying on the shoulders is a roll of cloth
      // thicker than the neck it came off. Drawn in front it covered the
      // jaw.
      // The same cloth as the hoodie, not a second colour: as its own tone
      // it read as a grey wig behind his ears rather than as his own hood.
      arka.add(sekil(_kapson(oy, omuzYari), 'govdeG', orta));
      on
        // A darker shade of the same cloth, not the second garment colour:
        // rolled independently the ribbing came out purple on a grey hoodie.
        ..add(sekil(_yakaBandi(oy, boyunYari, 7), 'govdeK', ince))
        // The pocket: one band with two openings, which is one shape and
        // reads as a pocket because of where it sits.
        ..add(sekil(_cep(oy, altYari), 'govdeK', ince));
      for (final s in const [-1.0, 1.0]) {
        on.add(sekil(_ip(oy, s), 'govdeK', ince));
      }

    case Kiyafet.hirka:
      for (final s in const [-1.0, 1.0]) {
        final k = _hirkaKanat(oy, omuzYari, altYari, s);
        on.add(sekil(k, 'yelek', orta));
        if (s > 0) {
          on.add(
            sekil(hilal(k, a0: -72, a1: 62, kalinlik: .22), 'yelekG', yok),
          );
        }
      }
      for (var i = 0; i < 3; i++) {
        on.add(sekil(elips(cx + 11, oy + 34 + i * 20, 2, 2), 'yelekG', ince));
      }

    case Kiyafet.ceket:
      for (final s in const [-1.0, 1.0]) {
        final k = _ceketKanat(oy, omuzYari, altYari, s);
        on
          ..add(sekil(k, 'yelek', orta))
          ..add(sekil(_yaka2(oy, boyunYari, s), 'yelekG', ince));
      }
      on.add(sekil(_gogusCebi(oy, altYari), 'yelekG', ince));

    case Kiyafet.kravat:
      for (final s in const [-1.0, 1.0]) {
        on.add(sekil(yakaSekli(oy, boyunYari, s), 'govdeK', ince));
      }
      on
        ..add(sekil(_kravatDugum(oy), 'yelek', ince))
        ..add(sekil(_kravat(oy), 'yelek', orta))
        ..add(sekil(hilal(_kravat(oy)), 'yelekG', yok));

    case Kiyafet.esofman:
      on
        ..add(sekil(_fermuarYaka(oy, boyunYari), 'yelekG', ince))
        ..add(sekil(_fermuar(oy), 'govdeK', yok));
      for (final s in const [-1.0, 1.0]) {
        on.add(
          sekilYol(
            _kirp(govdeYolu, yoldan(_yanSerit(oy, omuzYari, altYari, s))),
            'yelek',
            yok,
          ),
        );
      }

    case Kiyafet.tulum:
      on.add(sekil(_yakaBandi(oy, boyunYari, 5.5), 'govdeG', ince));
      on.add(sekil(_onluk(oy, altYari), 'yelek', orta));
      for (final s in const [-1.0, 1.0]) {
        on
          ..add(sekil(_aski(oy, omuzYari, s), 'yelek', orta))
          ..add(sekil(elips(cx + s * 13, oy + 26, 2.4, 2.4), 'yelekG', ince));
      }

    case Kiyafet.bluz:
      on
        ..add(sekil(_scoop(oy, boyunYari), 'ten', orta))
        ..add(sekil(_scoopKenar(oy, boyunYari), 'govdeG', ince));

    case Kiyafet.polo:
      for (final s in const [-1.0, 1.0]) {
        on.add(sekil(_poloYaka(oy, boyunYari, s), 'govdeK', ince));
      }
      on.add(sekil(_kisaPat(oy), 'govdeG', ince));
      for (var i = 0; i < 2; i++) {
        on.add(sekil(elips(cx, oy + 22 + i * 11, 1.9, 1.9), 'govdeK', ince));
      }

    case Kiyafet.kazak:
      on
        ..add(sekil(_kazakYaka(oy, boyunYari), 'govdeG', orta))
        ..add(
          sekilYol(_kirp(govdeYolu, yoldan(_etek(altYari))), 'govdeG', yok),
        );
  }

  // The pattern goes on last and under nothing: it is printed on the cloth,
  // so it has to be over the body's own shading and under the trim that sits
  // on top of the cloth. Inserted at the front of `on` is exactly that.
  final desenler = _desenler(desen, govdeYolu, oy, altYari);
  return (arka: arka, on: [...desenler, ...on]);
}

List<Sekil> _desenler(
  Desen desen,
  Path govde,
  double oy,
  double altYari,
) {
  switch (desen) {
    case Desen.yok:
      return const [];

    case Desen.cizgili:
      return [
        for (var i = 0; i < 4; i++)
          sekilYol(
            _kirp(
              govde,
              yoldan([
                Offset(cx - 60, oy + 12 + i * 26),
                Offset(cx + 60, oy + 12 + i * 26),
                Offset(cx + 60, oy + 25 + i * 26),
                Offset(cx - 60, oy + 25 + i * 26),
              ]),
            ),
            'govdeG',
            yok,
          ),
      ];

    case Desen.ekose:
      return [
        for (var i = 0; i < 3; i++)
          sekilYol(
            _kirp(
              govde,
              yoldan([
                Offset(cx - 60, oy + 16 + i * 34),
                Offset(cx + 60, oy + 16 + i * 34),
                Offset(cx + 60, oy + 24 + i * 34),
                Offset(cx - 60, oy + 24 + i * 34),
              ]),
            ),
            'govdeG',
            yok,
          ),
        for (var i = -2; i <= 2; i++)
          sekilYol(
            _kirp(
              govde,
              yoldan([
                Offset(cx + i * 17 - 4, oy - 20),
                Offset(cx + i * 17 + 4, oy - 20),
                const Offset(0, _alt) + Offset(cx + i * 17 + 4, 0),
                const Offset(0, _alt) + Offset(cx + i * 17 - 4, 0),
              ]),
            ),
            'govdeG',
            yok,
          ),
      ];

    case Desen.benekli:
      return [
        for (var i = 0; i < 14; i++)
          sekilYol(
            _kirp(
              govde,
              yoldan(
                elips(
                  cx + _dagilim(i * 3) * altYari * 1.7 - altYari * .85,
                  oy + 6 + _dagilim(i * 3 + 1) * 100,
                  2.6,
                  2.6,
                ),
              ),
            ),
            'govdeG',
            yok,
          ),
      ];

    case Desen.baski:
      return [
        sekilYol(
          _kirp(govde, yoldan(elips(cx, oy + 42, 15, 15))),
          'yelek',
          yok,
        ),
        sekilYol(
          _kirp(govde, yoldan(elips(cx, oy + 42, 7.5, 7.5))),
          'govde',
          yok,
        ),
      ];
  }
}

/// Deterministic scatter, so a dotted blouse does not reshuffle its own dots.
double _dagilim(int i) {
  final x = (i * 12.9898 + 4.1).remainder(6.2831853);
  final v = (x * 43758.5453).remainder(1);
  return v < 0 ? v + 1 : v;
}

Path _kirp(Path govde, Path parca) =>
    Path.combine(PathOperation.intersect, govde, parca);

// --- necklines ------------------------------------------------------------

/// A round neck, as a band rather than a line: a stroke has no thickness to
/// take a colour, and the hem of a t-shirt is the only thing that says it is
/// a t-shirt.
List<Offset> _yakaBandi(double oy, double b, double kalin) {
  final dis = <Offset>[
    ...bez(
      Offset(cx - b - 1, oy - 6),
      Offset(cx - b * .7, oy + 9),
      Offset(cx + b * .7, oy + 9),
      Offset(cx + b + 1, oy - 6),
    ),
  ];
  final ic = <Offset>[
    ...bez(
      Offset(cx + b + 1 - kalin * .5, oy - 6),
      Offset(cx + b * .7, oy + 9 - kalin),
      Offset(cx - b * .7, oy + 9 - kalin),
      Offset(cx - b - 1 + kalin * .5, oy - 6),
    ),
  ];
  return [...dis, ...ic];
}

/// The blouse's scoop: wide and shallow, and the skin inside it is the shape,
/// not a hole — a hole would have to be cut out of the body and the body is
/// one silhouette on purpose.
List<Offset> _scoop(double oy, double b) => [
  Offset(cx - b - 4, oy - 7),
  ...bez(
    Offset(cx - b - 4, oy - 7),
    Offset(cx - b * .8, oy + 14),
    Offset(cx + b * .8, oy + 14),
    Offset(cx + b + 4, oy - 7),
  ),
];

List<Offset> _scoopKenar(double oy, double b) {
  final dis = bez(
    Offset(cx - b - 4, oy - 7),
    Offset(cx - b * .8, oy + 14),
    Offset(cx + b * .8, oy + 14),
    Offset(cx + b + 4, oy - 7),
  );
  final ic = bez(
    Offset(cx + b + 1, oy - 7),
    Offset(cx + b * .78, oy + 10),
    Offset(cx - b * .78, oy + 10),
    Offset(cx - b - 1, oy - 7),
  );
  return [...dis, ...ic];
}

List<Offset> _poloYaka(double oy, double b, double s) => yol(
  Offset(cx + s * b * .5, oy - 7),
  [
    [
      Offset(cx + s * (b + 3), oy - 6),
      Offset(cx + s * (b + 4.5), oy - 2),
      Offset(cx + s * (b + 3.8), oy + 2),
    ],
    [
      Offset(cx + s * (b + 1), oy + 5),
      Offset(cx + s * 4, oy + 7),
      Offset(cx + s * 1.2, oy + 9),
    ],
    [
      Offset(cx + s * 1.2, oy + 5),
      Offset(cx + s * b * .44, oy),
      Offset(cx + s * b * .5, oy - 7),
    ],
  ],
);

List<Offset> _kazakYaka(double oy, double b) {
  // Kept under the shoulder line. Above it the band cleared the body's own
  // top edge and read as a notch cut out of the neck.
  final dis = bez(
    Offset(cx - b - 1, oy - 6),
    Offset(cx - b * .72, oy + 12),
    Offset(cx + b * .72, oy + 12),
    Offset(cx + b + 1, oy - 6),
  );
  final ic = bez(
    Offset(cx + b - 2.5, oy - 6),
    Offset(cx + b * .58, oy + 5),
    Offset(cx - b * .58, oy + 5),
    Offset(cx - b + 2.5, oy - 6),
  );
  return [...dis, ...ic];
}

List<Offset> _fermuarYaka(double oy, double b) {
  final dis = bez(
    Offset(cx - b - 2, oy - 11),
    Offset(cx - b * .8, oy + 4),
    Offset(cx + b * .8, oy + 4),
    Offset(cx + b + 2, oy - 11),
  );
  final ic = bez(
    Offset(cx + b - 1.5, oy - 11),
    Offset(cx + b * .66, oy - 2),
    Offset(cx - b * .66, oy - 2),
    Offset(cx - b + 1.5, oy - 11),
  );
  return [...dis, ...ic];
}

List<Offset> _yaka2(double oy, double b, double s) => yol(
  Offset(cx + s * 1.5, oy + 2),
  [
    [
      Offset(cx + s * (b * .4), oy - 5),
      Offset(cx + s * (b + 2), oy - 7),
      Offset(cx + s * (b + 6), oy - 6),
    ],
    [
      Offset(cx + s * (b + 5), oy + 6),
      Offset(cx + s * (b - 1), oy + 16),
      Offset(cx + s * 2.4, oy + 26),
    ],
    [
      Offset(cx + s * 2, oy + 16),
      Offset(cx + s * 1.6, oy + 8),
      Offset(cx + s * 1.5, oy + 2),
    ],
  ],
);

// --- openings and trim ----------------------------------------------------

List<Offset> _pat(double oy) => [
  Offset(cx - 3.6, oy + 13),
  Offset(cx + 3.6, oy + 13),
  const Offset(cx + 3.9, _alt),
  const Offset(cx - 3.9, _alt),
];

List<Offset> _kisaPat(double oy) => [
  Offset(cx - 3.4, oy + 10),
  Offset(cx + 3.4, oy + 10),
  Offset(cx + 3.6, oy + 40),
  Offset(cx - 3.6, oy + 40),
];

List<Offset> _fermuar(double oy) => [
  Offset(cx - 1.8, oy - 6),
  Offset(cx + 1.8, oy - 6),
  const Offset(cx + 1.8, _alt),
  const Offset(cx - 1.8, _alt),
];

/// The drawstring: a short cord with a knot on the end, one each side of the
/// throat. Two lines and two dots, and without them a hoodie is a jumper.
List<Offset> _ip(double oy, double s) => [
  ...serit(
    [
      Offset(cx + s * 4.5, oy + 4),
      Offset(cx + s * 6, oy + 16),
      Offset(cx + s * 5, oy + 27),
    ],
    1.9,
    1.6,
  ),
];

List<Offset> _cep(double oy, double altYari) => yol(
  Offset(cx - altYari * .62, oy + 62),
  [
    [
      Offset(cx - altYari * .66, oy + 74),
      Offset(cx - altYari * .60, oy + 84),
      Offset(cx - altYari * .46, oy + 86),
    ],
    [
      Offset(cx - 10, oy + 88),
      Offset(cx + 10, oy + 88),
      Offset(cx + altYari * .46, oy + 86),
    ],
    [
      Offset(cx + altYari * .60, oy + 84),
      Offset(cx + altYari * .66, oy + 74),
      Offset(cx + altYari * .62, oy + 62),
    ],
    [
      Offset(cx + altYari * .40, oy + 68),
      Offset(cx - altYari * .40, oy + 68),
      Offset(cx - altYari * .62, oy + 62),
    ],
  ],
);

List<Offset> _gogusCebi(double oy, double altYari) => [
  Offset(cx + altYari * .30, oy + 30),
  Offset(cx + altYari * .66, oy + 30),
  Offset(cx + altYari * .64, oy + 46),
  Offset(cx + altYari * .32, oy + 46),
];

List<Offset> _etek(double altYari) => [
  Offset(cx - altYari - 4, _alt - 16),
  Offset(cx + altYari + 4, _alt - 16),
  Offset(cx + altYari + 4, _alt),
  Offset(cx - altYari - 4, _alt),
];

List<Offset> _yanSerit(double oy, double omuzYari, double altYari, double s) =>
    [
      Offset(cx + s * (omuzYari - 4), oy + 14),
      Offset(cx + s * (omuzYari + 2), oy + 14),
      Offset(cx + s * (altYari + 2), _alt),
      Offset(cx + s * (altYari - 4), _alt),
    ];

// --- the tie --------------------------------------------------------------

List<Offset> _kravatDugum(double oy) => [
  Offset(cx - 4.6, oy + 9),
  Offset(cx + 4.6, oy + 9),
  Offset(cx + 3.6, oy + 19),
  Offset(cx - 3.6, oy + 19),
];

List<Offset> _kravat(double oy) => yol(
  Offset(cx - 3.4, oy + 19),
  [
    [
      Offset(cx - 5.4, oy + 40),
      Offset(cx - 6.4, oy + 58),
      Offset(cx, oy + 70),
    ],
    [
      Offset(cx + 6.4, oy + 58),
      Offset(cx + 5.4, oy + 40),
      Offset(cx + 3.4, oy + 19),
    ],
  ],
);

// --- the outer layers -----------------------------------------------------

List<Offset> _yelekKanat(
  double oy,
  double omuzYari,
  double altYari,
  double s,
) => [
  ...yol(Offset(cx + s * 7.5, oy - 3), [
    [
      Offset(cx + s * 20, oy + 1),
      Offset(cx + s * (omuzYari - 3.5), oy + 7),
      Offset(cx + s * (omuzYari - 1.6), oy + 18),
    ],
    [
      Offset(cx + s * (omuzYari + 1), oy + 30),
      Offset(cx + s * (altYari - 2.4), _alt - 28),
      Offset(cx + s * (altYari - .6), _alt),
    ],
  ]),
  Offset(cx + s * 9.5, _alt),
  ...bez(
    Offset(cx + s * 9.5, _alt),
    Offset(cx + s * 10, _alt - 30),
    Offset(cx + s * 9.2, oy + 16),
    Offset(cx + s * 7.5, oy - 3),
  ),
];

/// A cardigan: the same panel, softer at the throat and cut away at the hem,
/// so it hangs open rather than buttoning like a waistcoat.
List<Offset> _hirkaKanat(
  double oy,
  double omuzYari,
  double altYari,
  double s,
) => [
  ...yol(Offset(cx + s * 10, oy - 5), [
    [
      Offset(cx + s * 22, oy - 2),
      Offset(cx + s * (omuzYari - 2), oy + 6),
      Offset(cx + s * (omuzYari + .4), oy + 20),
    ],
    [
      Offset(cx + s * (omuzYari + 2), oy + 32),
      Offset(cx + s * (altYari - 1), _alt - 26),
      Offset(cx + s * altYari, _alt),
    ],
  ]),
  Offset(cx + s * 13, _alt),
  ...bez(
    Offset(cx + s * 13, _alt),
    Offset(cx + s * 15, _alt - 34),
    Offset(cx + s * 13, oy + 20),
    Offset(cx + s * 10, oy - 5),
  ),
];

/// A jacket: squarer at the shoulder than a cardigan and standing further off
/// the body, because it has a lining and a cardigan does not.
List<Offset> _ceketKanat(
  double oy,
  double omuzYari,
  double altYari,
  double s,
) => [
  ...yol(Offset(cx + s * 2.4, oy + 26), [
    [
      Offset(cx + s * 12, oy + 4),
      Offset(cx + s * (omuzYari - 4), oy + 2),
      Offset(cx + s * (omuzYari + 1), oy + 16),
    ],
    [
      Offset(cx + s * (omuzYari + 3), oy + 30),
      Offset(cx + s * (altYari + .5), _alt - 26),
      Offset(cx + s * (altYari + 1.5), _alt),
    ],
  ]),
  Offset(cx + s * 8, _alt),
  ...bez(
    Offset(cx + s * 8, _alt),
    Offset(cx + s * 9, _alt - 36),
    Offset(cx + s * 5, oy + 46),
    Offset(cx + s * 2.4, oy + 26),
  ),
];

/// The hood, lying on the shoulders. Drawn behind everything, and wider than
/// the neck it came off: cloth bunches.
List<Offset> _kapson(double oy, double omuzYari) => yol(
  // Wider than the head it sits behind, or none of it shows: the head is
  // drawn over this and a hood the width of the neck is a hood nobody sees.
  Offset(cx - omuzYari * 1.12, oy + 10),
  [
    [
      Offset(cx - omuzYari * 1.22, oy - 8),
      Offset(cx - omuzYari * .80, oy - 22),
      Offset(cx, oy - 24),
    ],
    [
      Offset(cx + omuzYari * .80, oy - 22),
      Offset(cx + omuzYari * 1.22, oy - 8),
      Offset(cx + omuzYari * 1.12, oy + 10),
    ],
    [
      Offset(cx + omuzYari * .50, oy + 18),
      Offset(cx - omuzYari * .50, oy + 18),
      Offset(cx - omuzYari * 1.16, oy + 8),
    ],
  ],
);

List<Offset> _onluk(double oy, double altYari) => [
  Offset(cx - altYari * .52, oy + 30),
  Offset(cx + altYari * .52, oy + 30),
  const Offset(0, _alt) + Offset(cx + altYari * .74, 0),
  const Offset(0, _alt) + Offset(cx - altYari * .74, 0),
];

List<Offset> _aski(double oy, double omuzYari, double s) => serit(
  [
    Offset(cx + s * (omuzYari - 9), oy - 4),
    Offset(cx + s * (omuzYari - 13), oy + 14),
    Offset(cx + s * 13, oy + 30),
  ],
  7,
  6,
);
