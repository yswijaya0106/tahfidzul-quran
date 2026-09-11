import 'dart:typed_data';

import '../../../core/network/api_client.dart';
import '../domain/uploaded_file.dart';

/// Drives the presign -> direct upload -> complete flow documented in the
/// backend's Postman collection. Widgets never call this directly; they go
/// through a use case in application/.
class FileRepository {
  final ApiClient _apiClient;

  FileRepository({required this._apiClient});

  Future<UploadedFile> upload({
    required String fileName,
    required Uint8List bytes,
    required String mimeType,
    void Function(int sent, int total)? onProgress,
  }) async {
    final presignResponse = await _apiClient.post(
      '/files/presign',
      data: {'fileName': fileName, 'mimeType': mimeType},
    );
    final presignData = presignResponse['data'] as Map<String, dynamic>;
    final objectKey = presignData['objectKey'] as String;
    final uploadUrl = presignData['uploadUrl'] as String;

    await _apiClient.uploadBytes(
      uploadUrl,
      bytes,
      mimeType: mimeType,
      onProgress: onProgress,
    );

    final completeResponse = await _apiClient.post(
      '/files/$objectKey/complete',
      data: {'objectKey': objectKey},
    );
    final completeData = completeResponse['data'] as Map<String, dynamic>;

    return UploadedFile(
      objectKey: completeData['objectKey'] as String,
      mimeType: mimeType,
      sizeBytes: completeData['sizeBytes'] as int,
    );
  }
}
