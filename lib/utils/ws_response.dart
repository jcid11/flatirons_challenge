class WsResponse{
  final bool success;
  final String? errorMessage;
  final dynamic data;
  final int? statusCode;

  WsResponse({required this.success,  this.errorMessage,  this.data,  this.statusCode});
}