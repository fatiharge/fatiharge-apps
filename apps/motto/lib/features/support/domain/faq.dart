import 'package:meta/meta.dart';

/// One question and its answer.
@immutable
class FaqItem {
  const FaqItem(this.id, this.question, this.answer);

  final String id;
  final String question;
  final String answer;
}

/// The questions, answered before they are asked.
///
/// Offline on purpose: the moment someone wonders where their data went they
/// have neither a network guarantee nor patience. Copy rules in
/// `content/README.md` — every answer names the cost rather than working
/// around it.
const faq = <FaqItem>[
  FaqItem(
    'data_on_device',
    'Verilerim nerede tutuluyor?',
    'Zincirin ve hatırlatıcı ayarların yalnızca telefonunda. Test cevapların '
        've arketipin sunucuda, cihazına bağlı bir kimlikle — isminle değil.',
  ),
  FaqItem(
    'no_account',
    'Neden hesap açmıyorum?',
    'Çünkü gerekmiyor. Hesapsız başlamak, seni bir e-posta vermeye zorlamadan '
        'kullanmanın tek yolu. Bunun bedeli aşağıdaki maddede yazıyor.',
  ),
  FaqItem(
    'lost_data',
    'Uygulamayı silersem ne olur?',
    'Zincirin gider. Hesap olmadığı için geri getirecek bir yer yok — bu, '
        'hesapsız çalışmanın bedeli. Telefon değiştirince de aynısı olur.',
  ),
  FaqItem(
    'why_wait',
    'Neden hemen yeni bir test yapamıyorum?',
    'Kişilik iki günde değişmez. Arka arkaya çözülen bir envanter, cevabı '
        'değil ruh halini ölçer. Bekleme süresi sonucun bir anlamı olsun diye.',
  ),
  FaqItem(
    'accuracy',
    'Sonuç ne kadar doğru?',
    'Kısa bir form, kaba bir çözünürlük verir. Arketip bilimsel bir kategori '
        'değil, beş boyutlu bir profilin editöryal yorumu. Yöntem sayfasında '
        'sınırlılıkları tek tek yazdık.',
  ),
  FaqItem(
    'not_me',
    'Arketip bana uymadı, ne yapayım?',
    'Sonuç ekranındaki "bana uymadı" bağlantısını kullan. Hangi arketibin ne '
        'sıklıkla reddedildiği, eşleme tablosunu düzeltmek için elimizdeki tek '
        'sinyal.',
  ),
  FaqItem(
    'chain_broken',
    'Zincirim kırıldı, geri gelir mi?',
    'Ayda bir telafi hakkın var ve tek bir kaçan günü kapatır. İki gün '
        'kaçtıysa kapatmaz — kapatsaydı zincirin bir anlamı kalmazdı.',
  ),
  FaqItem(
    'notifications_off',
    'Bildirimlere izin vermedim, zincir çalışır mı?',
    'Çalışır. Sadece hatırlatma gelmez; günü kendin işaretlersin. iOS izni bir '
        'kez sorar, sonrasında yalnızca sistem ayarlarından açılır.',
  ),
  FaqItem(
    'reminder_time',
    'Hatırlatma saatini değiştirebilir miyim?',
    'Ayarlar ekranından. Günde en fazla bir hatırlatma gelir ve 22:00 ile '
        '08:00 arasında hiç gelmez.',
  ),
  FaqItem(
    'too_many',
    'Neden bazen hiç bildirim gelmiyor?',
    'Üst üste üç bildirimi açmazsan sıklık kendiliğinden düşer. Görmezden '
        'gelinen bir hatırlatıcının çözümü dördüncüsü değil.',
  ),
  FaqItem(
    'delete_data',
    'Verilerimi sildirebilir miyim?',
    'Ayarlar → Gizlilik → Verilerimi sil. Telefonundakiler ve sunucudaki '
        'kaydın silinir. Cihaz kimliğin ve kullandığın hak sayısı kalır; '
        'silip yeniden yükleyerek hak kazanılmasın diye.',
  ),
  FaqItem(
    'cost',
    'Ücretli mi?',
    'Bu sürümde hayır. Test, sonuç, kart ve zincir ücretsiz.',
  ),
  FaqItem(
    'share_card',
    'Paylaştığım kartta ne görünüyor?',
    'Arketibinin adı ve mottosu. Cevapların, puanların ve cihaz kimliğin '
        'kartta yok.',
  ),
  FaqItem(
    'contact',
    'Size nasıl ulaşırım?',
    'Ayarlar → Geri bildirim. E-posta bırakmak zorunda değilsin; bırakmazsan '
        'okuruz ama cevap yazamayız.',
  ),
];
