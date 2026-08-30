-- The two ways to run out of turns, and what each leads to.
--
-- The app used to be handed one refusal and two flags, and worked out which
-- sentence to say from them. It said the wrong one whenever the day was
-- unmarked: "you have used them all" to somebody with a turn still waiting in
-- the day. The server knows which is true, so it says which.
--
-- These are the first definitions. They exist as rows so that changing "önce
-- görevini bitir" costs a sentence rather than a release.

INSERT INTO error_effects (code, locale, definition) VALUES
('no_turns_yet', 'tr',
 '[{"kind":"bottom_sheet",
    "title":"Oyun hakkın bitti",
    "body":"Önce görevini bitir, hakkını kazan.",
    "choices":[{"label":"Görevlere git","then":[{"kind":"navigate","to":"gorevler"}]},
               {"label":"Kapat","then":[]}]}]'),
('no_turns_today', 'tr',
 '[{"kind":"bottom_sheet",
    "title":"Oyun hakkın bitti",
    "body":"Bugünlük tüm haklarını bitirdin. Yeni hak için yarınki görevlerini bekle.",
    "choices":[{"label":"Tamam","then":[]}]}]');
