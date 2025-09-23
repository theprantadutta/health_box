import 'package:drift/drift.dart';

class Attachments extends Table {
  TextColumn get id => text().named('id')();
  TextColumn get recordId =>
      text().named('record_id')(); // References any medical record
  TextColumn get fileName => text().named('file_name')();
  TextColumn get filePath => text().named('file_path')();
  TextColumn get fileType => text().named('file_type')();
  TextColumn get mimeType => text().nullable().named('mime_type')();
  IntColumn get fileSize => integer().named('file_size')();
  TextColumn get description => text().nullable().named('description')();
  TextColumn get thumbnailPath => text().nullable().named('thumbnail_path')();
  IntColumn get sortOrder => integer().withDefault(const Constant(0)).named('sort_order')();
  DateTimeColumn get createdAt =>
      dateTime().withDefault(currentDateAndTime).named('created_at')();
  DateTimeColumn get updatedAt =>
      dateTime().withDefault(currentDateAndTime).named('updated_at')();
  BoolColumn get isActive =>
      boolean().withDefault(const Constant(true)).named('is_active')();
  BoolColumn get isSynced =>
      boolean().withDefault(const Constant(false)).named('is_synced')();
  BoolColumn get isConfidential =>
      boolean().withDefault(const Constant(false)).named('is_confidential')();

  @override
  Set<Column> get primaryKey => {id};

  @override
  List<String> get customConstraints => [
    'CHECK (LENGTH(TRIM(file_name)) > 0)',
    'CHECK (LENGTH(TRIM(file_path)) > 0)',
    'CHECK (file_type IN (\'image\', \'pdf\', \'document\', \'audio\', \'video\', \'other\'))',
    'CHECK (file_size > 0 AND file_size <= 52428800)', // 50MB max
    'CHECK (sort_order >= 0)',
  ];
}

// File type constants
class AttachmentFileType {
  static const String image = 'image';
  static const String pdf = 'pdf';
  static const String document = 'document';
  static const String audio = 'audio';
  static const String video = 'video';
  static const String other = 'other';

  static const List<String> allTypes = [
    image,
    pdf,
    document,
    audio,
    video,
    other,
  ];

  static String getDisplayName(String type) {
    switch (type) {
      case image:
        return 'Image';
      case pdf:
        return 'PDF Document';
      case document:
        return 'Document';
      case audio:
        return 'Audio';
      case video:
        return 'Video';
      case other:
        return 'Other';
      default:
        return type;
    }
  }

  static String getTypeFromMimeType(String? mimeType) {
    if (mimeType == null) return other;

    if (mimeType.startsWith('image/')) return image;
    if (mimeType == 'application/pdf') return pdf;
    if (mimeType.startsWith('audio/')) return audio;
    if (mimeType.startsWith('video/')) return video;
    if (mimeType.startsWith('text/') ||
        mimeType.contains('document') ||
        mimeType.contains('sheet') ||
        mimeType.contains('presentation')) return document;

    return other;
  }

  static String getTypeFromFileName(String fileName) {
    final extension = fileName.toLowerCase().split('.').last;

    switch (extension) {
      case 'jpg':
      case 'jpeg':
      case 'png':
      case 'gif':
      case 'bmp':
      case 'webp':
      case 'svg':
      case 'heic':
      case 'avif':
        return image;

      case 'pdf':
        return pdf;

      case 'doc':
      case 'docx':
      case 'txt':
      case 'rtf':
      case 'odt':
      case 'xls':
      case 'xlsx':
      case 'ppt':
      case 'pptx':
      case 'csv':
        return document;

      case 'mp3':
      case 'wav':
      case 'aac':
      case 'flac':
      case 'm4a':
      case 'ogg':
        return audio;

      case 'mp4':
      case 'avi':
      case 'mov':
      case 'wmv':
      case 'mkv':
      case 'webm':
        return video;

      default:
        return other;
    }
  }

  static bool canPreview(String type) {
    return type == image || type == pdf;
  }

  static bool isImage(String type) {
    return type == image;
  }

  static bool isPdf(String type) {
    return type == pdf;
  }
}

// Common MIME types for medical documents
class MedicalMimeTypes {
  // Images
  static const String jpeg = 'image/jpeg';
  static const String png = 'image/png';
  static const String gif = 'image/gif';
  static const String bmp = 'image/bmp';
  static const String webp = 'image/webp';
  static const String svg = 'image/svg+xml';
  static const String heic = 'image/heic';
  static const String avif = 'image/avif';

  // Documents
  static const String pdf = 'application/pdf';
  static const String msWord = 'application/msword';
  static const String msWordX = 'application/vnd.openxmlformats-officedocument.wordprocessingml.document';
  static const String msExcel = 'application/vnd.ms-excel';
  static const String msExcelX = 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet';
  static const String msPowerPoint = 'application/vnd.ms-powerpoint';
  static const String msPowerPointX = 'application/vnd.openxmlformats-officedocument.presentationml.presentation';
  static const String textPlain = 'text/plain';
  static const String rtf = 'application/rtf';

  // Medical specific
  static const String dicom = 'application/dicom';
  static const String hl7 = 'application/hl7-v2';

  static const List<String> supportedTypes = [
    jpeg, png, gif, bmp, webp, svg, heic, avif,
    pdf, msWord, msWordX, msExcel, msExcelX, msPowerPoint, msPowerPointX,
    textPlain, rtf, dicom, hl7,
  ];
}
