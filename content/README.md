# content

The product's words. Everything a user reads that is not a button lives here,
and `services/motto` seeds its content tables from these files — so a wording
change ships without a store release.

> 🇹🇷 Türkçe için: [README.tr.md](README.tr.md)

| File | What it holds |
|---|---|
| `archetypes.yaml` | the eight archetypes: name, summary, motto |

## The voice

Names are evocative, summaries are spoken. That split is deliberate: the name
carries the claim that this is an inventory rather than a horoscope, and the
summary is what makes someone feel recognised enough to screenshot it.

- **Name** — two words, an image rather than a label. `Sessiz İnşacı`, not
  `Yüksek Vicdanlılık`. One is shared, the other is a scale score.
- **Summary** — second person, the way someone would actually say it.
- **Motto** — a stance, not an instruction.

## Every summary names a cost

A description that only flatters reads as a horoscope and is not shared. What
makes a person feel *seen* is the part nobody says to their face:

> Kimse karar vermeyince sen veriyorsun ve genelde doğru çıkıyor. **Bedeli:**
> herkesin katılmasını beklemediğin için bazen yalnız yürüyorsun.

A strength, then what it costs. Both, or the piece is not finished.

## Words that get the app rejected

App Review guideline 1.4.1 treats a health claim as a health claim. The line is
not about honesty, it is about which words were used:

| Never | Instead |
|---|---|
| test sonucun, değerlendirme | envanter temelli öneri |
| analiz, teşhis, profil çıkarımı | eğilim, örüntü |
| kişilik testi | kişilik envanteri |
| sana uygun tedavi, terapi | sana iyi gelebilecek alışkanlık |

This applies to store copy too, not only to what ships inside the app.

## What is not here

The thresholds that decide which archetype a profile vector lands on. Those are
scoring data and live with the service, so that editing a sentence can never
change who gets which result.

## Done, for one piece

Written · read once more the next day · passes the 1.4.1 table above · fits the
screen it appears on · names a cost, where it is a description.

## The one thing that is not here

Reminder copy lives in
`apps/motto/lib/features/chain/domain/turkish_reminder_copy.dart`, not in this
directory. A notification has to render at the moment it fires, on a phone that
may have been offline for a week, so it cannot come from anything served — and
a copy here plus a copy there is the drift this directory exists to prevent.

The rules still apply to it, and one is written only for it: the chain is
waiting for you, never how many days you have missed.
