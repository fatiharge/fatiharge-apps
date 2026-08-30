import 'dart:io';

import 'package:api_client_motto/api.dart' as api;
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' show ClientException;
import 'package:motto/infrastructure/api/outcome.dart';

api.ApiException _answered(int status, String body) =>
    api.ApiException(status, body);

String _named(String code) => '{"code":"$code","message":"…","traceId":"t-1"}';

void main() {
  group('what a request came back with', () {
    test('a value is a value', () async {
      final outcome = await asked('test', () async => 7);
      expect(outcome, isA<Ok<int>>());
      expect((outcome as Ok<int>).value, 7);
    });

    test('a named refusal keeps its name', () async {
      final outcome = await asked<int>(
        'test',
        () async => throw _answered(409, _named('no_turns_left')),
      );

      // The name is the whole point: it is what tells the screen whether to
      // send somebody to their tasks or to say come back tomorrow.
      final trouble = (outcome as Failed<int>).trouble;
      expect(trouble, isA<Refused>());
      expect((trouble as Refused).code, 'no_turns_left');
      expect(trouble.status, 409);
    });

    test('a dead session is its own thing', () async {
      final outcome = await asked<int>(
        'test',
        () async => throw _answered(401, ''),
      );

      // Never reaches a screen on the happy path — the client renews and
      // retries first. This is only what is left when that did not work.
      expect((outcome as Failed<int>).trouble, isA<SessionOver>());
    });

    test('a door we should not have offered is not their mistake', () async {
      final outcome = await asked<int>(
        'test',
        () async => throw _answered(403, ''),
      );
      expect((outcome as Failed<int>).trouble, isA<NotAllowed>());
    });

    test('a request that never arrived is a connection', () async {
      final socket = await asked<int>(
        'test',
        () async => throw const SocketException('no route'),
      );
      final client = await asked<int>(
        'test',
        () async => throw ClientException('failed'),
      );

      // The one failure the person can act on, so it must not be mixed in
      // with the ones they cannot.
      expect((socket as Failed<int>).trouble, isA<Offline>());
      expect((client as Failed<int>).trouble, isA<Offline>());
    });

    test('a server that fell over is ours', () async {
      final outcome = await asked<int>(
        'test',
        () async => throw _answered(500, _named('store_unreachable')),
      );

      // Named or not, a 5xx is nothing anybody outside this repo can act on.
      expect((outcome as Failed<int>).trouble, isA<Broken>());
    });

    test('a refusal with nothing to call it is ours too', () async {
      final outcome = await asked<int>(
        'test',
        () async => throw _answered(400, 'not json at all'),
      );

      // A 4xx we cannot name is a contract we are not keeping.
      expect((outcome as Failed<int>).trouble, isA<Broken>());
    });

    test('a body that would not parse is ours', () async {
      final outcome = await asked<int>(
        'test',
        () async => throw const FormatException('unexpected end'),
      );
      expect((outcome as Failed<int>).trouble, isA<Broken>());
    });
  });
}
