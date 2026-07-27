# Git Akışı

> 🇬🇧 For English: [git-workflow.md](git-workflow.md)

Bu doküman, bu Flutter monorepo'da nasıl branch açtığımızı, commit'lediğimizi ve merge ettiğimizi anlatır.

- Commit kuralları ve izinli türler: [CONTRIBUTING.tr.md](../CONTRIBUTING.tr.md)
- For English contributing guide: [CONTRIBUTING.md](../CONTRIBUTING.md)

## Branch stratejisi

Tek uzun ömürlü branch'li bir **trunk-based** akış kullanıyoruz.

| Branch          | Rol                                                            |
| --------------- | -------------------------------------------------------------- |
| `main`          | Tek doğruluk kaynağı. Her zaman release edilebilir, her zaman yeşil. |
| `feature/*`     | Yeni işlevsellik.                                              |
| `fix/*`         | Hata düzeltmeleri.                                             |
| `chore/*`       | Bakım: bağımlılıklar, tooling, CI, config, docs.              |

- Her değişiklik `main`'e bir **pull request** ile iner — doğrudan push yok.
- Kısa ömürlü branch'ler: PR'ı erken aç, küçük tut, hızlı merge et, branch'i sil.
- En güncel `main`'den branch aç; `main` önüne geçerse branch'ini GitHub'ın
  **Update branch** düğmesiyle güncelle.

### İsimlendirme

```
<type>/<kisa-kebab-aciklama>
```

`type` öneki, Conventional Commit türlerini yansıtır; böylece niyet ilk bakışta bellidir.

```
feature/user-login
feature/payments-apple-pay
fix/auth-token-refresh
chore/bump-flutter-3-24
```

İsteğe bağlı olarak bir paket/scope ekle: `feature/auth/social-login`.

## Commit mesajları — Conventional Commits

Her commit **mutlaka** [Conventional Commits](https://www.conventionalcommits.org/) kurallarına uymalı:

```
<type>(<scope>)?<!>?: <açıklama>
```

- **Yerel** olarak `.githooks/commit-msg` hook'u ile zorlanır (klonladıktan sonra bir kez `./.githooks/setup.sh` çalıştır).
- **CI**'da PR başlığı üzerinden zorlanır (aşağıya bak).
- Scope, dokunduğun monorepo paketiyle eşleşmeli (`auth`, `ui_kit`, …).
- `!` (veya bir `BREAKING CHANGE:` footer'ı) kırıcı değişikliği işaretler.

Tüm kurallar, tür tablosu ve örnekler [CONTRIBUTING.tr.md](../CONTRIBUTING.tr.md)'de. Bu konvansiyon, monorepo büyüdükçe otomatik paket versiyonlama ve changelog'u (Melos) da besler.

## Pull request süreci

1. Yukarıdaki isimlendirmeyle en güncel `main`'den **branch aç**.
2. Conventional Commit mesajlarıyla **commit'le**.
3. `main`'e bir **PR aç**. PR **başlığı geçerli bir Conventional Commit olmalı** — squash-merge yaptığımız için merge commit'i başlıktan oluşur.
4. **CI geçmeli.** `Conventional PR Title` workflow'u başlığı doğrular; diğer kontroller (test, analyze) proje büyüdükçe eklenir.
5. **Review** — en az bir onay gerekir.
6. **Squash and merge** — ruleset'in izin verdiği tek yöntem. Bkz. [PR'ı kapsamla ve dokunduğu her paketi düşünerek başlıklandır](#prı-kapsamla-ve-dokundugu-her-paketi-düşünerek-başlıklandır).
7. Merge'den sonra branch'i **sil**.

### PR'ı kapsamla ve dokunduğu her paketi düşünerek başlıklandır

**Tercihen workspace member başına bir PR.** Değişiklikler bağımsızsa böl —
her biri ayrı review edilir, ayrı geri alınır.

Gerçekten *bağımlı*ysalar birlikte gönder. Bir paketin API'sini değiştirmesi ve
uygulamanın buna uyması tek PR'a aittir; bunu ekle/kullan/kaldır dizisine bölmek,
başlıktan çok daha ucuza elde edebileceğimiz bir doğruluğu pahalıya satın alır.

Başlığın önemi şuradan geliyor: `melos version` bir commit'i **dokunduğu
dosyalara** bakarak pakete atar, ama changelog metnini commit'in **konu
satırından** alır. Squash-merge yaptığımız için iki member'a dokunan bir PR
geriye **tek** konu satırı bırakır ve dokunulan **her** member o satırı alır.

Bu yüzden birden fazla member'a dokunan PR'da **scope'u hiç yazma**:

```
refactor!: take the splash from the page, not the port     ← iyi
refactor(bootstrap_kit)!: take the splash from …           ← wallet'ın
                                                              changelog'u artık
                                                              başka bir paketin
                                                              adını anıyor
```

Conventional Commits'te scope opsiyonel ve PR başlık kontrolü ikisini de kabul
ediyor. Yazmamak hiçbir şeye mal olmuyor ve bir paketin changelog'unun
komşusunun işini sahiplenmesini engelliyor. `wallet`'ın `refactor(bootstrap_kit)!`
başlığı yüzünden `0.2.0`'a çıkması tam da bundan kaçınılan durum.

Merge her zaman **squash**: `main` üzerindeki ruleset başka yönteme izin
vermiyor ve doğrusal geçmiş şart. Zaten bozuk hiçbir şey `main`'e ulaşamaz —
iki CI kontrolü de geçmek zorunda.

`architecture/`, `.github/`, `scripts/` ve kök config hiçbir member'a ait
değildir; bu konuyu hiç tetiklemezler ve herhangi bir PR'a eşlik edebilirler.

### Neden squash-merge

- `main` lineer kalır: PR başına bir commit, her biri temiz bir Conventional Commit.
- Yalnızca **PR başlığını** (gelecekteki squash commit'i) zorlamamız yeterli, her ara WIP commit'ini değil.
- Otomatik changelog/versiyonlama için temiz girdi.

## Branch protection (GitHub ayarları)

Klasik branch protection yerine bir **ruleset** olarak kurulu
(`main-protection`) — GitHub → **Settings → Rules → Rulesets**. Dikkat: eski
`/branches/main/protection` API'si ruleset'ler için 404 döner; branch korumasız
sanmak buradan kolay.

Bugün `main` üzerinde zorlananlar:

- **Merge öncesi PR zorunlu**, tek izinli yöntem squash. Onay zorunlu değil —
  tek kişilik bir ekipte kendi işini onaylamak bir şey katmıyor.
- **Zorunlu status check'ler:** `Analyze, format & test` ve `Validate PR title`.
- **Doğrusal geçmiş zorunlu**, silme ve force-push kapalı.
- **Açık değil:** *require branches to be up to date before merging*. Yani bir PR,
  açıldığı `main`'e karşı test edilir; indiği `main`'e karşı değil — CI'ın her
  `main` push'unda da çalışmasının sebebi bu.

Repository → **Settings → General → Pull Requests**:

- Yalnızca **squash merging**'e izin ver — diğer iki yöntem kapalı.
- Merge'den sonra head branch'leri **otomatik sil**.

> Bu ayarlar GitHub arayüzünde etkinleştirilene kadar CI kontrolü durum bildirir ama merge'i *engelleyemez*. Konvansiyonu sert bir bariyere çeviren şey branch protection'dır.
