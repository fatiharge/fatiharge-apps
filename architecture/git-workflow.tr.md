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
- En güncel `main`'den branch aç; `main` önüne geçerse `main` üzerine rebase et.

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
6. **Merge et** — varsayılan squash; ne zaman rebase gerektiği için bkz. [Bir PR tek pakete dokunsun](#bir-pr-tek-pakete-dokunsun).
7. Merge'den sonra branch'i **sil**.

### Bir PR tek pakete dokunsun

**Varsayılan: PR'ı pakete göre böl.** Yalnızca değişiklikler *birbirine bağlıysa*
tek PR'da birleştir — yani biri olmadan diğeri derlenmiyorsa; örneğin bir paket
API'sini değiştirir ve uygulamanın uyması gerekir.

Bu bir üslup meselesi değil. `melos version` bir commit'i **dokunduğu dosyalara**
bakarak pakete atar, changelog metnini de commit'in **konu satırından** alır. İki
pakete birden dokunan squash'lanmış bir PR'ın tek konu satırı vardır; biri
diğerinin işini anlatan bir girdi alır — ve tek bir pakete ait `!` işareti
ikisini birden yükseltir.

Bu bizde zaten yaşandı: `wallet`, `refactor(bootstrap_kit)!: …` başlıklı squash
commit'i `apps/wallet`'a da dokunduğu için `0.2.0`'a çıktı.

Yani:

| PR şuna dokunuyorsa | Şununla merge et | Neden |
| ------------------- | ---------------- | ----- |
| tek pakete | **Squash** | varsayılan; konu satırı ile paket örtüşür |
| birkaçına, bağımlı | **Rebase** | her commit kendi scope'uyla iner, her changelog doğru olur |
| birkaçına, bağımsız | — | onun yerine paket başına bir PR'a böl |

`architecture/` ve kökteki config dosyaları hiçbir pakete ait değildir; bu
durumu tetiklemezler ve herhangi bir PR'a eşlik edebilirler.

### Neden squash-merge

- `main` lineer kalır: PR başına bir commit, her biri temiz bir Conventional Commit.
- Yalnızca **PR başlığını** (gelecekteki squash commit'i) zorlamamız yeterli, her ara WIP commit'ini değil.
- Otomatik changelog/versiyonlama için temiz girdi.

## Branch protection (GitHub ayarları)

GitHub → **Settings → Branches → Add rule** ile `main` için ayarla:

- ✅ **Require a pull request before merging** (`main`'e doğrudan push yok).
  - En az **1 onay** iste.
- ✅ **Require status checks to pass before merging.**
  - **`Validate PR title`**'ı seç (`Conventional PR Title` workflow'undan).
  - ✅ Merge'den önce branch'lerin güncel olmasını iste.
- ✅ **Require linear history** (squash-merge ile eşleşir).
- ✅ İsteğe bağlı: conversation resolution iste, force-push'u engelle, yöneticileri de dahil et.

Repository → **Settings → General → Pull Requests**:

- Yalnızca **squash merging**'e izin ver (merge commit ve rebase merging'i kapat).
- Merge'den sonra head branch'leri **otomatik sil**.

> Bu ayarlar GitHub arayüzünde etkinleştirilene kadar CI kontrolü durum bildirir ama merge'i *engelleyemez*. Konvansiyonu sert bir bariyere çeviren şey branch protection'dır.
