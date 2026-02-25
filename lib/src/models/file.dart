enum ZeytinXFileType {
  image("image"),
  video("video"),
  doc("doc"),
  url("url"),
  or("or");

  final String value;
  const ZeytinXFileType(this.value);
}

class ZeytinXFileModel {
  final String url;
  final ZeytinXFileType type;
  final Map<String, dynamic> moreData;

  ZeytinXFileModel({
    required this.url,
    required this.type,
    this.moreData = const {},
  });

  factory ZeytinXFileModel.empty() {
    return ZeytinXFileModel(url: '', type: ZeytinXFileType.image, moreData: {});
  }

  factory ZeytinXFileModel.fromJson(Map<String, dynamic> json) {
    return ZeytinXFileModel(
      url: json['url']?.toString() ?? '',
      type: ZeytinXFileType.values.firstWhere(
        (e) => e.value == json['type'],
        orElse: () => ZeytinXFileType.image,
      ),
      moreData: json['moreData'] is Map
          ? Map<String, dynamic>.from(json['moreData'])
          : {},
    );
  }

  Map<String, dynamic> toJson() {
    return {'url': url, 'type': type.value, 'moreData': moreData};
  }

  ZeytinXFileModel copyWith({
    String? url,
    ZeytinXFileType? type,
    Map<String, dynamic>? moreData,
  }) {
    return ZeytinXFileModel(
      url: url ?? this.url,
      type: type ?? this.type,
      moreData: moreData ?? this.moreData,
    );
  }
}
