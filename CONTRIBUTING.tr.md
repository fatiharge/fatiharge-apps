# Katkı Rehberi

> 🇬🇧 For English: [CONTRIBUTING.md](CONTRIBUTING.md)

Katkın için teşekkürler! Bu repo **[Conventional Commits](https://www.conventionalcommits.org/) kullanımını zorunlu kılar.** Bu sadece bir stil tercihi değil: bu Flutter monorepo'da otomatik paket versiyonlama ve changelog üretimini besleyen işlevsel bir gereksinimdir.

## Commit mesajı biçimi

```
<type>(<scope>)?<!>?: <açıklama>
```

- **type** — aşağıdaki izinli türlerden biri (zorunlu)
- **scope** — etkilenen paket/alan, örn. `auth`, `core_ui` (opsiyonel)
- **!** — kırıcı (breaking) değişikliği işaretler (opsiyonel)
- **açıklama** — emir kipinde kısa özet (zorunlu)

### İzinli türler

| Tür        | Ne zaman kullanılır                                     |
| ---------- | ------------------------------------------------------- |
| `feat`     | Yeni özellik                                            |
| `fix`      | Hata düzeltmesi                                         |
| `docs`     | Sadece dokümantasyon                                    |
| `style`    | Biçimlendirme, kod davranışı değişmez                   |
| `refactor` | Özellik ya da düzeltme olmayan kod değişikliği          |
| `perf`     | Performans iyileştirmesi                                |
| `test`     | Test ekleme veya düzeltme                               |
| `build`    | Build sistemi veya bağımlılıklar                        |
| `ci`       | CI yapılandırması                                       |
| `chore`    | Bakım işleri                                            |
| `revert`   | Önceki bir commit'i geri alma                           |

### Örnekler

```
feat: kullanıcı girişi eklendi
fix(auth): token yenileme hatası düzeltildi
feat(payments)!: API sözleşmesi değiştirildi
chore(deps): bağımlılıklar güncellendi
docs: kurulum talimatları güncellendi
```

## Nasıl zorunlu kılınıyor

İki katman var:

1. **Yerel git hook (erken uyarı).** `commit-msg` hook'u, kurala uymayan mesajı commit anında reddeder. Klonladıktan sonra bir kez etkinleştir:

   ```bash
   ./.githooks/setup.sh
   # veya:
   git config core.hooksPath .githooks
   ```

   > Yerel hook'lar klonlamayla otomatik kurulmaz ve `git commit --no-verify` ile atlanabilir. Bunlar bir kolaylıktır, asıl bariyer değildir.

2. **CI (asıl bariyer).** Bir GitHub Actions workflow'u **pull request başlığını** aynı kurallara göre doğrular. Uymayan başlık kontrolü başarısız yapar ve merge'i engeller. Squash-merge kullandığımız için merge commit'i PR başlığından oluşur.

## İpuçları

- Commit'in hook'a takılırsa mesajı `git commit --amend` ile düzelt.
- Açıklamayı emir kipinde tut: "ekle", "düzelt", "güncelle" — "eklendi"/"düzeltir" değil.
- Monorepo'da dokunduğun pakete uygun bir scope kullan.
