import 'package:zeytinx/zeytinx.dart';

enum ZeytinXCommunityModelType {
  private("private"),
  privCommunity("privCommunity"),
  superCommunity("superCommunity"),
  channel("channel"),
  voiceChat("voiceChat"),
  muteChat("muteChat"),
  community("community");

  final String value;
  const ZeytinXCommunityModelType(this.value);
}

ZeytinXCommunityModelType? _typeFromString(String? value) {
  if (value == null) return null;
  return ZeytinXCommunityModelType.values.firstWhere(
    (e) => e.value == value,
    orElse: () => ZeytinXCommunityModelType.private,
  );
}

enum ZeytinXRoomType {
  text("text"),
  voice("voice"),
  announcement("announcement");

  final String value;
  const ZeytinXRoomType(this.value);
}

class ZeytinXCommunityRoomModel {
  final String id;
  final String communityId;
  final String name;
  final ZeytinXRoomType type;
  final List<String> allowedRoles;
  final DateTime createdAt;

  ZeytinXCommunityRoomModel({
    required this.id,
    required this.communityId,
    required this.name,
    this.type = ZeytinXRoomType.text,
    this.allowedRoles = const [],
    required this.createdAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'communityId': communityId,
      'name': name,
      'type': type.value,
      'allowedRoles': allowedRoles,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory ZeytinXCommunityRoomModel.fromJson(Map<String, dynamic> json) {
    return ZeytinXCommunityRoomModel(
      id: json['id'] ?? '',
      communityId: json['communityId'] ?? '',
      name: json['name'] ?? '',
      type: ZeytinXRoomType.values.firstWhere(
        (e) => e.value == json['type'],
        orElse: () => ZeytinXRoomType.text,
      ),
      allowedRoles: List<String>.from(json['allowedRoles'] ?? []),
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}

class ZeytinXCommunityInviteModel {
  final String code;
  final String communityId;
  final String creatorId;
  final DateTime createdAt;
  final DateTime? expiresAt;
  final int? maxUses;
  final int usedCount;
  final Map<String, dynamic> moreData;

  ZeytinXCommunityInviteModel({
    required this.code,
    required this.communityId,
    required this.creatorId,
    required this.createdAt,
    this.expiresAt,
    this.maxUses,
    this.usedCount = 0,
    this.moreData = const {},
  });

  factory ZeytinXCommunityInviteModel.empty() {
    return ZeytinXCommunityInviteModel(
      code: '',
      communityId: '',
      creatorId: '',
      createdAt: DateTime.now(),
    );
  }

  bool get isExpired {
    if (expiresAt == null) return false;
    return DateTime.now().isAfter(expiresAt!);
  }

  bool get isQuotaExceeded {
    if (maxUses == null) return false;
    return usedCount >= maxUses!;
  }

  bool get isValid => !isExpired && !isQuotaExceeded;

  Map<String, dynamic> toJson() {
    return {
      "code": code,
      "communityId": communityId,
      "creatorId": creatorId,
      "createdAt": createdAt.toIso8601String(),
      "expiresAt": expiresAt?.toIso8601String(),
      "maxUses": maxUses,
      "usedCount": usedCount,
      "moreData": moreData,
    };
  }

  factory ZeytinXCommunityInviteModel.fromJson(Map<String, dynamic> json) {
    return ZeytinXCommunityInviteModel(
      code: json["code"] ?? "",
      communityId: json["communityId"] ?? "",
      creatorId: json["creatorId"] ?? "",
      createdAt: DateTime.tryParse(json["createdAt"] ?? "") ?? DateTime.now(),
      expiresAt: json["expiresAt"] != null
          ? DateTime.tryParse(json["expiresAt"])
          : null,
      maxUses: json["maxUses"],
      usedCount: json["usedCount"] ?? 0,
      moreData: json["moreData"] ?? {},
    );
  }

  ZeytinXCommunityInviteModel copyWith({
    String? code,
    String? communityId,
    String? creatorId,
    DateTime? createdAt,
    DateTime? expiresAt,
    int? maxUses,
    int? usedCount,
    Map<String, dynamic>? moreData,
  }) {
    return ZeytinXCommunityInviteModel(
      code: code ?? this.code,
      communityId: communityId ?? this.communityId,
      creatorId: creatorId ?? this.creatorId,
      createdAt: createdAt ?? this.createdAt,
      expiresAt: expiresAt ?? this.expiresAt,
      maxUses: maxUses ?? this.maxUses,
      usedCount: usedCount ?? this.usedCount,
      moreData: moreData ?? this.moreData,
    );
  }
}

class ZeytinXCommunityModel {
  final String id;
  final String name;
  final String? description;
  final String? photoURL;
  final ZeytinXCommunityModelType? type;
  final DateTime createdAt;
  final List<ZeytinXUserModel> participants;
  final List<ZeytinXUserModel> admins;
  final String lastMessage;
  final DateTime lastMessageTimestamp;
  final ZeytinXUserModel lastMessageSender;
  final int unreadCount;
  final List<ZeytinXUserModel> typingUsers;
  final bool isMuted;
  final bool isArchived;
  final List<String> pinnedMessageIDs;
  final String moreData;
  final String? rules;
  final List<String> stickers;
  final String? pinnedPostID;

  ZeytinXCommunityModel({
    required this.id,
    required this.name,
    this.description,
    this.type,
    this.photoURL,
    required this.createdAt,
    required this.participants,
    required this.admins,
    required this.lastMessage,
    required this.lastMessageTimestamp,
    required this.lastMessageSender,
    required this.unreadCount,
    required this.typingUsers,
    required this.isMuted,
    required this.isArchived,
    required this.pinnedMessageIDs,
    required this.moreData,
    this.rules,
    this.stickers = const [],
    this.pinnedPostID,
  });

  factory ZeytinXCommunityModel.empty() {
    return ZeytinXCommunityModel(
      id: '',
      name: '',
      description: null,
      type: null,
      photoURL: null,
      createdAt: DateTime.now(),
      participants: [],
      admins: [],
      lastMessage: '',
      lastMessageTimestamp: DateTime.now(),
      lastMessageSender: ZeytinXUserModel.empty(),
      unreadCount: 0,
      typingUsers: [],
      isMuted: false,
      isArchived: false,
      pinnedMessageIDs: [],
      moreData: '',
      rules: null,
      stickers: [],
      pinnedPostID: null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'photoURL': photoURL,
      'type': type?.value,
      'createdAt': createdAt.toIso8601String(),
      'participants': participants.map((x) => x.toJson()).toList(),
      'admins': admins.map((x) => x.toJson()).toList(),
      'lastMessage': lastMessage,
      'lastMessageTimestamp': lastMessageTimestamp.toIso8601String(),
      'lastMessageSender': lastMessageSender.toJson(),
      'unreadCount': unreadCount,
      'typingUsers': typingUsers.map((x) => x.toJson()).toList(),
      'isMuted': isMuted,
      'isArchived': isArchived,
      'pinnedMessageIDs': pinnedMessageIDs,
      'moreData': moreData,
      'rules': rules,
      'stickers': stickers,
      'pinnedPostID': pinnedPostID,
    };
  }

  factory ZeytinXCommunityModel.fromJson(Map<String, dynamic> json) {
    return ZeytinXCommunityModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      type: _typeFromString(json['type'] as String?),
      description: json['description'],
      photoURL: json['photoURL'],
      createdAt: DateTime.parse(json['createdAt']),
      participants:
          (json['participants'] as List?)
              ?.map((x) => ZeytinXUserModel.fromJson(x))
              .toList() ??
          [],
      admins:
          (json['admins'] as List?)
              ?.map((x) => ZeytinXUserModel.fromJson(x))
              .toList() ??
          [],
      lastMessage: json['lastMessage'] ?? '',
      lastMessageTimestamp: DateTime.parse(json['lastMessageTimestamp']),
      lastMessageSender: ZeytinXUserModel.fromJson(json['lastMessageSender']),
      unreadCount: json['unreadCount'] ?? 0,
      typingUsers:
          (json['typingUsers'] as List?)
              ?.map((x) => ZeytinXUserModel.fromJson(x))
              .toList() ??
          [],
      isMuted: json['isMuted'] ?? false,
      isArchived: json['isArchived'] ?? false,
      pinnedMessageIDs: List<String>.from(json['pinnedMessageIDs'] ?? []),
      moreData: json['moreData'] ?? '',
      rules: json['rules'],
      stickers: List<String>.from(json['stickers'] ?? []),
      pinnedPostID: json['pinnedPostID'],
    );
  }

  ZeytinXCommunityModel copyWith({
    String? id,
    String? name,
    String? description,
    ZeytinXCommunityModelType? type,
    String? photoURL,
    DateTime? createdAt,
    List<ZeytinXUserModel>? participants,
    List<ZeytinXUserModel>? admins,
    String? lastMessage,
    DateTime? lastMessageTimestamp,
    ZeytinXUserModel? lastMessageSender,
    int? unreadCount,
    List<ZeytinXUserModel>? typingUsers,
    bool? isMuted,
    bool? isArchived,
    List<String>? pinnedMessageIDs,
    String? moreData,
    String? rules,
    List<String>? stickers,
    String? pinnedPostID,
  }) {
    return ZeytinXCommunityModel(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      description: description ?? this.description,
      photoURL: photoURL ?? this.photoURL,
      createdAt: createdAt ?? this.createdAt,
      participants: participants ?? this.participants,
      admins: admins ?? this.admins,
      lastMessage: lastMessage ?? this.lastMessage,
      lastMessageTimestamp: lastMessageTimestamp ?? this.lastMessageTimestamp,
      lastMessageSender: lastMessageSender ?? this.lastMessageSender,
      unreadCount: unreadCount ?? this.unreadCount,
      typingUsers: typingUsers ?? this.typingUsers,
      isMuted: isMuted ?? this.isMuted,
      isArchived: isArchived ?? this.isArchived,
      pinnedMessageIDs: pinnedMessageIDs ?? this.pinnedMessageIDs,
      moreData: moreData ?? this.moreData,
      rules: rules ?? this.rules,
      stickers: stickers ?? this.stickers,
      pinnedPostID: pinnedPostID ?? this.pinnedPostID,
    );
  }
}
