import 'package:auto_route/auto_route.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kiyma/application/kiyma_cubit.dart';
import 'package:kiyma/config/injectable.dart';
import 'package:kiyma/domain/day_rule.dart';
import 'package:kiyma/domain/model/customer_kind.dart';
import 'package:kiyma/domain/run_summary.dart';
import 'package:kiyma/domain/tempo.dart';
import 'package:kiyma/domain/trade_shape.dart';
import 'package:kiyma/domain/unlocks.dart';
import 'package:kiyma/presentation/brand.dart';
import 'package:kiyma/presentation/palette.dart';

/// Everything the game will not stop to explain twice.
///
/// The usta says each thing once, on the run where it first matters, and
/// then the run carries on. That is right for teaching and wrong for
/// remembering: a player on day fourteen who has forgotten what a fussy
/// customer does has nowhere to look. This is the nowhere.
///
/// It reads out of the same strings the game itself uses, so there is no
/// second copy of any rule to fall out of step with the first — and nothing
/// here decides anything, which is why it can be a page of words.
@RoutePage()
class WikiPage extends StatelessWidget {
  const WikiPage({super.key});

  @override
  Widget build(BuildContext context) => BlocProvider(
    create: (_) => getIt<KiymaCubit>(),
    child: BrandBackground(
      child: BlocBuilder<KiymaCubit, KiymaState>(
        builder: (context, state) => Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 8, 20, 8),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_rounded),
                    color: KiymaPalette.komur,
                    onPressed: () => context.router.maybePop(),
                  ),
                  Expanded(
                    child: Text(
                      'defter.baslik'.tr(),
                      style: const TextStyle(
                        fontFamily: 'Rubik',
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: KiymaPalette.komur,
                      ),
                    ),
                  ),
                  BrandChip(label: 'hud.gun'.tr(args: ['${state.gun}'])),
                ],
              ),
            ),
            Expanded(
              child: Builder(
                builder: (context) {
                  final unlocks = context.read<KiymaCubit>().progress.unlocks;
                  return ListView(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                    children: [
                      _Bolum(
                        'defter.musteriler',
                        [
                          for (final tip in CustomerKind.values)
                            _Satir(
                              baslik: 'musteri.${tip.name}'.tr(),
                              metin: 'musteri.${tip.name}_ne'.tr(),
                              // A type nobody has met yet is a reason to keep
                              // playing, so it is listed with the day it starts
                              // rather than hidden.
                              kilit: state.gun < tip.gun
                                  ? 'defter.gun_kilidi'.tr(args: ['${tip.gun}'])
                                  : null,
                            ),
                        ],
                      ),
                      _Bolum('defter.gunler', [
                        for (final gidis in [
                          TradeShape.duz,
                          ...TradeShape.dongu,
                        ])
                          _Satir(
                            baslik: 'gidis.${gidis.ad}'.tr(),
                            metin: 'gidis_ne.${gidis.ad}'.tr(),
                          ),
                      ]),
                      _Bolum('defter.kurallar', [
                        for (final kural in DayRule.dongu)
                          _Satir(
                            baslik: 'kural.${kural.id}'.tr(),
                            metin: 'kural.${kural.id}_ne'.tr(),
                          ),
                      ]),
                      _Bolum('defter.tempo', [
                        for (final hal in TempoBand.values)
                          _Satir(
                            baslik: 'tempo.${hal.name}'.tr(),
                            metin: 'tempo_ne.${hal.name}'.tr(),
                          ),
                      ]),
                      _Bolum('defter.rozetler', [
                        for (final rozet in DayBadge.values)
                          _Satir(
                            baslik: 'rozet.${rozet.name}'.tr(),
                            metin: 'rozet_ne.${rozet.name}'.tr(),
                          ),
                      ]),
                      _Bolum('defter.tezgah', [
                        for (final grup in UnlockGroup.values)
                          _Satir(
                            baslik: 'grup.${grup.id}'.tr(),
                            metin: 'grup.${grup.id}_ne'.tr(),
                            sayac:
                                '${unlocks.kademe(grup)}'
                                '/${Unlocks.kademeler(grup).length}',
                          ),
                      ]),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

class _Bolum extends StatelessWidget {
  const _Bolum(this.baslik, this.satirlar);

  final String baslik;
  final List<Widget> satirlar;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 18),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Text(
            baslik.tr(),
            style: const TextStyle(
              fontFamily: 'Rubik',
              fontSize: 16,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.3,
              color: KiymaPalette.ates,
            ),
          ),
        ),
        ...satirlar,
      ],
    ),
  );
}

class _Satir extends StatelessWidget {
  const _Satir({
    required this.baslik,
    required this.metin,
    this.sayac,
    this.kilit,
  });

  final String baslik;
  final String metin;

  /// How far up a ladder the counter is, where the row is one.
  final String? sayac;

  /// What is still in front of this, if anything.
  final String? kilit;

  @override
  Widget build(BuildContext context) => Opacity(
    opacity: kilit == null ? 1 : 0.55,
    child: Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: KiymaPalette.krema,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: KiymaPalette.komur.withValues(alpha: 0.25),
          width: 2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  baslik,
                  style: const TextStyle(
                    fontFamily: 'Rubik',
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: KiymaPalette.komur,
                  ),
                ),
              ),
              if (sayac case final sayac?)
                Text(
                  sayac,
                  style: const TextStyle(
                    fontFamily: 'Rubik',
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: KiymaPalette.celik,
                  ),
                ),
              if (kilit case final kilit?)
                Text(
                  kilit,
                  style: const TextStyle(
                    fontFamily: 'Rubik',
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: KiymaPalette.celik,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 3),
          Text(
            metin,
            style: const TextStyle(
              fontFamily: 'Rubik',
              fontSize: 13,
              height: 1.3,
              fontWeight: FontWeight.w600,
              color: KiymaPalette.celik,
            ),
          ),
        ],
      ),
    ),
  );
}
