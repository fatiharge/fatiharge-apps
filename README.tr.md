# fatiharge-apps

> 🇬🇧 For English: [README.md](README.md)

Bir Flutter monorepo.

## Commit kuralı

Bu repo **[Conventional Commits](https://www.conventionalcommits.org/) kullanımını zorunlu kılar**; hem yerel bir git hook hem de CI tarafından (pull request başlığı üzerinden) uygulanır.

Biçim: `<type>(<scope>)?: <açıklama>` — örn. `feat(auth): giriş ekranı eklendi`.

Klonladıktan sonra yerel commit hook'unu bir kez etkinleştir:

```bash
./.githooks/setup.sh
```

Tüm kurallar, izinli türler ve örnekler için [CONTRIBUTING.tr.md](CONTRIBUTING.tr.md) dosyasına bak.

## Başlangıç

> Monorepo yapısı (paketler, uygulamalar, araçlar) proje büyüdükçe eklenecek.
