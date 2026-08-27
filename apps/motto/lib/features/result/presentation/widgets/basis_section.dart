import 'package:flutter/material.dart';

/// What this is built on, in the open. Never behind a paywall: a claim you
/// have to pay to check is not one.
///
/// "Uyarlanmıştır", not "doğrulanmıştır" — items translated for this app are
/// not a validated Turkish instrument.
class BasisSection extends StatelessWidget {
  const BasisSection({super.key});

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;

    return Theme(
      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
      child: ExpansionTile(
        tilePadding: EdgeInsets.zero,
        childrenPadding: const EdgeInsets.only(bottom: 8),
        title: Text('Bu neye dayanıyor?', style: text.titleMedium),
        children: [
          Text(
            'Sorular, kamuya açık IPIP madde havuzundan Türkçeye '
            'uyarlanmıştır. Cevapların beş eğilim ekseninde bir profil '
            'oluşturur; arketip, o profilin en yakın düştüğü tanıma verilen '
            'addır.',
            style: text.bodyMedium?.copyWith(color: scheme.onSurfaceVariant),
          ),
          const SizedBox(height: 16),
          Text(
            'Sınırlılıklar: kısa form düşük çözünürlüklüdür, kendi kendini '
            'bildirme yanlılığı taşır ve arketip sınırları keskin değildir. '
            'Arketip adı bilimsel bir kategori değil, editöryal bir yorumdur.',
            style: text.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}
