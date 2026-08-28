import 'dart:async';
import 'package:api_client_motto/api.dart' as api;
import 'package:bloc/bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:meta/meta.dart';
import 'package:motto/config/reported.dart';

enum ProfileStatus { loading, ready, failed }

@immutable
class ProfileState {
  const ProfileState({
    this.status = ProfileStatus.loading,
    this.results = const [],
    this.entitlement,
  });

  final ProfileStatus status;

  /// Newest first, so the first entry is who someone is now.
  final List<api.ResultSummary> results;
  final api.EntitlementResponse? entitlement;

  api.ResultSummary? get current => results.isEmpty ? null : results.first;

  bool get premium => entitlement?.premium ?? false;
}

@injectable
class ProfileCubit extends Cubit<ProfileState> {
  ProfileCubit(this._results, this._entitlements) : super(const ProfileState());

  final api.ResultResourceApi _results;
  final api.EntitlementResourceApi _entitlements;

  void unawaitedLoad() => unawaited(load());

  Future<void> load() async {
    try {
      final history = await _results.resultHistory();
      final entitlement = await _entitlements.currentEntitlement();
      emit(
        ProfileState(
          status: ProfileStatus.ready,
          results: history?.results ?? const [],
          entitlement: entitlement,
        ),
      );
    } on Object catch (failure, trace) {
      reported('profile', failure, trace);
      emit(const ProfileState(status: ProfileStatus.failed));
    }
  }
}
