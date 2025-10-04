import 'dart:math';

/// Contract for requesting and verifying one-time SMS codes.
abstract class SmsService {
  Future<void> requestCode(String phoneNumber);
  Future<bool> verifyCode({required String phoneNumber, required String code});
}

/// In-memory mock that simulates delivery of one-time codes.
class MockSmsService implements SmsService {
  final _codes = <String, String>{};
  final _random = Random();

  @override
  Future<void> requestCode(String phoneNumber) async {
    await Future<void>.delayed(const Duration(milliseconds: 350));
    final generated = (_random.nextInt(900000) + 100000).toString();
    _codes[phoneNumber] = generated;
    // In production the SMS would be sent to the user. During local testing we
    // simply log the code to help with manual verification.
    // ignore: avoid_print
    print('Mock SMS to $phoneNumber: $generated');
  }

  @override
  Future<bool> verifyCode({required String phoneNumber, required String code}) async {
    await Future<void>.delayed(const Duration(milliseconds: 250));
    final saved = _codes[phoneNumber];
    final isValid = saved != null && saved == code.trim();
    if (isValid) {
      _codes.remove(phoneNumber);
    }
    return isValid;
  }
}

/// Template for wiring the production SMS API when backend integration is
/// ready. The provided API key is intentionally commented out so that it is not
/// accidentally shipped in clear text. Move it to secure storage or an
/// environment variable before enabling network requests.
class ExternalSmsService implements SmsService {
  ExternalSmsService({required this.endpointBase});

  final String endpointBase;
  // static const String _smsApiKey = '457A5DBA-D814-BC10-DDD7-645DC659658E';

  @override
  Future<void> requestCode(String phoneNumber) {
    throw UnimplementedError('POST phoneNumber to $endpointBase when backend is ready');
  }

  @override
  Future<bool> verifyCode({required String phoneNumber, required String code}) {
    throw UnimplementedError('Verify code with $endpointBase once the PHP API is implemented');
  }
}
