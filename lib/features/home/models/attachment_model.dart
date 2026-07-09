class AttachmentModel {
  final String publicId;
  final String secureUrl; // The URL to view or download the file
  final String? resourceType;
  final String? format;
  final int? bytes;

  AttachmentModel({
    required this.publicId,
    required this.secureUrl,
    this.resourceType,
    this.format,
    this.bytes,
  });

  factory AttachmentModel.fromJson(Map<String, dynamic> json) {
    return AttachmentModel(
      publicId: json['public_id']?.toString() ?? json['publicId']?.toString() ?? '',
      secureUrl: json['secure_url']?.toString() ?? json['secureUrl']?.toString() ?? '',
      resourceType: json['resource_type']?.toString() ?? json['resourceType']?.toString(),
      format: json['format']?.toString(),
      bytes: json['bytes'] != null ? (json['bytes'] as num).toInt() : null,
    );
  }
}
