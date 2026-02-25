import 'package:zeytinx/zeytinx.dart';

class ZeytinXForumCategoryModel {
  final String id;
  final String title;
  final String description;
  final String? iconUrl;
  final int order;
  final bool isActive;
  final Map<String, dynamic> moreData;

  ZeytinXForumCategoryModel({
    required this.id,
    required this.title,
    required this.description,
    this.iconUrl,
    this.order = 0,
    this.isActive = true,
    this.moreData = const {},
  });

  factory ZeytinXForumCategoryModel.empty() {
    return ZeytinXForumCategoryModel(id: '', title: '', description: '');
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "title": title,
      "description": description,
      "iconUrl": iconUrl,
      "order": order,
      "isActive": isActive,
      "moreData": moreData,
    };
  }

  factory ZeytinXForumCategoryModel.fromJson(Map<String, dynamic> data) {
    return ZeytinXForumCategoryModel(
      id: data["id"] ?? "",
      title: data["title"] ?? "",
      description: data["description"] ?? "",
      iconUrl: data["iconUrl"],
      order: data["order"] ?? 0,
      isActive: data["isActive"] ?? true,
      moreData: data["moreData"] is Map
          ? Map<String, dynamic>.from(data["moreData"])
          : {},
    );
  }

  ZeytinXForumCategoryModel copyWith({
    String? id,
    String? title,
    String? description,
    String? iconUrl,
    int? order,
    bool? isActive,
    Map<String, dynamic>? moreData,
  }) {
    return ZeytinXForumCategoryModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      iconUrl: iconUrl ?? this.iconUrl,
      order: order ?? this.order,
      isActive: isActive ?? this.isActive,
      moreData: moreData ?? this.moreData,
    );
  }
}

class ZeytinXForumEntryModel {
  final String id;
  final String threadId;
  final ZeytinXUserModel? user;
  final String text;
  final List<String> images;
  final List<String> likes;
  final bool isEdited;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final Map<String, dynamic> moreData;

  ZeytinXForumEntryModel({
    required this.id,
    required this.threadId,
    this.user,
    required this.text,
    this.images = const [],
    this.likes = const [],
    this.isEdited = false,
    this.createdAt,
    this.updatedAt,
    this.moreData = const {},
  });

  factory ZeytinXForumEntryModel.empty() {
    return ZeytinXForumEntryModel(id: '', threadId: '', text: '');
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "threadId": threadId,
      "user": user?.toJson() ?? {},
      "text": text,
      "images": images,
      "likes": likes,
      "isEdited": isEdited,
      "createdAt": createdAt?.toIso8601String(),
      "updatedAt": updatedAt?.toIso8601String(),
      "moreData": moreData,
    };
  }

  factory ZeytinXForumEntryModel.fromJson(Map<String, dynamic> data) {
    return ZeytinXForumEntryModel(
      id: data["id"] ?? "",
      threadId: data["threadId"] ?? "",
      user: data["user"] != null
          ? ZeytinXUserModel.fromJson(data["user"])
          : null,
      text: data["text"] ?? "",
      images: List<String>.from(data["images"] ?? []),
      likes: List<String>.from(data["likes"] ?? []),
      isEdited: data["isEdited"] ?? false,
      createdAt: data["createdAt"] != null
          ? DateTime.tryParse(data["createdAt"])
          : null,
      updatedAt: data["updatedAt"] != null
          ? DateTime.tryParse(data["updatedAt"])
          : null,
      moreData: data["moreData"] is Map
          ? Map<String, dynamic>.from(data["moreData"])
          : {},
    );
  }

  ZeytinXForumEntryModel copyWith({
    String? id,
    String? threadId,
    ZeytinXUserModel? user,
    String? text,
    List<String>? images,
    List<String>? likes,
    bool? isEdited,
    DateTime? createdAt,
    DateTime? updatedAt,
    Map<String, dynamic>? moreData,
  }) {
    return ZeytinXForumEntryModel(
      id: id ?? this.id,
      threadId: threadId ?? this.threadId,
      user: user ?? this.user,
      text: text ?? this.text,
      images: images ?? this.images,
      likes: likes ?? this.likes,
      isEdited: isEdited ?? this.isEdited,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      moreData: moreData ?? this.moreData,
    );
  }
}

class ZeytinXForumThreadModel {
  final String id;
  final String categoryId;
  final ZeytinXUserModel? user;
  final String title;
  final String content;
  final List<String> tags;
  final List<String> images;
  final int viewCount;
  final List<String> likes;
  final List<ZeytinXForumEntryModel> entries;
  final bool isPinned;
  final bool isLocked;
  final bool isResolved;
  final DateTime? createdAt;
  final DateTime? lastActivityAt;
  final Map<String, dynamic> moreData;

  ZeytinXForumThreadModel({
    required this.id,
    required this.categoryId,
    this.user,
    required this.title,
    this.content = '',
    this.tags = const [],
    this.images = const [],
    this.viewCount = 0,
    this.likes = const [],
    this.entries = const [],
    this.isPinned = false,
    this.isLocked = false,
    this.isResolved = false,
    this.createdAt,
    this.lastActivityAt,
    this.moreData = const {},
  });

  factory ZeytinXForumThreadModel.empty() {
    return ZeytinXForumThreadModel(id: '', categoryId: '', title: '');
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "categoryId": categoryId,
      "user": user?.toJson() ?? {},
      "title": title,
      "content": content,
      "tags": tags,
      "images": images,
      "viewCount": viewCount,
      "likes": likes,
      "entries": entries.map((e) => e.toJson()).toList(),
      "isPinned": isPinned,
      "isLocked": isLocked,
      "isResolved": isResolved,
      "createdAt": createdAt?.toIso8601String(),
      "lastActivityAt": lastActivityAt?.toIso8601String(),
      "moreData": moreData,
    };
  }

  factory ZeytinXForumThreadModel.fromJson(Map<String, dynamic> data) {
    return ZeytinXForumThreadModel(
      id: data["id"] ?? "",
      categoryId: data["categoryId"] ?? "",
      user: data["user"] != null
          ? ZeytinXUserModel.fromJson(data["user"])
          : null,
      title: data["title"] ?? "",
      content: data["content"] ?? "",
      tags: List<String>.from(data["tags"] ?? []),
      images: List<String>.from(data["images"] ?? []),
      viewCount: data["viewCount"] ?? 0,
      likes: List<String>.from(data["likes"] ?? []),
      entries: data["entries"] != null
          ? (data["entries"] as List)
                .map((e) => ZeytinXForumEntryModel.fromJson(e))
                .toList()
          : [],
      isPinned: data["isPinned"] ?? false,
      isLocked: data["isLocked"] ?? false,
      isResolved: data["isResolved"] ?? false,
      createdAt: data["createdAt"] != null
          ? DateTime.tryParse(data["createdAt"])
          : null,
      lastActivityAt: data["lastActivityAt"] != null
          ? DateTime.tryParse(data["lastActivityAt"])
          : null,
      moreData: data["moreData"] is Map
          ? Map<String, dynamic>.from(data["moreData"])
          : {},
    );
  }

  ZeytinXForumThreadModel copyWith({
    String? id,
    String? categoryId,
    ZeytinXUserModel? user,
    String? title,
    String? content,
    List<String>? tags,
    List<String>? images,
    int? viewCount,
    List<String>? likes,
    List<ZeytinXForumEntryModel>? entries,
    bool? isPinned,
    bool? isLocked,
    bool? isResolved,
    DateTime? createdAt,
    DateTime? lastActivityAt,
    Map<String, dynamic>? moreData,
  }) {
    return ZeytinXForumThreadModel(
      id: id ?? this.id,
      categoryId: categoryId ?? this.categoryId,
      user: user ?? this.user,
      title: title ?? this.title,
      content: content ?? this.content,
      tags: tags ?? this.tags,
      images: images ?? this.images,
      viewCount: viewCount ?? this.viewCount,
      likes: likes ?? this.likes,
      entries: entries ?? this.entries,
      isPinned: isPinned ?? this.isPinned,
      isLocked: isLocked ?? this.isLocked,
      isResolved: isResolved ?? this.isResolved,
      createdAt: createdAt ?? this.createdAt,
      lastActivityAt: lastActivityAt ?? this.lastActivityAt,
      moreData: moreData ?? this.moreData,
    );
  }
}
