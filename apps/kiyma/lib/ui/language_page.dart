import 'package:auto_route/auto_route.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:kiyma/config/injectable.dart';
import 'package:kiyma/infrastructure/language_choice.dart';
import 'package:kiyma/route/app_router.gr.dart';
import 'package:kiyma/ui/brand.dart';
import 'package:kiyma/ui/palette.dart';

/// Asked once, on a device that has never answered. Nothing is stored by
/// hand: easy_localization persists `setLocale`, and the absence of that
/// value is what routes anybody here.
@RoutePage()
class LanguagePage extends StatefulWidget {
  const LanguagePage({this.firstRun = true, super.key});

  /// On the first run this replaces itself with the menu; otherwise closes.
  final bool firstRun;

  @override
  State<LanguagePage> createState() => _LanguagePageState();
}

class _LanguagePageState extends State<LanguagePage> {
  static const _languages = {'tr': 'Türkçe', 'en': 'English'};

  late String _picked = context.locale.languageCode;

  Future<void> _confirm() async {
    await context.setLocale(Locale(_picked));
    await getIt<LanguageChoice>().record();
    if (!mounted) return;
    if (widget.firstRun) {
      await context.router.replaceAll([const MenuRoute()]);
    } else {
      await context.router.maybePop();
    }
  }

  @override
  Widget build(BuildContext context) => BrandBackground(
    child: Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: BrandCard(
          width: 380,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Dil / Language',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Rubik',
                  fontSize: 19,
                  fontWeight: FontWeight.w700,
                  color: KiymaPalette.komur,
                ),
              ),
              const SizedBox(height: 16),
              for (final entry in _languages.entries)
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: _LanguageRow(
                    code: entry.key,
                    name: entry.value,
                    selected: _picked == entry.key,
                    onTap: () => setState(() => _picked = entry.key),
                  ),
                ),
              const SizedBox(height: 8),
              ChunkyButton(label: 'dil.devam'.tr(), onPressed: _confirm),
            ],
          ),
        ),
      ),
    ),
  );
}

class _LanguageRow extends StatelessWidget {
  const _LanguageRow({
    required this.code,
    required this.name,
    required this.selected,
    required this.onTap,
  });

  final String code;
  final String name;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Material(
    color: Colors.transparent,
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: KiymaPalette.ahsap.withValues(alpha: selected ? 0.14 : 0.06),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected
                ? KiymaPalette.ates
                : KiymaPalette.ahsap.withValues(alpha: 0.3),
            width: selected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            // Not a flag: emoji flags differ per platform and English has
            // no one country.
            Container(
              width: 34,
              height: 34,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: KiymaPalette.krema,
                shape: BoxShape.circle,
                border: Border.all(color: KiymaPalette.komur, width: 2),
              ),
              child: Text(
                code.toUpperCase(),
                style: const TextStyle(
                  fontFamily: 'Rubik',
                  fontWeight: FontWeight.w900,
                  fontSize: 12,
                  color: KiymaPalette.komur,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                name,
                style: const TextStyle(
                  fontFamily: 'Rubik',
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: KiymaPalette.komur,
                ),
              ),
            ),
            Icon(
              selected ? Icons.check_circle : Icons.circle_outlined,
              color: selected ? KiymaPalette.ates : KiymaPalette.ahsap,
            ),
          ],
        ),
      ),
    ),
  );
}
