import 'package:zeytinx/zeytinx.dart';

enum ZeytinXChatType {
  private("private"),
  privGroup("privGroup"),
  superGroup("superGroup"),
  channel("channel"),
  voiceChat("voiceChat"),
  muteChat("muteChat"),
  group("group");

  final String value;
  const ZeytinXChatType(this.value);
}

enum ZeytinXMessageType {
  text("text"),
  image("image"),
  video("video"),
  audio("audio"),
  file("file"),
  location("location"),
  contact("contact"),
  sticker("sticker"),
  system("system");

  final String value;
  const ZeytinXMessageType(this.value);
}

enum ZeytinXMessageStatus {
  sending("sending"),
  sent("sent"),
  delivered("delivered"),
  read("read"),
  failed("failed");

  final String value;
  const ZeytinXMessageStatus(this.value);
}

enum ZeytinXSystemMessageType {
  userJoined("user_joined"),
  userLeft("user_left"),
  groupCreated("group_created"),
  nameChanged("name_changed"),
  photoChanged("photo_changed"),
  adminAdded("admin_added"),
  adminRemoved("admin_removed"),
  callStarted("call_started"),
  callEnded("call_ended"),
  callMissed("call_missed"),
  callRejected("call_rejected"),
  callBusy("call_busy"),
  callCanceled("call_canceled"),
  videoCallStarted("video_call_started"),
  audioCallStarted("audio_call_started"),
  messagePinned("message_pinned"),
  messageUnpinned("message_unpinned"),
  chatSecured("chat_secured"),
  disappearingTimerChanged("disappearing_timer_changed"),
  none("none");

  final String value;
  const ZeytinXSystemMessageType(this.value);
}

class ZeytinXMediaDimensionsModel {
  final int width;
  final int height;

  ZeytinXMediaDimensionsModel({required this.width, required this.height});

  Map<String, dynamic> toJson() => {'width': width, 'height': height};
  factory ZeytinXMediaDimensionsModel.fromJson(Map<String, dynamic> json) {
    return ZeytinXMediaDimensionsModel(
      width: json['width'] ?? 0,
      height: json['height'] ?? 0,
    );
  }
}

class ZeytinXMediaModel {
  final String url;
  final String? thumbnailUrl;
  final int? fileSize;
  final String fileName;
  final String mimeType;
  final Duration? duration;
  final ZeytinXMediaDimensionsModel? dimensions;

  ZeytinXMediaModel({
    required this.url,
    this.thumbnailUrl,
    this.fileSize,
    required this.fileName,
    required this.mimeType,
    this.duration,
    this.dimensions,
  });

  Map<String, dynamic> toJson() {
    return {
      'url': url,
      'thumbnailUrl': thumbnailUrl,
      'fileSize': fileSize,
      'fileName': fileName,
      'mimeType': mimeType,
      'duration': duration?.inMilliseconds,
      'dimensions': dimensions?.toJson(),
    };
  }

  factory ZeytinXMediaModel.fromJson(Map<String, dynamic> json) {
    return ZeytinXMediaModel(
      url: json['url'] ?? '',
      thumbnailUrl: json['thumbnailUrl'],
      fileSize: json['fileSize'],
      fileName: json['fileName'] ?? '',
      mimeType: json['mimeType'] ?? '',
      duration: json['duration'] != null
          ? Duration(milliseconds: json['duration'])
          : null,
      dimensions: json['dimensions'] != null
          ? ZeytinXMediaDimensionsModel.fromJson(json['dimensions'])
          : null,
    );
  }
}

class ZeytinXLocationModel {
  final double latitude;
  final double longitude;
  final String? name;
  final String? address;

  ZeytinXLocationModel({
    required this.latitude,
    required this.longitude,
    this.name,
    this.address,
  });

  Map<String, dynamic> toJson() {
    return {
      'latitude': latitude,
      'longitude': longitude,
      'name': name,
      'address': address,
    };
  }

  factory ZeytinXLocationModel.fromJson(Map<String, dynamic> json) {
    return ZeytinXLocationModel(
      latitude: json['latitude'] ?? 0.0,
      longitude: json['longitude'] ?? 0.0,
      name: json['name'],
      address: json['address'],
    );
  }
}

class ZeytinXContactModel {
  final String name;
  final String? phoneNumber;
  final String? email;

  ZeytinXContactModel({required this.name, this.phoneNumber, this.email});

  Map<String, dynamic> toJson() {
    return {'name': name, 'phoneNumber': phoneNumber, 'email': email};
  }

  factory ZeytinXContactModel.fromJson(Map<String, dynamic> json) {
    return ZeytinXContactModel(
      name: json['name'] ?? '',
      phoneNumber: json['phoneNumber'],
      email: json['email'],
    );
  }
}

class ZeytinXReactionModel {
  final String emoji;
  final String userId;
  final DateTime timestamp;

  ZeytinXReactionModel({
    required this.emoji,
    required this.userId,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() {
    return {
      'emoji': emoji,
      'userId': userId,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  factory ZeytinXReactionModel.fromJson(Map<String, dynamic> json) {
    return ZeytinXReactionModel(
      emoji: json['emoji'] ?? '',
      userId: json['userId'] ?? '',
      timestamp: DateTime.parse(json['timestamp']),
    );
  }
}

class ZeytinXMessageReactionsModel {
  final Map<String, List<ZeytinXReactionModel>> reactions;

  ZeytinXMessageReactionsModel({
    Map<String, List<ZeytinXReactionModel>>? reactions,
  }) : reactions = reactions ?? {};

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> result = {};
    reactions.forEach((emoji, reactionList) {
      result[emoji] = reactionList.map((r) => r.toJson()).toList();
    });
    return result;
  }

  factory ZeytinXMessageReactionsModel.fromJson(Map<String, dynamic> json) {
    final Map<String, List<ZeytinXReactionModel>> reactionsMap = {};
    json.forEach((emoji, reactionData) {
      if (reactionData is List) {
        reactionsMap[emoji] = reactionData
            .map<ZeytinXReactionModel>(
              (item) => ZeytinXReactionModel.fromJson(item),
            )
            .toList();
      }
    });
    return ZeytinXMessageReactionsModel(reactions: reactionsMap);
  }
}

class ZeytinXMessageStatusInfoModel {
  final List<String> deliveredTo;
  final List<String> readBy;
  final DateTime? deliveredAt;
  final DateTime? readAt;

  ZeytinXMessageStatusInfoModel({
    List<String>? deliveredTo,
    List<String>? readBy,
    this.deliveredAt,
    this.readAt,
  }) : deliveredTo = deliveredTo ?? [],
       readBy = readBy ?? [];

  Map<String, dynamic> toJson() {
    return {
      'deliveredTo': deliveredTo,
      'readBy': readBy,
      'deliveredAt': deliveredAt?.toIso8601String(),
      'readAt': readAt?.toIso8601String(),
    };
  }

  ZeytinXMessageStatusInfoModel copyWith({
    List<String>? deliveredTo,
    List<String>? readBy,
    DateTime? deliveredAt,
    DateTime? readAt,
  }) {
    return ZeytinXMessageStatusInfoModel(
      deliveredTo: deliveredTo ?? this.deliveredTo,
      readBy: readBy ?? this.readBy,
      deliveredAt: deliveredAt ?? this.deliveredAt,
      readAt: readAt ?? this.readAt,
    );
  }

  factory ZeytinXMessageStatusInfoModel.fromJson(Map<String, dynamic> json) {
    return ZeytinXMessageStatusInfoModel(
      deliveredTo: json['deliveredTo'] != null
          ? List<String>.from(json['deliveredTo'])
          : [],
      readBy: json['readBy'] != null ? List<String>.from(json['readBy']) : [],
      deliveredAt: json['deliveredAt'] != null
          ? DateTime.tryParse(json['deliveredAt'])
          : null,
      readAt: json['readAt'] != null ? DateTime.tryParse(json['readAt']) : null,
    );
  }
}

class ZeytinXSystemMessageDataModel {
  final ZeytinXSystemMessageType type;
  final String? userId;
  final String? userName;
  final String? oldValue;
  final String? value;

  ZeytinXSystemMessageDataModel({
    required this.type,
    this.userId,
    this.userName,
    this.oldValue,
    this.value,
  });

  Map<String, dynamic> toJson() {
    return {
      'type': type.value,
      'userId': userId,
      'userName': userName,
      'oldValue': oldValue,
      'value': value,
    };
  }

  factory ZeytinXSystemMessageDataModel.fromJson(Map<String, dynamic> json) {
    return ZeytinXSystemMessageDataModel(
      type: ZeytinXSystemMessageType.values.firstWhere(
        (e) => e.value == json['type'],
        orElse: () => ZeytinXSystemMessageType.none,
      ),
      userId: json['userId'],
      userName: json['userName'],
      oldValue: json['oldValue'],
      value: json['value'],
    );
  }
}

class ZeytinXInteractiveButtonModel {
  final String id;
  final String text;
  final String type;
  final String? payload;

  ZeytinXInteractiveButtonModel({
    required this.id,
    required this.text,
    required this.type,
    this.payload,
  });

  Map<String, dynamic> toJson() {
    return {'id': id, 'text': text, 'type': type, 'payload': payload};
  }

  factory ZeytinXInteractiveButtonModel.fromJson(Map<String, dynamic> json) {
    return ZeytinXInteractiveButtonModel(
      id: json['id'] ?? '',
      text: json['text'] ?? '',
      type: json['type'] ?? '',
      payload: json['payload'],
    );
  }
}

class ZeytinXBotModel {
  final String botId;
  final String botName;

  ZeytinXBotModel({required this.botId, required this.botName});

  static ZeytinXBotModel empty() => ZeytinXBotModel(botId: '', botName: '');

  Map<String, dynamic> toJson() => {'botId': botId, 'botName': botName};

  factory ZeytinXBotModel.fromJson(Map<String, dynamic> json) {
    return ZeytinXBotModel(
      botId: json['botId'] ?? '',
      botName: json['botName'] ?? '',
    );
  }
}

class ZeytinXChatModel {
  final String chatID;
  final ZeytinXChatType type;
  final DateTime createdAt;
  final String chatName;
  final String chatPhotoURL;
  final Map<String, dynamic> themeSettings;
  final List<ZeytinXUserModel> participants;
  final List<ZeytinXUserModel> admins;
  final String lastMessage;
  final DateTime lastMessageTimestamp;
  final ZeytinXUserModel lastMessageSender;
  final int unreadCount;
  final List<ZeytinXUserModel> typingUsers;
  final List<ZeytinXBotModel> bots;
  final bool isMuted;
  final bool isArchived;
  final bool isBlocked;
  final List<String> pinnedMessageIDs;
  final String moreData;

  ZeytinXChatModel({
    required this.chatID,
    required this.type,
    required this.createdAt,
    required this.chatName,
    required this.chatPhotoURL,
    required this.themeSettings,
    required this.lastMessage,
    required this.lastMessageTimestamp,
    required this.lastMessageSender,
    required this.unreadCount,
    required this.participants,
    required this.admins,
    required this.typingUsers,
    required this.bots,
    required this.isMuted,
    required this.isArchived,
    required this.isBlocked,
    required this.pinnedMessageIDs,
    required this.moreData,
  });

  static ZeytinXChatModel empty() {
    return ZeytinXChatModel(
      chatID: '',
      type: ZeytinXChatType.private,
      createdAt: DateTime.now(),
      chatName: '',
      chatPhotoURL: '',
      themeSettings: {},
      lastMessage: '',
      lastMessageTimestamp: DateTime.now(),
      lastMessageSender: ZeytinXUserModel.empty(),
      unreadCount: 0,
      participants: [],
      admins: [],
      typingUsers: [],
      bots: [],
      isMuted: false,
      isArchived: false,
      isBlocked: false,
      pinnedMessageIDs: [],
      moreData: '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'chatID': chatID,
      'type': type.value,
      'createdAt': createdAt.toIso8601String(),
      'chatName': chatName,
      'chatPhotoURL': chatPhotoURL,
      'themeSettings': themeSettings,
      'participants': participants.map((x) => x.toJson()).toList(),
      'admins': admins.map((x) => x.toJson()).toList(),
      'lastMessage': lastMessage,
      'lastMessageTimestamp': lastMessageTimestamp.toIso8601String(),
      'lastMessageSender': lastMessageSender.toJson(),
      'unreadCount': unreadCount,
      'typingUsers': typingUsers.map((x) => x.toJson()).toList(),
      'bots': bots.map((x) => x.toJson()).toList(),
      'isMuted': isMuted,
      'isArchived': isArchived,
      'isBlocked': isBlocked,
      'pinnedMessageIDs': pinnedMessageIDs,
      'moreData': moreData,
    };
  }

  factory ZeytinXChatModel.fromJson(Map<String, dynamic> json) {
    return ZeytinXChatModel(
      chatID: json['chatID'] ?? '',
      type: ZeytinXChatType.values.firstWhere(
        (e) => e.value == json['type'],
        orElse: () => ZeytinXChatType.private,
      ),
      createdAt: DateTime.parse(json['createdAt']),
      chatName: json['chatName'] ?? '',
      chatPhotoURL: json['chatPhotoURL'] ?? '',
      themeSettings: Map<String, dynamic>.from(json['themeSettings'] ?? {}),
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
      bots:
          (json['bots'] as List?)
              ?.map((x) => ZeytinXBotModel.fromJson(x))
              .toList() ??
          [],
      isMuted: json['isMuted'] ?? false,
      isArchived: json['isArchived'] ?? false,
      isBlocked: json['isBlocked'] ?? false,
      pinnedMessageIDs: List<String>.from(json['pinnedMessageIDs'] ?? []),
      moreData: json['moreData'] ?? '',
    );
  }

  ZeytinXChatModel copyWith({
    String? chatID,
    ZeytinXChatType? type,
    DateTime? createdAt,
    String? chatName,
    String? chatPhotoURL,
    Map<String, dynamic>? themeSettings,
    List<ZeytinXUserModel>? participants,
    List<ZeytinXUserModel>? admins,
    String? lastMessage,
    DateTime? lastMessageTimestamp,
    ZeytinXUserModel? lastMessageSender,
    int? unreadCount,
    List<ZeytinXUserModel>? typingUsers,
    List<ZeytinXBotModel>? bots,
    bool? isMuted,
    bool? isArchived,
    bool? isBlocked,
    List<String>? pinnedMessageIDs,
    String? moreData,
  }) {
    return ZeytinXChatModel(
      chatID: chatID ?? this.chatID,
      type: type ?? this.type,
      createdAt: createdAt ?? this.createdAt,
      chatName: chatName ?? this.chatName,
      chatPhotoURL: chatPhotoURL ?? this.chatPhotoURL,
      themeSettings: themeSettings ?? this.themeSettings,
      participants: participants ?? this.participants,
      admins: admins ?? this.admins,
      lastMessage: lastMessage ?? this.lastMessage,
      lastMessageTimestamp: lastMessageTimestamp ?? this.lastMessageTimestamp,
      lastMessageSender: lastMessageSender ?? this.lastMessageSender,
      unreadCount: unreadCount ?? this.unreadCount,
      typingUsers: typingUsers ?? this.typingUsers,
      bots: bots ?? this.bots,
      isMuted: isMuted ?? this.isMuted,
      isArchived: isArchived ?? this.isArchived,
      isBlocked: isBlocked ?? this.isBlocked,
      pinnedMessageIDs: pinnedMessageIDs ?? this.pinnedMessageIDs,
      moreData: moreData ?? this.moreData,
    );
  }
}

class ZeytinXMessage {
  final String messageId;
  final String chatId;
  final String senderId;
  final String text;
  final DateTime timestamp;
  final ZeytinXMessageType messageType;
  final ZeytinXMessageStatus status;
  final bool isEdited;
  final DateTime? editedTimestamp;
  final bool isDeleted;
  final bool deletedForEveryone;
  final bool isForwarded;
  final String? forwardedFrom;
  final ZeytinXMediaModel? media;
  final ZeytinXLocationModel? location;
  final ZeytinXContactModel? contact;
  final String? replyToMessageId;
  final List<String> mentions;
  final ZeytinXMessageReactionsModel reactions;
  final ZeytinXMessageStatusInfoModel statusInfo;
  final List<String> starredBy;
  final bool isPinned;
  final String? pinnedBy;
  final DateTime? pinnedTimestamp;
  final bool isSystemMessage;
  final ZeytinXSystemMessageDataModel? systemMessageData;
  final bool encrypted;
  final String? encryptionKey;
  final Duration? selfDestructTimer;
  final DateTime? selfDestructTimestamp;
  final String? localId;
  final String? serverId;
  final int sequenceNumber;
  final String? botId;
  final List<ZeytinXInteractiveButtonModel> interactiveButtons;
  final Map<String, dynamic> metadata;

  ZeytinXMessage({
    required this.messageId,
    required this.chatId,
    required this.senderId,
    required this.text,
    required this.timestamp,
    this.messageType = ZeytinXMessageType.text,
    this.status = ZeytinXMessageStatus.sent,
    this.isEdited = false,
    this.editedTimestamp,
    this.isDeleted = false,
    this.deletedForEveryone = false,
    this.isForwarded = false,
    this.forwardedFrom,
    this.media,
    this.location,
    this.contact,
    this.replyToMessageId,
    List<String>? mentions,
    ZeytinXMessageReactionsModel? reactions,
    ZeytinXMessageStatusInfoModel? statusInfo,
    List<String>? starredBy,
    this.isPinned = false,
    this.pinnedBy,
    this.pinnedTimestamp,
    this.isSystemMessage = false,
    this.systemMessageData,
    this.encrypted = false,
    this.encryptionKey,
    this.selfDestructTimer,
    this.selfDestructTimestamp,
    this.localId,
    this.serverId,
    this.sequenceNumber = 0,
    this.botId,
    List<ZeytinXInteractiveButtonModel>? interactiveButtons,
    Map<String, dynamic>? metadata,
  }) : mentions = mentions ?? [],
       reactions = reactions ?? ZeytinXMessageReactionsModel(),
       statusInfo = statusInfo ?? ZeytinXMessageStatusInfoModel(),
       starredBy = starredBy ?? [],
       interactiveButtons = interactiveButtons ?? [],
       metadata = metadata ?? {};

  Map<String, dynamic> toJson() {
    return {
      'messageId': messageId,
      'chatId': chatId,
      'senderId': senderId,
      'text': text,
      'timestamp': timestamp.toIso8601String(),
      'messageType': messageType.value,
      'status': status.value,
      'isEdited': isEdited,
      'editedTimestamp': editedTimestamp?.toIso8601String(),
      'isDeleted': isDeleted,
      'deletedForEveryone': deletedForEveryone,
      'isForwarded': isForwarded,
      'forwardedFrom': forwardedFrom,
      'media': media?.toJson(),
      'location': location?.toJson(),
      'contact': contact?.toJson(),
      'replyToMessageId': replyToMessageId,
      'mentions': mentions,
      'reactions': reactions.toJson(),
      'statusInfo': statusInfo.toJson(),
      'starredBy': starredBy,
      'isPinned': isPinned,
      'pinnedBy': pinnedBy,
      'pinnedTimestamp': pinnedTimestamp?.toIso8601String(),
      'isSystemMessage': isSystemMessage,
      'systemMessageData': systemMessageData?.toJson(),
      'encrypted': encrypted,
      'encryptionKey': encryptionKey,
      'selfDestructTimer': selfDestructTimer?.inSeconds,
      'selfDestructTimestamp': selfDestructTimestamp?.toIso8601String(),
      'localId': localId,
      'serverId': serverId,
      'sequenceNumber': sequenceNumber,
      'botId': botId,
      'interactiveButtons': interactiveButtons.map((b) => b.toJson()).toList(),
      'metadata': metadata,
    };
  }

  factory ZeytinXMessage.fromJson(Map<String, dynamic> json) {
    return ZeytinXMessage(
      messageId: json['messageId'] ?? '',
      chatId: json['chatId'] ?? '',
      senderId: json['senderId'] ?? '',
      text: json['text'] ?? '',
      timestamp: DateTime.parse(json['timestamp']),
      messageType: ZeytinXMessageType.values.firstWhere(
        (e) => e.value == json['messageType'],
        orElse: () => ZeytinXMessageType.text,
      ),
      status: ZeytinXMessageStatus.values.firstWhere(
        (e) => e.value == json['status'],
        orElse: () => ZeytinXMessageStatus.sent,
      ),
      isEdited: json['isEdited'] ?? false,
      editedTimestamp: json['editedTimestamp'] != null
          ? DateTime.tryParse(json['editedTimestamp'])
          : null,
      isDeleted: json['isDeleted'] ?? false,
      deletedForEveryone: json['deletedForEveryone'] ?? false,
      isForwarded: json['isForwarded'] ?? false,
      forwardedFrom: json['forwardedFrom'],
      media: json['media'] != null
          ? ZeytinXMediaModel.fromJson(json['media'])
          : null,
      location: json['location'] != null
          ? ZeytinXLocationModel.fromJson(json['location'])
          : null,
      contact: json['contact'] != null
          ? ZeytinXContactModel.fromJson(json['contact'])
          : null,
      replyToMessageId: json['replyToMessageId'],
      mentions: json['mentions'] != null
          ? List<String>.from(json['mentions'])
          : [],
      reactions: json['reactions'] != null
          ? ZeytinXMessageReactionsModel.fromJson(json['reactions'])
          : ZeytinXMessageReactionsModel(),
      statusInfo: json['statusInfo'] != null
          ? ZeytinXMessageStatusInfoModel.fromJson(json['statusInfo'])
          : ZeytinXMessageStatusInfoModel(),
      starredBy: json['starredBy'] != null
          ? List<String>.from(json['starredBy'])
          : [],
      isPinned: json['isPinned'] ?? false,
      pinnedBy: json['pinnedBy'],
      pinnedTimestamp: json['pinnedTimestamp'] != null
          ? DateTime.tryParse(json['pinnedTimestamp'])
          : null,
      isSystemMessage: json['isSystemMessage'] ?? false,
      systemMessageData: json['systemMessageData'] != null
          ? ZeytinXSystemMessageDataModel.fromJson(json['systemMessageData'])
          : null,
      encrypted: json['encrypted'] ?? false,
      encryptionKey: json['encryptionKey'],
      selfDestructTimer: json['selfDestructTimer'] != null
          ? Duration(seconds: json['selfDestructTimer'])
          : null,
      selfDestructTimestamp: json['selfDestructTimestamp'] != null
          ? DateTime.tryParse(json['selfDestructTimestamp'])
          : null,
      localId: json['localId'],
      serverId: json['serverId'],
      sequenceNumber: json['sequenceNumber'] ?? 0,
      botId: json['botId'],
      interactiveButtons: json['interactiveButtons'] != null
          ? (json['interactiveButtons'] as List)
                .map((item) => ZeytinXInteractiveButtonModel.fromJson(item))
                .toList()
          : [],
      metadata: json['metadata'] != null
          ? Map<String, dynamic>.from(json['metadata'])
          : {},
    );
  }

  ZeytinXMessage copyWith({
    String? messageId,
    String? chatId,
    String? senderId,
    String? text,
    DateTime? timestamp,
    ZeytinXMessageType? messageType,
    ZeytinXMessageStatus? status,
    bool? isEdited,
    DateTime? editedTimestamp,
    bool? isDeleted,
    bool? deletedForEveryone,
    bool? isForwarded,
    String? forwardedFrom,
    ZeytinXMediaModel? media,
    ZeytinXLocationModel? location,
    ZeytinXContactModel? contact,
    String? replyToMessageId,
    List<String>? mentions,
    ZeytinXMessageReactionsModel? reactions,
    ZeytinXMessageStatusInfoModel? statusInfo,
    List<String>? starredBy,
    bool? isPinned,
    String? pinnedBy,
    DateTime? pinnedTimestamp,
    bool? isSystemMessage,
    ZeytinXSystemMessageDataModel? systemMessageData,
    bool? encrypted,
    String? encryptionKey,
    Duration? selfDestructTimer,
    DateTime? selfDestructTimestamp,
    String? localId,
    String? serverId,
    int? sequenceNumber,
    String? botId,
    List<ZeytinXInteractiveButtonModel>? interactiveButtons,
    Map<String, dynamic>? metadata,
  }) {
    return ZeytinXMessage(
      messageId: messageId ?? this.messageId,
      chatId: chatId ?? this.chatId,
      senderId: senderId ?? this.senderId,
      text: text ?? this.text,
      timestamp: timestamp ?? this.timestamp,
      messageType: messageType ?? this.messageType,
      status: status ?? this.status,
      isEdited: isEdited ?? this.isEdited,
      editedTimestamp: editedTimestamp ?? this.editedTimestamp,
      isDeleted: isDeleted ?? this.isDeleted,
      deletedForEveryone: deletedForEveryone ?? this.deletedForEveryone,
      isForwarded: isForwarded ?? this.isForwarded,
      forwardedFrom: forwardedFrom ?? this.forwardedFrom,
      media: media ?? this.media,
      location: location ?? this.location,
      contact: contact ?? this.contact,
      replyToMessageId: replyToMessageId ?? this.replyToMessageId,
      mentions: mentions ?? this.mentions,
      reactions: reactions ?? this.reactions,
      statusInfo: statusInfo ?? this.statusInfo,
      starredBy: starredBy ?? this.starredBy,
      isPinned: isPinned ?? this.isPinned,
      pinnedBy: pinnedBy ?? this.pinnedBy,
      pinnedTimestamp: pinnedTimestamp ?? this.pinnedTimestamp,
      isSystemMessage: isSystemMessage ?? this.isSystemMessage,
      systemMessageData: systemMessageData ?? this.systemMessageData,
      encrypted: encrypted ?? this.encrypted,
      encryptionKey: encryptionKey ?? this.encryptionKey,
      selfDestructTimer: selfDestructTimer ?? this.selfDestructTimer,
      selfDestructTimestamp:
          selfDestructTimestamp ?? this.selfDestructTimestamp,
      localId: localId ?? this.localId,
      serverId: serverId ?? this.serverId,
      sequenceNumber: sequenceNumber ?? this.sequenceNumber,
      botId: botId ?? this.botId,
      interactiveButtons: interactiveButtons ?? this.interactiveButtons,
      metadata: metadata ?? this.metadata,
    );
  }
}
