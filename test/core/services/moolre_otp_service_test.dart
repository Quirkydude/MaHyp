import 'dart:convert';
import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mahyp_app/core/services/moolre_otp_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MockHttpAdapter implements HttpClientAdapter {
  final int statusCode;
  final String responseBody;
  final Map<String, List<String>> headers;

  MockHttpAdapter({
    required this.statusCode,
    required this.responseBody,
    this.headers = const {
      'content-type': ['text/html; charset=UTF-8'],
    },
  });

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    return ResponseBody.fromString(
      responseBody,
      statusCode,
      headers: headers,
    );
  }

  @override
  void close({bool force = false}) {}
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('MoolreOtpService', () {
    test(
        'successfully sends and verifies OTP when Moolre returns text/html JSON string',
        () async {
      final dio = Dio();
      dio.httpClientAdapter = MockHttpAdapter(
        statusCode: 200,
        responseBody:
            '{"status":1,"code":"SMS01","message":"Success","data":null,"go":null}',
      );

      final service = MoolreOtpService(
        vasKey: 'test_vas_key',
        senderId: 'KamarTec',
        dio: dio,
      );

      final sendResult = await service.sendOTP('0241234567');
      expect(sendResult.success, isTrue);
      expect(sendResult.code, 'SMS01');
      expect(sendResult.message, 'OTP sent');

      final prefs = await SharedPreferences.getInstance();
      final storedRaw = prefs.getString('moolre_otp_0241234567');
      expect(storedRaw, isNotNull);
      final storedMap = jsonDecode(storedRaw!) as Map<String, dynamic>;
      final otpCode = storedMap['code'] as String;
      expect(otpCode.length, 6);

      final wrongResult = await service.verifyOTP('0241234567', '999999');
      expect(wrongResult.success, isFalse);
      expect(wrongResult.message, 'Invalid OTP. Please try again.');

      final verifyResult = await service.verifyOTP('0241234567', otpCode);
      expect(verifyResult.success, isTrue);
      expect(verifyResult.message, 'OTP verified');

      final reusedResult = await service.verifyOTP('0241234567', otpCode);
      expect(reusedResult.success, isFalse);
      expect(reusedResult.message, 'No OTP found. Please request a new code.');
    });

    test(
        'returns error message when Moolre returns failure status and does not store OTP',
        () async {
      final dio = Dio();
      dio.httpClientAdapter = MockHttpAdapter(
        statusCode: 200,
        responseBody:
            '{"status":0,"code":"ASMS07","message":"Sender ID is not approved, Please login on app.moolre.com and setup your Sender ID.","data":"senderid","go":null}',
      );

      final service = MoolreOtpService(
        vasKey: 'test_vas_key',
        senderId: 'UnapprovedID',
        dio: dio,
      );

      final sendResult = await service.sendOTP('+233241234567');
      expect(sendResult.success, isFalse);
      expect(sendResult.code, 'ASMS07');
      expect(sendResult.message, contains('Sender ID is not approved'));

      final verifyResult = await service.verifyOTP('0241234567', '123456');
      expect(verifyResult.success, isFalse);
      expect(verifyResult.message, 'No OTP found. Please request a new code.');
    });

    test('handles unconfigured state', () async {
      final service = MoolreOtpService(
        vasKey: '',
        senderId: '',
      );

      expect(service.isConfigured, isFalse);
      final result = await service.sendOTP('0241234567');
      expect(result.success, isFalse);
      expect(result.message, contains('Moolre is not configured'));
    });

    test('formats various Ghana phone number styles correctly', () async {
      final dio = Dio();
      dio.httpClientAdapter = MockHttpAdapter(
        statusCode: 200,
        responseBody:
            '{"status":1,"code":"SMS01","message":"Success","data":null,"go":null}',
      );

      final service = MoolreOtpService(
        vasKey: 'test_vas_key',
        senderId: 'KamarTec',
        dio: dio,
      );

      await service.sendOTP('+233 24 123 4567');
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.containsKey('moolre_otp_0241234567'), isTrue);

      final raw = prefs.getString('moolre_otp_0241234567')!;
      final code = (jsonDecode(raw) as Map<String, dynamic>)['code'] as String;

      final verifyResult = await service.verifyOTP('0241234567', code);
      expect(verifyResult.success, isTrue);
    });
  });
}
