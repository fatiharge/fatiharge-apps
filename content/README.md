# content

The product's words. Everything a user reads that is not a button lives here,
and `services/motto` serves them — so a wording change ships without a store
release.

Most of it is read from the classpath at startup. The two that live in tables
instead, `tasks.yaml` and `report.yaml`, are pushed into the running service by
`scripts/push_content.py`; they are data, not schema, so correcting a sentence
is one request rather than a deploy.

> 🇹🇷 Türkçe için: [README.tr.md](README.tr.md)

| File | What it holds |
|---|---|
| `archetypes.yaml` | the eight archetypes: name, summary, motto |
| `items.yaml` | the short form: twenty statements, four per dimension |
| `mottos.yaml` | four mottos per archetype, each with what it means and its reminder line |
| `daily_skeletons.yaml` | the fourteen days, without the person in them |
| `fragments.yaml` | four per archetype, the part that makes a day theirs |
| `connectors.yaml` | the hand-written joins between the two |
| `tasks.yaml` | the three things each of the fourteen days asks for |
| `report.yaml` | the deep report's shared parts: four section skeletons and the limitations |
| `support.yaml` | the FAQ, the privacy summary and the deletion copy |

A day someone reads is `skeleton.body` + a connector + a fragment. Fourteen
bodies and eight sets of four fragments is a hundred and twelve days of text
from forty-six pieces — which only works while the connectors are written by
hand. The moment they become a template, every day reads like the same
sentence with a different ending, and that is what a horoscope is.

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

`scripts/content_words.py` checks the table over this directory and over the
copy that ships inside the app — the guideline does not care which side of the
network a sentence came from. It has one exception, written down in the script:
the method screen says the result is **not** a diagnosis, and denying the claim
needs the word.

## What is not here: copy that has to work offline

Some text has to render on a phone that has been offline for a week, at the
moment it is needed. It cannot come from anything served, and a copy here plus
a copy in the app is exactly the drift this directory exists to prevent — so it
lives in the app, and this list is where you find it:

| What | Where |
|---|---|
| Reminder notifications | `apps/motto/lib/features/chain/domain/turkish_reminder_copy.dart` |
| Method and limitations | `apps/motto/lib/features/support/domain/method_text.dart` |

The FAQ, the privacy summary and the deletion copy used to be here too. They
are served now (`support.yaml`), because the answer that matters most — where
somebody's data is — has to be correctable in one deploy rather than one store
release.

The rules still apply to all of it, and two are written only for these:

* **A reminder says the chain is waiting for you, never how many days you have
  missed.** One that keeps score is one that gets the app deleted, and the
  person it would scold is already having a bad week.
* **An answer names the cost plainly rather than working around it.** "Your
  streak is gone and there is no account to restore it from" is the answer that
  does not become a one-star review; a reassuring non-answer is.
