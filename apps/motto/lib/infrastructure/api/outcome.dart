import 'dart:convert';
import 'dart:io';

import 'package:api_client_motto/api.dart' as api;
import 'package:http/http.dart' show ClientException;
import 'package:meta/meta.dart';
import 'package:motto/config/injectable.dart';
import 'package:motto/config/reported.dart';
import 'package:motto/infrastructure/api/trouble_bus.dart';

/// What a request came back with.
///
/// One shape for every call, so the screen that made it answers with a switch
/// rather than a `try` block of its own. Scattered `catch`es were how the app
/// ended up with four different silences for the same failure: a box that
/// unticked itself, a button that did nothing, a tab that stayed empty and a
/// snackbar.
@immutable
sealed class Outcome<T> {
  const Outcome();
}

final class Ok<T> extends Outcome<T> {
  const Ok(this.value);

  final T value;
}

final class Failed<T> extends Outcome<T> {
  const Failed(this.trouble);

  final Trouble trouble;
}

/// The four things that can go wrong, and nothing else.
///
/// Closed on purpose: a `switch` over this is exhaustive, so a new kind of
/// failure cannot be added without every screen being asked what it means.
@immutable
sealed class Trouble {
  const Trouble();
}

/// The server said no on purpose, and named it.
///
/// The only kind the screen has to think about: the name is what tells it
/// whether to send somebody to their tasks, offer a different email, or say
/// the day cannot be marked twice.
final class Refused extends Trouble {
  const Refused({required this.code, required this.status, this.message});

  final String code;
  final int status;
  final String? message;
}

/// A door the app should never have offered. Nothing for the person to do, so
/// the app says so plainly rather than pretending it was their mistake.
final class NotAllowed extends Trouble {
  const NotAllowed();
}

/// The token is gone and renewing it did not help. Invisible on the happy
/// path — the client renews and retries before this ever gets built.
final class SessionOver extends Trouble {
  const SessionOver();
}

/// It never reached us. The one failure the person can actually act on.
final class Offline extends Trouble {
  const Offline();
}

/// Ours. A server that fell over, a body that would not parse, a null where
/// the contract promised a value. Nothing to tell the person except that it
/// was not them; everything to tell us, so it is reported on the way past.
final class Broken extends Trouble {
  const Broken(this.failure, this.trace);

  final Object failure;
  final StackTrace trace;
}

/// Runs a call and names what came back.
///
/// [where] is the tag the report carries, so a crash in the wild says which
/// part of the app was asking.
Future<Outcome<T>> asked<T>(
  String where,
  Future<T> Function() request,
) async {
  try {
    return Ok(await request());
  } on api.ApiException catch (failure, trace) {
    final trouble = _named(where, failure, trace);
    _announce(trouble);
    return Failed(trouble);
  } on SocketException {
    return const Failed(Offline());
  } on ClientException {
    return const Failed(Offline());
  } on Object catch (failure, trace) {
    // A body that would not parse lands here, and it is ours to fix.
    reported(where, failure, trace);
    return Failed(Broken(failure, trace));
  }
}

/// Tells the shell about the ones it answers on everybody's behalf.
///
/// Looked up rather than injected: `asked` is a function, not a class, and a
/// test that pumps a repository on its own should not have to build a bus.
void _announce(Trouble trouble) {
  if (getIt.isRegistered<TroubleBus>()) getIt<TroubleBus>().add(trouble);
}

/// Names a failure somebody already caught.
///
/// The same reading as [asked] gives, for the call sites that still hold a raw
/// exception: one classification, so a sheet and a cubit cannot disagree about
/// what just happened.
Trouble troubleFrom(Object failure, [StackTrace? trace]) {
  final where = StackTrace.current;
  if (failure is Trouble) return failure;
  if (failure is api.ApiException) {
    return _named('app', failure, trace ?? where);
  }
  if (failure is SocketException || failure is ClientException) {
    return const Offline();
  }
  return Broken(failure, trace ?? where);
}

Trouble _named(String where, api.ApiException failure, StackTrace trace) {
  if (failure.code == 401) return const SessionOver();
  if (failure.code == 403) return const NotAllowed();

  final refusal = failure.code < 500 ? _refusal(failure) : null;
  if (refusal != null) return refusal;

  // A 5xx, or a 4xx with no name on it. Either way nobody outside this repo
  // can do anything about it, so it goes to the report.
  reported(where, failure, trace);
  return Broken(failure, trace);
}

/// Reads `{code, message}` off the body the services all answer with.
Refused? _refusal(api.ApiException failure) {
  final body = failure.message;
  if (body == null || body.isEmpty) return null;

  try {
    final decoded = jsonDecode(body);
    if (decoded is! Map<String, dynamic>) return null;
    if (decoded['code'] case final String code) {
      return Refused(
        code: code,
        status: failure.code,
        message: decoded['message'] as String?,
      );
    }
  } on FormatException {
    return null;
  }
  return null;
}
