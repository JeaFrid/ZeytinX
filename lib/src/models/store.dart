import 'package:zeytinx/zeytinx.dart';

class ZeytinXStoreModel {
  final String id;
  final String name;
  final String description;
  final String logoUrl;
  final String coverUrl;
  final List<ZeytinXUserModel> owners;
  final String email;
  final String phoneNumber;
  final String address;
  final String website;
  final double rating;
  final int followerCount;
  final bool isVerified;
  final DateTime? createdAt;
  final Map<String, dynamic> moreData;

  ZeytinXStoreModel({
    required this.id,
    required this.name,
    required this.description,
    required this.owners,
    this.logoUrl = '',
    this.coverUrl = '',
    this.email = '',
    this.phoneNumber = '',
    this.address = '',
    this.website = '',
    this.rating = 0.0,
    this.followerCount = 0,
    this.isVerified = false,
    this.createdAt,
    this.moreData = const {},
  });

  factory ZeytinXStoreModel.empty() {
    return ZeytinXStoreModel(id: '', name: '', description: '', owners: []);
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "name": name,
      "description": description,
      "logoUrl": logoUrl,
      "coverUrl": coverUrl,
      "owners": owners.map((e) => e.toJson()).toList(),
      "email": email,
      "phoneNumber": phoneNumber,
      "address": address,
      "website": website,
      "rating": rating,
      "followerCount": followerCount,
      "isVerified": isVerified,
      "createdAt": createdAt?.toIso8601String(),
      "moreData": moreData,
    };
  }

  factory ZeytinXStoreModel.fromJson(Map<String, dynamic> data) {
    return ZeytinXStoreModel(
      id: data["id"] ?? "",
      name: data["name"] ?? "",
      description: data["description"] ?? "",
      logoUrl: data["logoUrl"] ?? "",
      coverUrl: data["coverUrl"] ?? "",
      owners: data["owners"] != null
          ? (data["owners"] as List)
                .map((e) => ZeytinXUserModel.fromJson(e))
                .toList()
          : [],
      email: data["email"] ?? "",
      phoneNumber: data["phoneNumber"] ?? "",
      address: data["address"] ?? "",
      website: data["website"] ?? "",
      rating: (data["rating"] ?? 0.0).toDouble(),
      followerCount: data["followerCount"] ?? 0,
      isVerified: data["isVerified"] ?? false,
      createdAt: data["createdAt"] != null
          ? DateTime.tryParse(data["createdAt"])
          : null,
      moreData: data["moreData"] is Map
          ? Map<String, dynamic>.from(data["moreData"])
          : {},
    );
  }

  ZeytinXStoreModel copyWith({
    String? id,
    String? name,
    String? description,
    String? logoUrl,
    String? coverUrl,
    List<ZeytinXUserModel>? owners,
    String? email,
    String? phoneNumber,
    String? address,
    String? website,
    double? rating,
    int? followerCount,
    bool? isVerified,
    DateTime? createdAt,
    Map<String, dynamic>? moreData,
  }) {
    return ZeytinXStoreModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      logoUrl: logoUrl ?? this.logoUrl,
      coverUrl: coverUrl ?? this.coverUrl,
      owners: owners ?? this.owners,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      address: address ?? this.address,
      website: website ?? this.website,
      rating: rating ?? this.rating,
      followerCount: followerCount ?? this.followerCount,
      isVerified: isVerified ?? this.isVerified,
      createdAt: createdAt ?? this.createdAt,
      moreData: moreData ?? this.moreData,
    );
  }
}
