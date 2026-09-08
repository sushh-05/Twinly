class BackendHealth {
  const BackendHealth({required this.status, required this.service});
  final String status;
  final String service;

  factory BackendHealth.fromJson(Map<String, dynamic> json) => BackendHealth(
    status: json['status'] as String,
    service: json['service'] as String,
  );
}
