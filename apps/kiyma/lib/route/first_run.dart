/// Whether this device has ever answered the language question.
///
/// easy_localization stores the chosen locale itself and exposes it only
/// through an inherited widget, so it is read on the startup page — where
/// there is a context — and left here for `bootstrapFinished`, which has
/// none. A global for the same reason the flag is: exactly one device, read
/// once, before any screen that cares exists.
bool languageChosen = false;
