import 'dart:async';

import 'package:api_client_motto/api.dart' as api;
import 'package:bloc/bloc.dart';
import 'package:injectable/injectable.dart';

enum SupportCopyStatus { loading, ready, failed }

class SupportCopyState {
  const SupportCopyState({this.status = SupportCopyStatus.loading, this.copy});

  final SupportCopyStatus status;
  final api.SupportCopy? copy;
}

/// The support copy, from the server every time.
///
/// Not cached: a wrong answer about where somebody's data is has to be fixable
/// in one deploy, and a cache is a copy that keeps answering the old way.
@injectable
class SupportCopyCubit extends Cubit<SupportCopyState> {
  SupportCopyCubit(this._support) : super(const SupportCopyState());

  final api.SupportResourceApi _support;

  void unawaitedLoad() => unawaited(load());

  Future<void> load() async {
    try {
      final copy = await _support.supportCopy();
      emit(SupportCopyState(status: SupportCopyStatus.ready, copy: copy));
    } on Object {
      emit(const SupportCopyState(status: SupportCopyStatus.failed));
    }
  }
}
