import 'package:bloc/bloc.dart';
import 'package:wallet/features/settings/domain/repository/settings_repository.dart';
import 'package:wallet/features/settings/domain/theme_preference.dart';

/// Holds the chosen theme and writes every change through.
///
/// The state is the [ThemePreference] itself rather than a wrapper: there is
/// no loading phase to model — the repository has its store open before the
/// cubit exists — and no second field to carry. A freezed state class here
/// would be a box around one enum.
///
/// The language is *not* here. easy_localization already owns it, persists it,
/// and rebuilds on change; mirroring it into this cubit would create a second
/// copy that can disagree with the first.
class SettingsCubit extends Cubit<ThemePreference> {
  SettingsCubit(this._repository) : super(_repository.readTheme());

  final SettingsRepository _repository;

  Future<void> selectTheme(ThemePreference preference) async {
    if (preference == state) return;

    // Emit first: the write is a side effect the UI should not wait on, and a
    // failed write must not leave the app showing a theme it did not pick.
    emit(preference);
    await _repository.writeTheme(preference);
  }
}
