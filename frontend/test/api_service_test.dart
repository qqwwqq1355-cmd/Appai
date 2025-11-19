import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_project/services/api_service.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import 'api_service_test.mocks.dart';

@GenerateMocks([http.Client])
void main() {
  group('ApiService', () {
    test('login returns a token and saves it and the email when http call completes successfully', () async {
      final client = MockClient();
      final apiService = ApiService(client: client);
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();


      when(client.post(
        any,
        headers: anyNamed('headers'),
        body: anyNamed('body'),
      )).thenAnswer((_) async =>
          http.Response(jsonEncode({'token': 'sample-jwt-token', 'user': {'email': 'test@example.com'}}), 200));

      final result = await apiService.login('test@example.com', 'password');

      expect(result, isA<Map<String, dynamic>>());
      expect(await prefs.getString('token'), 'sample-jwt-token');
      expect(await prefs.getString('email'), 'test@example.com');
    });

    test('login throws an exception with the correct message when http call completes with an error',
        () {
      final client = MockClient();
      final apiService = ApiService(client: client);

      when(client.post(
        any,
        headers: anyNamed('headers'),
        body: anyNamed('body'),
      )).thenAnswer((_) async =>
          http.Response(jsonEncode({'message': 'Invalid credentials'}), 401));

      expect(apiService.login('test@example.com', 'password'),
          throwsA(isA<Exception>().having((e) => e.toString(), 'toString', 'Exception: Invalid credentials')));
    });

    test('logout removes the token and email from shared preferences', () async {
      final client = MockClient();
      final apiService = ApiService(client: client);
      SharedPreferences.setMockInitialValues({'token': 'sample-jwt-token', 'email': 'test@example.com'});
      final prefs = await SharedPreferences.getInstance();

      await apiService.logout();

      expect(await prefs.getString('token'), isNull);
      expect(await prefs.getString('email'), isNull);
    });

    test('getUserEmail returns the email from shared preferences', () async {
      final client = MockClient();
      final apiService = ApiService(client: client);
      SharedPreferences.setMockInitialValues({'email': 'test@example.com'});

      final email = await apiService.getUserEmail();

      expect(email, 'test@example.com');
    });
  });
}
