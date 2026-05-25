class RtdbPaths {
  const RtdbPaths._();

  static String deviceCode(String codeHash) => 'deviceCodes/$codeHash';

  static String deviceLatest(String deviceCode) => 'devices/$deviceCode/latest';

  static String deviceReadings(String deviceCode) {
    return 'devices/$deviceCode/readings';
  }

  static String deviceReading(String deviceCode, String readingId) {
    return '${deviceReadings(deviceCode)}/$readingId';
  }

  static String deviceConfig(String deviceCode) => 'devices/$deviceCode/config';
<<<<<<< HEAD
=======

  static String deviceAlerts(String deviceCode) => 'devices/$deviceCode/alerts';
>>>>>>> origin/main
}
