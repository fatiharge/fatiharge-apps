import 'package:bloc/bloc.dart';
import 'package:wallet/features/settings/domain/repository/settings_repository.dart';
import 'package:wallet/features/settings/domain/theme_preference.dart';

/// The state is the enum itself: no loading phase, no second field. The
/// language is not here — easy_localization already owns and persists it, and
/// a mirror could disagree with it.
class SettingsCubit extends Cubit<ThemePreference> {
  SettingsCubit(this._repository) : super(_repository.readTheme());

  final SettingsRepository _repository;

  Future<void> selectTheme(ThemePreference preference) async {
    if (preference == state) return;

    // Emit first: a failed write must not leave a theme nobody picked.
    emit(preference);
    await _repository.writeTheme(preference);
  }
}
