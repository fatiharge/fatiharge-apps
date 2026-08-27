# content

Ürünün sözleri. Kullanıcının okuduğu, düğme olmayan her şey burada duruyor ve
`services/motto` içerik tablolarını bu dosyalardan besliyor — yani bir ifade
değişikliği mağaza sürümü beklemiyor.

> 🇬🇧 For English: [README.md](README.md)

| Dosya | İçindekiler |
|---|---|
| `archetypes.yaml` | sekiz arketip: ad, tanım, motto |

## Ses

Adlar imgesel, tanımlar konuşma dili. Bu ayrım bilinçli: adın taşıdığı şey bunun
bir burç değil bir envanter olduğu iddiası, tanımın taşıdığı şey ise kişinin
kendini ekran görüntüsü alacak kadar görülmüş hissetmesi.

- **Ad** — iki kelime, etiket değil imge. `Sessiz İnşacı`, `Yüksek Vicdanlılık`
  değil. Biri paylaşılır, öbürü bir ölçek skorudur.
- **Tanım** — ikinci tekil, insanın gerçekten söyleyeceği gibi.
- **Motto** — bir talimat değil, bir duruş.

## Her tanım bir bedel söyler

Yalnızca iltifat eden bir tanım burç gibi okunur ve paylaşılmaz. Kişiyi
**görülmüş** hissettiren şey, kimsenin yüzüne söylemediği kısımdır:

> Kimse karar vermeyince sen veriyorsun ve genelde doğru çıkıyor. **Bedeli:**
> herkesin katılmasını beklemediğin için bazen yalnız yürüyorsun.

Önce güç, sonra bedeli. İkisi yoksa parça bitmemiştir.

## Uygulamayı reddettiren kelimeler

App Review'ın 1.4.1 maddesi sağlık iddiasını sağlık iddiası sayar. Mesele
dürüstlük değil, hangi kelimenin kullanıldığı:

| Asla | Yerine |
|---|---|
| test sonucun, değerlendirme | envanter temelli öneri |
| analiz, teşhis, profil çıkarımı | eğilim, örüntü |
| kişilik testi | kişilik envanteri |
| sana uygun tedavi, terapi | sana iyi gelebilecek alışkanlık |

Bu, uygulama içi metinler kadar mağaza açıklaması için de geçerli.

## Burada olmayan şey

Bir profil vektörünün hangi arketibe düşeceğine karar veren eşikler. Onlar
skorlama verisi ve servisle birlikte duruyor — bir cümleyi düzeltmek asla kimin
hangi sonucu aldığını değiştirebilmesin diye.

## Bir parça için "bitti"

Yazıldı · ertesi gün bir kez daha okundu · yukarıdaki 1.4.1 tablosundan geçti ·
göründüğü ekrana sığıyor · tanımsa bir bedel söylüyor.

## Bir parça ne zaman biter

`scripts/content_words.py`, 1.4.1 tablosunu hem bu klasörde hem uygulamanın
içindeki metinlerde tarar — kılavuz, cümlenin ağın hangi tarafından geldiğini
umursamıyor. Tek istisnası betiğin içinde yazılı: yöntem ekranı sonucun bir
teşhis **olmadığını** söylüyor ve iddiayı reddetmek için o kelime gerekiyor.

## Burada olmayan: çevrimdışı çalışmak zorunda olan metinler

Bazı metinler, bir haftadır çevrimdışı olan bir telefonda, ihtiyaç duyulduğu
anda görünmek zorunda. Sunucudan gelen hiçbir şeye dayanamazlar, ve hem burada
hem uygulamada kopya tutmak tam olarak bu klasörün engellemek için var olduğu
kayma — o yüzden uygulamada duruyorlar ve nerede olduklarının listesi burada:

| Ne | Nerede |
|---|---|
| Hatırlatıcı bildirimleri | `apps/motto/lib/features/chain/domain/turkish_reminder_copy.dart` |
| SSS | `apps/motto/lib/features/support/domain/faq.dart` |
| Yöntem ve sınırlılıklar | `apps/motto/lib/features/support/domain/method_text.dart` |
| Gizlilik özeti | `apps/motto/lib/features/support/domain/privacy_text.dart` |
| Veri silme | `apps/motto/lib/features/support/domain/deletion_text.dart` |

Kurallar hepsi için geçerli, ve iki tanesi sadece bunlar için yazıldı:

* **Hatırlatıcı, zincirin seni beklediğini söyler; kaç gün kaçırdığını
  saymaz.** Sayan bir hatırlatıcı sildiren bir hatırlatıcıdır, ve azarlayacağı
  kişi zaten kötü bir hafta geçiriyordur.
* **Bir cevap, bedeli dolandırmadan söyler.** "Zincirin gitti ve geri
  getirecek bir hesap yok" cevabı tek yıldıza dönüşmeyen cevaptır; güven veren
  ama cevap vermeyen cümle dönüşür.
