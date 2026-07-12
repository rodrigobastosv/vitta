import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:vitta/app/core/http/vt_http_client.dart';
import 'package:vitta/app/core/http/vt_http_request.dart';

void main() {
  test('get returns the decoded body on a 200 response', () async {
    final client = VTHttpClient(
      baseUrl: 'https://example.com',
      client: MockClient((request) async => http.Response('{"ok":true}', 200)),
    );

    final bodyResult = await client.get(const VTHttpRequest(path: '/foo'));

    bodyResult.when((error) => fail('expected success, got $error'), (body) => expect(body, {'ok': true}));
  });

  test('get retries a transient 5xx response and succeeds once the server recovers', () async {
    var callCount = 0;
    final client = VTHttpClient(
      baseUrl: 'https://example.com',
      client: MockClient((request) async {
        callCount++;
        if (callCount < 3) {
          return http.Response('', 503);
        }
        return http.Response('{"ok":true}', 200);
      }),
    );

    final bodyResult = await client.get(const VTHttpRequest(path: '/foo'));

    bodyResult.when((error) => fail('expected success, got $error'), (body) => expect(body, {'ok': true}));
    expect(callCount, 3);
  });

  test('get gives up and returns a failure after repeated 5xx responses', () async {
    var callCount = 0;
    final client = VTHttpClient(
      baseUrl: 'https://example.com',
      client: MockClient((request) async {
        callCount++;
        return http.Response('', 503);
      }),
    );

    final bodyResult = await client.get(const VTHttpRequest(path: '/foo'));

    bodyResult.when((error) => expect(error.message, contains('503')), (body) => fail('expected failure, got $body'));
    expect(callCount, 3);
  });

  test('get does not retry a non-5xx failure response', () async {
    var callCount = 0;
    final client = VTHttpClient(
      baseUrl: 'https://example.com',
      client: MockClient((request) async {
        callCount++;
        return http.Response('', 404);
      }),
    );

    final bodyResult = await client.get(const VTHttpRequest(path: '/foo'));

    bodyResult.when((error) => expect(error.message, contains('404')), (body) => fail('expected failure, got $body'));
    expect(callCount, 1);
  });
}
