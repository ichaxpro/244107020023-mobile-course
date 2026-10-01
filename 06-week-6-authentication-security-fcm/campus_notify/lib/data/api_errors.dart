import 'package:dio/dio.dart';

String mapDioErrorToUserMessage(Object error) {
  if (error is DioException) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return 'Koneksi terputus/timeout. Silakan coba lagi.';
      case DioExceptionType.connectionError:
        return 'Tidak ada koneksi internet. Periksa jaringan Anda.';
      case DioExceptionType.badResponse:
        final statusCode = error.response?.statusCode;
        if (statusCode == 401) {
          return 'Sesi Anda telah berakhir. Silakan login kembali.';
        } else if (statusCode == 403) {
          return 'Akses ditolak.';
        } else if (statusCode == 404) {
          return 'Data tidak ditemukan.';
        } else if (statusCode != null && statusCode >= 500) {
          return 'Terjadi kesalahan pada server ($statusCode).';
        }
        return 'Terjadi kesalahan (${statusCode ?? "Unknown"}).';
      default:
        return 'Terjadi kesalahan pada koneksi jaringan.';
    }
  }
  return error.toString();
}
