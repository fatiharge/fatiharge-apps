# wallet

> 🇬🇧 For English: [README.md](README.md)

Yerel çalışan kişisel gelir/gider takibi. Backend yok: her şey cihazdaki
Hive'da duruyor.

## Çalıştırma

```bash
fvm install                 # bir kez, .fvmrc'yi okur
fvm flutter pub get         # repo kökünden (pub workspace)
cd apps/wallet
fvm dart run build_runner build   # freezed / auto_route / injectable
fvm flutter run
```

Kullanışlı parametreler:

```bash
fvm flutter run --dart-define=SEED_DEMO_DATA=true   # boş veritabanını doldur
fvm flutter run --dart-define=FEATURE_DEBUG_LOGS=false
```

## Yerleşim

```
lib/app/
├─ features/finance/     domain / application / presentation
├─ features/startup/     açılış (bootstrap) ekranı
├─ infrastructure/       Hive adapter'ları — depolamayı bilen tek yer
├─ config/  route/  theme/
```

Feature `packages/` altında değil, app'in içinde: tek tüketicisi var, yani
henüz paylaşılacak bir şey yok (bkz.
[architecture/package-conventions.tr.md](../../architecture/package-conventions.tr.md)).
`domain/` içinde Flutter, Hive ve IO import'u yok; ileride paketе çıkarmayı
ucuz tutan şey bu.

## Tasarım notları

- **Para minor birimde saklanır** (`int` kuruş), asla `double`. Kullanıcı
  girdisi `Money.tryParse` ile ayrıştırılır ve hiç double'a uğramaz.
- **Kur çevrimi olmadan çoklu para birimi.** Toplamlar tek para birimine
  göre hesaplanır, dashboard geçiş sunar; farklı birimler asla toplanmaz.
- **Repository'ler stream döner**; işlem eklenince dashboard, geçmiş listesi
  ve bütçe uyarıları kendiliğinden güncellenir.
- **Kategoriler silinmez, arşivlenir** — geçmiş işlemler onlara id ile
  bağlı ve çözümlenmeye devam etmeli.

## v1'de yok

Flavor'lar, backend senkronizasyonu, tekrarlayan işlemler, dışa aktarma,
push bildirimi. Bütçe uyarıları yalnızca uygulama içi.
