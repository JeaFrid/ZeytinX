enum ZeytinXNotificationMediaType {
  small("small"),
  big("big");

  final String value;
  const ZeytinXNotificationMediaType(this.value);
}

class ZeytinXNotificationMediaModel {
  final String url;
  final ZeytinXNotificationMediaType type;

  ZeytinXNotificationMediaModel({
    required this.url,
    this.type = ZeytinXNotificationMediaType.small,
  });

  Map<String, dynamic> toJson() {
    return {'url': url, 'type': type.value};
  }

  factory ZeytinXNotificationMediaModel.fromJson(Map<String, dynamic> json) {
    return ZeytinXNotificationMediaModel(
      url: json['url'] ?? '',
      type: ZeytinXNotificationMediaType.values.firstWhere(
        (e) => e.value == json['type'],
        orElse: () => ZeytinXNotificationMediaType.small,
      ),
    );
  }
}

class ZeytinXNotificationModel {
  final String id;
  final String title;
  final String description;
  final DateTime createdAt;
  final List<String> targetUserIds;
  final List<ZeytinXNotificationMediaModel> media;
  final String type;
  final List<String> seenBy;
  final bool isInApp;
  final String? inAppTag;
  final Map<String, dynamic> moreData;

  ZeytinXNotificationModel({
    required this.id,
    required this.title,
    required this.description,
    required this.createdAt,
    required this.targetUserIds,
    this.media = const [],
    required this.type,
    this.seenBy = const [],
    this.isInApp = false,
    this.inAppTag,
    this.moreData = const {},
  });

  factory ZeytinXNotificationModel.empty() {
    return ZeytinXNotificationModel(
      id: '',
      title: '',
      description: '',
      createdAt: DateTime.now(),
      targetUserIds: [],
      type: 'general',
    );
  }

  bool isSeen(String userId) => seenBy.contains(userId);

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'createdAt': createdAt.toIso8601String(),
      'targetUserIds': targetUserIds,
      'media': media.map((e) => e.toJson()).toList(),
      'type': type,
      'seenBy': seenBy,
      'isInApp': isInApp,
      'inAppTag': inAppTag,
      'moreData': moreData,
    };
  }

  factory ZeytinXNotificationModel.fromJson(Map<String, dynamic> json) {
    return ZeytinXNotificationModel(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      createdAt: DateTime.parse(json['createdAt']),
      targetUserIds: List<String>.from(json['targetUserIds'] ?? []),
      media:
          (json['media'] as List?)
              ?.map((e) => ZeytinXNotificationMediaModel.fromJson(e))
              .toList() ??
          [],
      type: json['type'] ?? 'general',
      seenBy: List<String>.from(json['seenBy'] ?? []),
      isInApp: json['isInApp'] ?? false,
      inAppTag: json['inAppTag'],
      moreData: json['moreData'] ?? {},
    );
  }

  ZeytinXNotificationModel copyWith({
    String? id,
    String? title,
    String? description,
    DateTime? createdAt,
    List<String>? targetUserIds,
    List<ZeytinXNotificationMediaModel>? media,
    String? type,
    List<String>? seenBy,
    bool? isInApp,
    String? inAppTag,
    Map<String, dynamic>? moreData,
  }) {
    return ZeytinXNotificationModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
      targetUserIds: targetUserIds ?? this.targetUserIds,
      media: media ?? this.media,
      type: type ?? this.type,
      seenBy: seenBy ?? this.seenBy,
      isInApp: isInApp ?? this.isInApp,
      inAppTag: inAppTag ?? this.inAppTag,
      moreData: moreData ?? this.moreData,
    );
  }
}
