import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:kiyma/ui/palette.dart';

/// What the two startup jobs are shown behind.
class SplashView extends StatelessWidget {
  const SplashView({required this.progress, super.key});

  final double progress;

  @override
  Widget build(BuildContext context) => ColoredBox(
    color: KiymaPalette.zemin,
    child: Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Kıyma',
            style: TextStyle(
              fontSize: 40,
              fontWeight: FontWeight.w900,
              color: KiymaPalette.kor,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 18),
          SizedBox(
            width: 160,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(3),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 5,
                backgroundColor: const Color(0x33FFFFFF),
                valueColor: const AlwaysStoppedAnimation(KiymaPalette.kor),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'yukleniyor'.tr(),
            style: const TextStyle(fontSize: 12, color: KiymaPalette.soluk),
          ),
        ],
      ),
    ),
  );
}
