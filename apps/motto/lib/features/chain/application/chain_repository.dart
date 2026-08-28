import 'package:api_client_motto/api.dart' as api;
import 'package:injectable/injectable.dart';
import 'package:motto/features/chain/application/chain_store.dart';
import 'package:motto/features/chain/domain/chain.dart';

/// The chain, which lives on the server.
///
/// Marking is the one thing allowed to happen offline: everything else can wait
/// for a connection, but a day someone marked and then lost is the failure this
/// whole feature exists to avoid.
@lazySingleton
class ChainRepository {
  ChainRepository(this._chains, this._store);

  final api.ChainResourceApi _chains;
  final ChainStore _store;

  Chain get cached => _store.readCached();

  /// The server's answer, or the cache when it cannot be reached.
  Future<Chain> load(DateTime today) async {
    await flushPending(today);
    try {
      return await _store.cacheAnd(
        _chains.currentChain(today: isoDay(today)),
      );
    } on Object {
      return cached;
    }
  }

  Future<Chain> start(DateTime today) async {
    final state = await _chains.startChain(
      api.MarkDayRequest(day: dayOf(today), today: dayOf(today)),
    );
    return _store.cacheAnd(Future.value(state));
  }

  /// Marks the day, and keeps it if the server cannot be told yet.
  Future<Chain> mark(DateTime day, DateTime today) async {
    try {
      final state = await _chains.markChainDay(
        api.MarkDayRequest(day: dayOf(day), today: dayOf(today)),
      );
      await _store.clearMark(day);
      return _store.cacheAnd(Future.value(state));
    } on Object {
      // Applied to the cache as well as queued, so the screen agrees with what
      // the person just did rather than waiting for a network they do not have.
      await _store.queueMark(day);
      final optimistic = cached.mark(day);
      await _store.cache(optimistic);
      return optimistic;
    }
  }

  Future<Chain> freeze(DateTime today) async {
    final state = await _chains.spendChainFreeze(
      api.MarkDayRequest(day: dayOf(today), today: dayOf(today)),
    );
    return _store.cacheAnd(Future.value(state));
  }

  /// Replays what was marked offline. Anything the server refuses is dropped:
  /// a day it will not take today it will not take tomorrow either.
  Future<void> flushPending(DateTime today) async {
    for (final day in _store.pendingMarks()) {
      try {
        await _chains.markChainDay(
          api.MarkDayRequest(day: dayOf(day), today: dayOf(today)),
        );
        await _store.clearMark(day);
      } on api.ApiException {
        await _store.clearMark(day);
      } on Object {
        return;
      }
    }
  }
}

extension on ChainStore {
  /// Caches whatever the server said and hands back the domain value.
  Future<Chain> cacheAnd(Future<api.ChainState?> pending) async {
    final chain = _fromState(await pending);
    await cache(chain);
    return chain;
  }
}

Chain _fromState(api.ChainState? state) {
  if (state == null || !state.started) return const Chain();
  return Chain(
    startedOn: state.startedOn,
    markedDays: {for (final marked in state.markedDays) dayOf(marked.day)},
    freezeUsedOn: state.freezeUsedOn,
  );
}
