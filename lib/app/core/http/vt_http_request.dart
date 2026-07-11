class VTHttpRequest {
  const VTHttpRequest({required this.path, this.queryParameters = const {}});

  final String path;
  final Map<String, String> queryParameters;
}
