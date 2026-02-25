import 'package:zeytinx/zeytinx.dart';

class ZeytinXSocialCommentsModel {
  final ZeytinXUserModel? user;
  final String? text;
  final String? id;
  final String? postID;
  final List<String>? likes;
  final Map<String, dynamic>? moreData;
  ZeytinXSocialCommentsModel({
    this.user,
    this.text,
    this.likes,
    this.postID,
    this.id,
    this.moreData,
  });

  Map<String, dynamic> toJson() {
    return {
      "user": user?.toJson() ?? {},
      "text": text ?? "",
      "id": id ?? "",
      "likes": likes ?? [],
      "post": postID ?? "",
      "moreData": moreData ?? {},
    };
  }

  ZeytinXSocialCommentsModel copyWith({
    ZeytinXUserModel? user,
    String? text,
    List<String>? likes,
    String? postID,
    String? id,
    Map<String, dynamic>? moreData,
  }) {
    return ZeytinXSocialCommentsModel(
      user: user ?? this.user,
      text: text ?? this.text,
      likes: likes ?? this.likes,
      postID: postID ?? this.postID,
      id: id ?? this.id,
      moreData: moreData ?? this.moreData,
    );
  }

  factory ZeytinXSocialCommentsModel.fromJson(Map<String, dynamic> data) {
    return ZeytinXSocialCommentsModel(
      user: data["user"] != null
          ? ZeytinXUserModel.fromJson(data["user"])
          : null,
      text: data["text"],
      likes: (data["likes"] as List?)?.cast<String>() ?? [],
      postID: data["postID"] ?? "",
      id: data["id"],
      moreData: data["moreData"] ?? {},
    );
  }
}

class ZeytinXSocialModel {
  final ZeytinXUserModel? user;
  final String? text;
  final String? id;
  String? category;
  final List<dynamic>? images;
  final List<dynamic>? docs;
  final List<dynamic>? locations;
  final List<dynamic>? likes;
  final List<ZeytinXSocialCommentsModel>? comments;
  final Map<String, dynamic>? moreData;
  ZeytinXSocialModel({
    this.moreData,
    this.user,
    this.category,
    this.text,
    this.images,
    this.docs,
    this.locations,
    this.id,
    this.likes,
    this.comments,
  });
  Map<String, dynamic> toJson() {
    List<Map<String, dynamic>> coms = [];
    if (comments != null) {
      for (var element in comments!) {
        coms.add(element.toJson());
      }
    }

    return {
      "user": user?.toJson() ?? {},
      "text": text ?? "",
      "images": images ?? [],
      "docs": docs ?? [],
      "category": category ?? "",
      "locations": locations ?? [],
      "id": id ?? "",
      "moreData": moreData ?? {},
      "likes": likes ?? [],
      "comments": comments == null ? [] : coms,
    };
  }

  ZeytinXSocialModel copyWith({
    ZeytinXUserModel? user,
    String? text,
    String? category,
    String? id,
    List<dynamic>? images,
    List<dynamic>? docs,
    List<dynamic>? locations,
    List<dynamic>? likes,
    List<ZeytinXSocialCommentsModel>? comments,
    Map<String, dynamic>? moreData,
  }) {
    return ZeytinXSocialModel(
      user: user ?? this.user,
      text: text ?? this.text,
      category: category ?? this.category,
      images: images ?? this.images,
      docs: docs ?? this.docs,
      locations: locations ?? this.locations,
      id: id ?? this.id,
      likes: likes ?? this.likes,
      comments: comments ?? this.comments,
      moreData: moreData ?? this.moreData,
    );
  }

  factory ZeytinXSocialModel.fromJson(Map<String, dynamic> data) {
    List<ZeytinXSocialCommentsModel> coms = [];
    if (data["comments"] is List) {
      for (var element in data["comments"]) {
        coms.add(ZeytinXSocialCommentsModel.fromJson(element));
      }
    }

    return ZeytinXSocialModel(
      user: ZeytinXUserModel.fromJson(data["user"]),
      text: data["text"] ?? "",
      images: data["images"] ?? [],
      category: data["category"] ?? "",
      docs: data["docs"] ?? [],
      locations: data["locations"] ?? [],
      id: data["id"] ?? "",
      likes: (data["likes"] as List?)?.cast<String>() ?? [],
      comments: coms,
      moreData: data["moreData"] ?? {},
    );
  }
}
