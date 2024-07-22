// models/pdf_file.dart
class PDFFile {
  final String fileName;
  final String uploadDate;

  PDFFile({required this.fileName, required this.uploadDate});

  factory PDFFile.fromJson(Map<String, dynamic> json) {
    return PDFFile(
      fileName: json['file_name'] ?? 'Unnamed File',
      uploadDate: json['upload_date'] ?? 'Unknown Date',
    );
  }
}
