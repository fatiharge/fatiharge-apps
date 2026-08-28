import 'package:meta/meta.dart';

@immutable
class MethodSection {
  const MethodSection(this.heading, this.body);

  final String heading;
  final String body;
}

/// What the result is built on, and what it is not. The limitations section is
/// the point of the screen, not an appendix: saying plainly that an archetype
/// is an editorial reading is what keeps this on the right side of 1.4.1.
const methodSections = <MethodSection>[
  MethodSection(
    'Ölçek',
    'Sorular, kamuya açık IPIP madde havuzundan Türkçeye uyarlandı. Beş '
        'boyut ölçülüyor: deneyime açıklık, sorumluluk, dışadönüklük, '
        'uyumluluk ve duygusal denge. Her boyut için dört madde var ve '
        'yarısı ters kodlu — aynı yöne peş peşe onaylamak profili '
        'bozmasın diye.',
  ),
  MethodSection(
    'Uyarlama',
    'Maddeler birebir çevrilmedi. Türkçede karşılığı zorlama duran '
        'ifadeler, aynı davranışı soran günlük cümlelerle değiştirildi. '
        'Bu, uluslararası normlarla karşılaştırma yapılamaması demek; '
        'sonuç kendi içinde tutarlı, dışarıyla kıyaslanabilir değil.',
  ),
  MethodSection(
    'Arketip nasıl seçiliyor',
    'Cevaplar beş boyutlu bir profile dönüşüyor ve bu profil, on sekiz '
        'arketibin her birinin tanımlı noktasına olan uzaklığına göre '
        'eşleşiyor — eşik sırası değil, en yakın nokta. Bu yüzden iki '
        'arketip arasında kalan bir profil, hangi eşiği önce geçtiğine '
        'göre değil, gerçekten hangisine yakın olduğuna göre yerleşiyor.',
  ),
  MethodSection(
    'Sınırlılıklar',
    'Kısa form kaba çözünürlük verir: yirmi madde, bir boyutu birkaç '
        'kademede ayırt eder, daha ince değil.\n\n'
        'Özbildirim yanlıdır. İnsan kendini olduğu gibi değil, o gün '
        'olmak istediği gibi işaretler; ruh hali sonucu kaydırır.\n\n'
        'Arketip sınırları keskin değildir. İki arketip arasında kalan '
        'bir profil için "doğru" cevap yoktur, yakın olan vardır.\n\n'
        'Arketip etiketi bilimsel bir kategori değil, editöryal bir '
        'yorumdur. Beş boyutlu bir profili okunabilir bir isme çeviriyor; '
        'bir teşhis, bir yetenek ölçümü ya da bir kişilik tipi değil.',
  ),
  MethodSection(
    'Kaynaklar',
    'Goldberg, L. R. (1999). A broad-bandwidth, public-domain personality '
        'inventory. International Personality Item Pool — ipip.ori.org.\n\n'
        'John, O. P. & Srivastava, S. (1999). The Big Five trait taxonomy.',
  ),
];
