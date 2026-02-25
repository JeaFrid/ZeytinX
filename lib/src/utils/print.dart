class ZeytinXPrint {
  static void successPrint(String data) {
    print('\x1B[32m[✅]: $data\x1B[0m');
  }

  static void errorPrint(String data) {
    print('\x1B[31m[❌]: $data\x1B[0m');
  }

  static void warningPrint(String data) {
    print('\x1B[33m[❗]: $data\x1B[0m');
  }
}
