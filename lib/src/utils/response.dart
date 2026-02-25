class ZeytinXResponse {
  final bool isSuccess;
  final String message;
  final Map<String, dynamic>? data;
  final String? error;

  ZeytinXResponse({
    required this.isSuccess,
    required this.message,
    this.data,
    this.error,
  });
}
