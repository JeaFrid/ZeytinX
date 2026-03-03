import 'dart:async';
import 'package:uuid/uuid.dart';
import 'package:zeytinx/zeytinx.dart';

class ZeytinXCommunity {
  final ZeytinX zeytin;
  static const String _communityBox = 'communities';
  static const String _messagesBox = 'messages';
  static const String _roomsBox = 'community_rooms';
  static const String _boardsBox = 'community_boards';
  static const String _invitesBox = 'community_invites';
  static const String _myCommunitiesBox = 'my_communities';
  final _uuid = const Uuid();

  ZeytinXCommunity(this.zeytin);

  Future<ZeytinXResponse> createCommunity({
    required String name,
    required List<ZeytinXUserModel> participants,
    required ZeytinXUserModel creator,
    String? description,
    String? photoURL,
    Map<String, dynamic>? moreDataMap,
  }) async {
    try {
      final communityId = _uuid.v4();
      final now = DateTime.now();
      if (!participants.any((p) => p.uid == creator.uid)) {
        participants.add(creator);
      }

      final newCommunity = ZeytinXCommunityModel.empty().copyWith(
        id: communityId,
        name: name,
        description: description,
        photoURL: photoURL,
        createdAt: now,
        participants: participants,
        admins: [creator],
        moreData: moreDataMap?.toString(),
      );

      var response = await zeytin.add(
        box: _communityBox,
        tag: communityId,
        value: newCommunity.toJson(),
      );

      if (response.isSuccess) {
        await _indexCommunityForParticipants(communityId, participants);
        return ZeytinXResponse(
          isSuccess: true,
          message: "Community created successfully",
          data: newCommunity.toJson(),
        );
      }

      return response;
    } catch (e) {
      return ZeytinXResponse(
        isSuccess: false,
        message: "Error creating community: $e",
      );
    }
  }

  Future<ZeytinXResponse> deleteCommunityAndContents({
    required String communityId,
    required ZeytinXUserModel admin,
  }) async {
    try {
      ZeytinXCommunityModel? community = await getCommunity(id: communityId);

      if (community == null) {
        return ZeytinXResponse(
          isSuccess: false,
          message: "Community not found",
        );
      }

      if (!community.admins.any((a) => a.uid == admin.uid)) {
        return ZeytinXResponse(isSuccess: false, message: "Not authorized");
      }

      var messagesRes = await zeytin.filter(
        box: _messagesBox,
        predicate: (data) => data["chatId"] == communityId,
      );

      if (messagesRes.isSuccess &&
          messagesRes.data != null &&
          messagesRes.data!['results'] != null) {
        for (var item in messagesRes.data!['results']) {
          if (item['tag'] != null) {
            await zeytin.remove(box: _messagesBox, tag: item['tag']);
          }
        }
      }

      final rooms = await getCommunityRooms(communityId: communityId);
      for (var room in rooms) {
        await zeytin.remove(box: _roomsBox, tag: room.id);
      }

      final posts = await getBoardPosts(communityId: communityId);
      for (var post in posts) {
        await zeytin.remove(box: _boardsBox, tag: post.id);
      }

      for (var user in community.participants) {
        var userComsRes = await zeytin.get(
          box: _myCommunitiesBox,
          tag: user.uid,
        );

        if (userComsRes.isSuccess &&
            userComsRes.data != null &&
            userComsRes.data!['value'] != null) {
          List<String> currentIds = List<String>.from(
            userComsRes.data!['value']["communityIds"] ?? [],
          );
          if (currentIds.contains(communityId)) {
            currentIds.remove(communityId);
            await zeytin.add(box: _myCommunitiesBox, tag: user.uid, value: {
              "communityIds": currentIds,
            });
          }
        }
      }

      return await zeytin.remove(
        box: _communityBox,
        tag: communityId,
      );
    } catch (e) {
      return ZeytinXResponse(isSuccess: false, message: e.toString());
    }
  }

  Future<ZeytinXResponse> createInviteCode({
    required String communityId,
    required ZeytinXUserModel admin,
    String? customCode,
    Duration? duration,
    int? maxUses,
    Map<String, dynamic>? moreData,
  }) async {
    try {
      ZeytinXCommunityModel? community = await getCommunity(id: communityId);

      if (community == null) {
        return ZeytinXResponse(
          isSuccess: false,
          message: "Community not found",
        );
      }

      if (!community.admins.any((a) => a.uid == admin.uid)) {
        return ZeytinXResponse(isSuccess: false, message: "Not authorized");
      }

      final String code = customCode ?? _uuid.v4().substring(0, 8);
      final DateTime now = DateTime.now();
      final DateTime? expiresAt = duration != null ? now.add(duration) : null;

      final invite = ZeytinXCommunityInviteModel(
        code: code,
        communityId: communityId,
        creatorId: admin.uid,
        createdAt: now,
        expiresAt: expiresAt,
        maxUses: maxUses,
        usedCount: 0,
        moreData: moreData ?? {},
      );

      var response = await zeytin.add(
        box: _invitesBox,
        tag: code,
        value: invite.toJson(),
      );

      if (response.isSuccess) {
        return ZeytinXResponse(
          isSuccess: true,
          message: "Created",
          data: invite.toJson(),
        );
      }

      return response;
    } catch (e) {
      return ZeytinXResponse(isSuccess: false, message: e.toString());
    }
  }

  Future<List<ZeytinXCommunityInviteModel>> getInviteCodes({
    required String communityId,
  }) async {
    List<ZeytinXCommunityInviteModel> invites = [];
    var res = await zeytin.filter(
      box: _invitesBox,
      predicate: (data) => data["communityId"] == communityId,
    );

    if (res.isSuccess && res.data != null && res.data!['results'] != null) {
      for (var item in res.data!['results']) {
        if (item['value'] != null) {
          invites.add(ZeytinXCommunityInviteModel.fromJson(item['value']));
        }
      }
    }
    return invites;
  }

  Future<ZeytinXResponse> validateInviteCode({required String code}) async {
    try {
      ZeytinXCommunityInviteModel? invite = await getInvite(code: code);

      if (invite == null) {
        return ZeytinXResponse(isSuccess: false, message: "Invalid code");
      }
      if (invite.isExpired) {
        return ZeytinXResponse(isSuccess: false, message: "Code expired");
      }
      if (invite.isQuotaExceeded) {
        return ZeytinXResponse(isSuccess: false, message: "Quota exceeded");
      }

      return ZeytinXResponse(
        isSuccess: true,
        message: "Valid",
        data: invite.toJson(),
      );
    } catch (e) {
      return ZeytinXResponse(isSuccess: false, message: e.toString());
    }
  }

  Future<ZeytinXCommunityInviteModel?> getInvite({required String code}) async {
    var res = await zeytin.get(
      box: _invitesBox,
      tag: code,
    );

    if (res.isSuccess && res.data != null && res.data!['value'] != null) {
      return ZeytinXCommunityInviteModel.fromJson(res.data!['value']);
    }
    return null;
  }

  Future<ZeytinXResponse> useInviteCode({required String code}) async {
    try {
      ZeytinXCommunityInviteModel? invite = await getInvite(code: code);
      if (invite == null) {
        return ZeytinXResponse(isSuccess: false, message: "Code not found");
      }
      if (!invite.isValid) {
        return ZeytinXResponse(
          isSuccess: false,
          message: "Code is not valid anymore",
        );
      }

      invite = invite.copyWith(usedCount: invite.usedCount + 1);

      return await zeytin.add(
        box: _invitesBox,
        tag: code,
        value: invite.toJson(),
      );
    } catch (e) {
      return ZeytinXResponse(isSuccess: false, message: e.toString());
    }
  }

  Future<ZeytinXResponse> deleteInviteCode({
    required String code,
    required String communityId,
    required ZeytinXUserModel admin,
  }) async {
    try {
      ZeytinXCommunityModel? community = await getCommunity(id: communityId);
      if (community == null) {
        return ZeytinXResponse(
          isSuccess: false,
          message: "Community not found",
        );
      }
      if (!community.admins.any((a) => a.uid == admin.uid)) {
        return ZeytinXResponse(isSuccess: false, message: "Not authorized");
      }

      return await zeytin.remove(
        box: _invitesBox,
        tag: code,
      );
    } catch (e) {
      return ZeytinXResponse(isSuccess: false, message: e.toString());
    }
  }

  Future<ZeytinXResponse> createRoom({
    required String communityId,
    required ZeytinXUserModel admin,
    required String roomName,
    ZeytinXRoomType type = ZeytinXRoomType.text,
  }) async {
    try {
      ZeytinXCommunityModel? community = await getCommunity(id: communityId);
      if (community == null) {
        return ZeytinXResponse(
          isSuccess: false,
          message: "Community not found",
        );
      }
      if (!community.admins.any((a) => a.uid == admin.uid)) {
        return ZeytinXResponse(
          isSuccess: false,
          message: "Only admins can create rooms",
        );
      }

      final roomId = _uuid.v4();
      final newRoom = ZeytinXCommunityRoomModel(
        id: roomId,
        communityId: communityId,
        name: roomName,
        type: type,
        createdAt: DateTime.now(),
      );

      return await zeytin.add(
          box: _roomsBox, tag: roomId, value: newRoom.toJson());
    } catch (e) {
      return ZeytinXResponse(isSuccess: false, message: e.toString());
    }
  }

  Future<ZeytinXCommunityRoomModel?> getRoom({required String roomId}) async {
    var res = await zeytin.get(
      box: _roomsBox,
      tag: roomId,
    );

    if (res.isSuccess && res.data != null && res.data!['value'] != null) {
      return ZeytinXCommunityRoomModel.fromJson(res.data!['value']);
    }

    return null;
  }

  Future<List<ZeytinXCommunityRoomModel>> getCommunityRooms({
    required String communityId,
  }) async {
    List<ZeytinXCommunityRoomModel> rooms = [];
    var res = await zeytin.filter(
      box: _roomsBox,
      predicate: (data) => data["communityId"] == communityId,
    );

    if (res.isSuccess && res.data != null && res.data!['results'] != null) {
      for (var item in res.data!['results']) {
        if (item['value'] != null) {
          rooms.add(ZeytinXCommunityRoomModel.fromJson(item['value']));
        }
      }
    }

    rooms.sort((a, b) => a.createdAt.compareTo(b.createdAt));
    return rooms;
  }

  Future<ZeytinXResponse> editCommunity({
    required String communityId,
    required ZeytinXUserModel admin,
    required ZeytinXCommunityModel updatedCommunity,
  }) async {
    try {
      ZeytinXCommunityModel? currentCommunity = await getCommunity(
        id: communityId,
      );
      if (currentCommunity == null) {
        return ZeytinXResponse(
          isSuccess: false,
          message: "Community not found",
        );
      }
      if (!currentCommunity.admins.any((a) => a.uid == admin.uid)) {
        return ZeytinXResponse(isSuccess: false, message: "Not authorized");
      }
      if (updatedCommunity.id != communityId) {
        return ZeytinXResponse(
          isSuccess: false,
          message: "Community ID mismatch",
        );
      }

      return await zeytin.add(
          box: _communityBox,
          tag: communityId,
          value: updatedCommunity.toJson());
    } catch (e) {
      return ZeytinXResponse(isSuccess: false, message: e.toString());
    }
  }

  Future<List<ZeytinXCommunityModel>> getAllCommunities() async {
    List<ZeytinXCommunityModel> list = [];
    var res = await zeytin.getBox(
      box: _communityBox,
    );

    if (res.isSuccess && res.data != null) {
      res.data!.forEach((key, value) {
        if (value != null) {
          list.add(ZeytinXCommunityModel.fromJson(value));
        }
      });
    }

    list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return list;
  }

  Future<void> _indexCommunityForParticipants(
    String communityId,
    List<ZeytinXUserModel> participants,
  ) async {
    for (var user in participants) {
      var userCommunitiesRes = await zeytin.get(
        box: _myCommunitiesBox,
        tag: user.uid,
      );

      List<String> currentCommunityIds = [];
      if (userCommunitiesRes.isSuccess &&
          userCommunitiesRes.data != null &&
          userCommunitiesRes.data!['value'] != null) {
        currentCommunityIds = List<String>.from(
          userCommunitiesRes.data!['value']["communityIds"] ?? [],
        );
      }

      if (!currentCommunityIds.contains(communityId)) {
        currentCommunityIds.add(communityId);
        await zeytin.add(box: _myCommunitiesBox, tag: user.uid, value: {
          "communityIds": currentCommunityIds,
        });
      }
    }
  }

  Future<ZeytinXResponse> setRules({
    required String communityId,
    required ZeytinXUserModel admin,
    required String rules,
  }) async {
    try {
      ZeytinXCommunityModel? community = await getCommunity(id: communityId);
      if (community == null) {
        return ZeytinXResponse(
          isSuccess: false,
          message: "Community not found",
        );
      }
      if (!community.admins.any((a) => a.uid == admin.uid)) {
        return ZeytinXResponse(isSuccess: false, message: "Not authorized");
      }

      community = community.copyWith(rules: rules);
      return await zeytin.add(
          box: _communityBox, tag: communityId, value: community.toJson());
    } catch (e) {
      return ZeytinXResponse(isSuccess: false, message: e.toString());
    }
  }

  Future<String?> getRules({required String communityId}) async {
    ZeytinXCommunityModel? community = await getCommunity(id: communityId);
    return community?.rules;
  }

  Future<ZeytinXResponse> setStickers({
    required String communityId,
    required ZeytinXUserModel admin,
    required List<String> stickers,
  }) async {
    try {
      ZeytinXCommunityModel? community = await getCommunity(id: communityId);
      if (community == null) {
        return ZeytinXResponse(
          isSuccess: false,
          message: "Community not found",
        );
      }
      if (!community.admins.any((a) => a.uid == admin.uid)) {
        return ZeytinXResponse(isSuccess: false, message: "Not authorized");
      }

      community = community.copyWith(stickers: stickers);
      return await zeytin.add(
          box: _communityBox, tag: communityId, value: community.toJson());
    } catch (e) {
      return ZeytinXResponse(isSuccess: false, message: e.toString());
    }
  }

  Future<List<String>> getStickers({required String communityId}) async {
    ZeytinXCommunityModel? community = await getCommunity(id: communityId);
    return community?.stickers ?? [];
  }

  Future<ZeytinXResponse> setPinnedPost({
    required String communityId,
    required ZeytinXUserModel admin,
    required String postId,
  }) async {
    try {
      ZeytinXCommunityModel? community = await getCommunity(id: communityId);
      if (community == null) {
        return ZeytinXResponse(
          isSuccess: false,
          message: "Community not found",
        );
      }
      if (!community.admins.any((a) => a.uid == admin.uid)) {
        return ZeytinXResponse(isSuccess: false, message: "Not authorized");
      }

      bool postExists = false;
      var res = await zeytin.get(
        box: _boardsBox,
        tag: postId,
      );
      if (res.isSuccess && res.data != null && res.data!['value'] != null) {
        postExists = true;
      }

      if (!postExists) {
        return ZeytinXResponse(isSuccess: false, message: "Post not found");
      }

      community = community.copyWith(pinnedPostID: postId);
      return await zeytin.add(
          box: _communityBox, tag: communityId, value: community.toJson());
    } catch (e) {
      return ZeytinXResponse(isSuccess: false, message: e.toString());
    }
  }

  Future<ZeytinXResponse> deletePinnedPost({
    required String communityId,
    required ZeytinXUserModel admin,
  }) async {
    try {
      ZeytinXCommunityModel? community = await getCommunity(id: communityId);
      if (community == null) {
        return ZeytinXResponse(
          isSuccess: false,
          message: "Community not found",
        );
      }
      if (!community.admins.any((a) => a.uid == admin.uid)) {
        return ZeytinXResponse(isSuccess: false, message: "Not authorized");
      }

      community = community.copyWith(pinnedPostID: null);
      return await zeytin.add(
          box: _communityBox, tag: communityId, value: community.toJson());
    } catch (e) {
      return ZeytinXResponse(isSuccess: false, message: e.toString());
    }
  }

  Future<ZeytinXCommunityBoardPostModel?> getPinnedPost({
    required String communityId,
  }) async {
    try {
      ZeytinXCommunityModel? community = await getCommunity(id: communityId);
      if (community == null || community.pinnedPostID == null) return null;

      var res = await zeytin.get(
        box: _boardsBox,
        tag: community.pinnedPostID!,
      );

      if (res.isSuccess && res.data != null && res.data!['value'] != null) {
        return ZeytinXCommunityBoardPostModel.fromJson(res.data!['value']);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<List<ZeytinXCommunityModel>> getCommunitiesForUser({
    required ZeytinXUserModel user,
  }) async {
    List<ZeytinXCommunityModel> userCommunities = [];
    var indexRes = await zeytin.get(
      box: _myCommunitiesBox,
      tag: user.uid,
    );

    if (indexRes.isSuccess &&
        indexRes.data != null &&
        indexRes.data!['value'] != null) {
      List<String> communityIds = List<String>.from(
        indexRes.data!['value']["communityIds"] ?? [],
      );
      for (var id in communityIds) {
        var communityData = await zeytin.get(
          box: _communityBox,
          tag: id,
        );
        if (communityData.isSuccess &&
            communityData.data != null &&
            communityData.data!['value'] != null) {
          userCommunities.add(
            ZeytinXCommunityModel.fromJson(communityData.data!['value']),
          );
        }
      }
    }

    userCommunities.sort(
      (a, b) => b.lastMessageTimestamp.compareTo(a.lastMessageTimestamp),
    );
    return userCommunities;
  }

  Future<ZeytinXCommunityModel?> getCommunity({required String id}) async {
    var res = await zeytin.get(
      box: _communityBox,
      tag: id,
    );

    if (res.isSuccess && res.data != null && res.data!['value'] != null) {
      return ZeytinXCommunityModel.fromJson(res.data!['value']);
    }
    return null;
  }

  Future<bool?> isParticipant({
    required String communityId,
    required ZeytinXUserModel user,
  }) async {
    ZeytinXCommunityModel? community = await getCommunity(id: communityId);
    if (community == null) return null;
    return community.participants.any((p) => p.uid == user.uid);
  }

  Future<bool?> isAdmin({
    required String communityId,
    required ZeytinXUserModel user,
  }) async {
    ZeytinXCommunityModel? community = await getCommunity(id: communityId);
    if (community == null) return null;
    return community.admins.any((p) => p.uid == user.uid);
  }

  Future<ZeytinXResponse> joinCommunity({
    required String communityId,
    required ZeytinXUserModel user,
  }) async {
    try {
      ZeytinXCommunityModel? community = await getCommunity(id: communityId);
      if (community == null) {
        return ZeytinXResponse(
          isSuccess: false,
          message: "Community not found",
        );
      }

      final participants = community.participants;
      if (participants.any((p) => p.uid == user.uid)) {
        return ZeytinXResponse(isSuccess: true, message: "Already a member");
      }

      participants.add(user);
      final updatedCommunity = community.copyWith(participants: participants);

      var response = await zeytin.add(
          box: _communityBox,
          tag: communityId,
          value: updatedCommunity.toJson());

      if (response.isSuccess) {
        await _indexCommunityForParticipants(communityId, [user]);
      }
      return response;
    } catch (e) {
      return ZeytinXResponse(isSuccess: false, message: e.toString());
    }
  }

  Future<List<ZeytinXUserModel>> getParticipants({
    required String communityId,
  }) async {
    ZeytinXCommunityModel? community = await getCommunity(id: communityId);
    return community?.participants ?? [];
  }

  Future<List<ZeytinXUserModel>> getAdmins({
    required String communityId,
  }) async {
    ZeytinXCommunityModel? community = await getCommunity(id: communityId);
    return community?.admins ?? [];
  }

  Future<ZeytinXResponse> leaveCommunity({
    required String communityId,
    required ZeytinXUserModel user,
  }) async {
    try {
      ZeytinXCommunityModel? community = await getCommunity(id: communityId);
      if (community == null) {
        return ZeytinXResponse(
          isSuccess: false,
          message: "Community not found",
        );
      }

      final participants =
          community.participants.where((p) => p.uid != user.uid).toList();
      final updatedCommunity = community.copyWith(participants: participants);

      var response = await zeytin.add(
          box: _communityBox,
          tag: communityId,
          value: updatedCommunity.toJson());

      if (response.isSuccess) {
        var userComsRes = await zeytin.get(
          box: _myCommunitiesBox,
          tag: user.uid,
        );

        if (userComsRes.isSuccess &&
            userComsRes.data != null &&
            userComsRes.data!['value'] != null) {
          List<String> currentIds = List<String>.from(
            userComsRes.data!['value']["communityIds"] ?? [],
          );
          currentIds.remove(communityId);
          await zeytin.add(box: _myCommunitiesBox, tag: user.uid, value: {
            "communityIds": currentIds,
          });
        }
      }

      return response;
    } catch (e) {
      return ZeytinXResponse(isSuccess: false, message: e.toString());
    }
  }

  Future<ZeytinXResponse> sendMessage({
    required String communityId,
    required ZeytinXUserModel sender,
    required String text,
    ZeytinXMessageType messageType = ZeytinXMessageType.text,
    ZeytinXMediaModel? media,
    ZeytinXLocationModel? location,
    ZeytinXContactModel? contact,
    String? replyToMessageId,
    List<String>? mentions,
    Duration? selfDestructTimer,
    String? botId,
    List<ZeytinXInteractiveButtonModel>? interactiveButtons,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      final messageId = _uuid.v4();
      final now = DateTime.now();
      final selfDestructTimestamp =
          selfDestructTimer != null ? now.add(selfDestructTimer) : null;

      final message = ZeytinXMessage(
        messageId: messageId,
        chatId: communityId,
        senderId: sender.uid,
        text: text,
        timestamp: now,
        messageType: messageType,
        status: ZeytinXMessageStatus.sent,
        media: media,
        location: location,
        contact: contact,
        replyToMessageId: replyToMessageId,
        mentions: mentions,
        selfDestructTimer: selfDestructTimer,
        selfDestructTimestamp: selfDestructTimestamp,
        botId: botId,
        interactiveButtons: interactiveButtons,
        metadata: metadata,
      );

      var response = await zeytin.add(
          box: _messagesBox, tag: messageId, value: message.toJson());

      if (response.isSuccess) {
        await _updateCommunityLastMessage(communityId, message, sender);
      }

      return response;
    } catch (e) {
      return ZeytinXResponse(isSuccess: false, message: e.toString());
    }
  }

  Future<void> _updateCommunityLastMessage(
    String communityId,
    ZeytinXMessage message,
    ZeytinXUserModel sender,
  ) async {
    ZeytinXCommunityModel? community = await getCommunity(id: communityId);
    if (community == null) return;

    community = community.copyWith(
      lastMessage: message.messageType == ZeytinXMessageType.text
          ? message.text
          : message.messageType.value,
      lastMessageTimestamp: message.timestamp,
      lastMessageSender: sender,
    );

    await zeytin.add(
        box: _communityBox, tag: communityId, value: community.toJson());
  }

  Future<ZeytinXMessage?> getMessage({required String messageId}) async {
    var res = await zeytin.get(
      box: _messagesBox,
      tag: messageId,
    );

    if (res.isSuccess && res.data != null && res.data!['value'] != null) {
      return ZeytinXMessage.fromJson(res.data!['value']);
    }

    return null;
  }

  Future<List<ZeytinXMessage>> getMessages({
    required String communityId,
    int? limit,
    int? offset,
  }) async {
    List<ZeytinXMessage> messages = [];
    var res = await zeytin.filter(
      box: _messagesBox,
      predicate: (data) => data["chatId"] == communityId,
    );

    if (res.isSuccess && res.data != null && res.data!['results'] != null) {
      for (var item in res.data!['results']) {
        if (item['value'] != null) {
          messages.add(ZeytinXMessage.fromJson(item['value']));
        }
      }
    }

    messages.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    final startIndex = offset ?? 0;
    final endIndex = limit != null
        ? (startIndex + limit).clamp(0, messages.length)
        : messages.length;

    if (startIndex >= messages.length) return [];
    return messages.sublist(startIndex, endIndex).reversed.toList();
  }

  Future<ZeytinXResponse> editMessage({
    required String messageId,
    required String newText,
  }) async {
    try {
      ZeytinXMessage? message = await getMessage(messageId: messageId);
      if (message == null) {
        return ZeytinXResponse(isSuccess: false, message: "Message not found");
      }
      if (message.isDeleted) {
        return ZeytinXResponse(
          isSuccess: false,
          message: "Cannot edit deleted message",
        );
      }

      message = message.copyWith(
        text: newText,
        isEdited: true,
        editedTimestamp: DateTime.now(),
      );

      return await zeytin.add(
          box: _messagesBox, tag: messageId, value: message.toJson());
    } catch (e) {
      return ZeytinXResponse(isSuccess: false, message: e.toString());
    }
  }

  Future<ZeytinXResponse> deleteMessage({
    required String messageId,
    required String userId,
    bool deleteForEveryone = false,
  }) async {
    try {
      ZeytinXMessage? message = await getMessage(messageId: messageId);
      if (message == null) {
        return ZeytinXResponse(isSuccess: false, message: "Message not found");
      }
      if (message.senderId != userId && !deleteForEveryone) {
        return ZeytinXResponse(isSuccess: false, message: "Not authorized");
      }

      message = message.copyWith(
        isDeleted: true,
        deletedForEveryone: deleteForEveryone,
      );

      return await zeytin.add(
          box: _messagesBox, tag: messageId, value: message.toJson());
    } catch (e) {
      return ZeytinXResponse(isSuccess: false, message: e.toString());
    }
  }

  Future<ZeytinXResponse> forwardMessage({
    required String originalMessageId,
    required String targetCommunityId,
    required ZeytinXUserModel sender,
  }) async {
    try {
      ZeytinXMessage? originalMessage = await getMessage(
        messageId: originalMessageId,
      );
      if (originalMessage == null) {
        return ZeytinXResponse(isSuccess: false, message: "Message not found");
      }

      final newMessageId = _uuid.v4();
      final now = DateTime.now();
      final forwardedMessage = ZeytinXMessage(
        messageId: newMessageId,
        chatId: targetCommunityId,
        senderId: sender.uid,
        text: originalMessage.text,
        timestamp: now,
        messageType: originalMessage.messageType,
        status: ZeytinXMessageStatus.sent,
        isForwarded: true,
        forwardedFrom: originalMessage.senderId,
        media: originalMessage.media,
        location: originalMessage.location,
        contact: originalMessage.contact,
        mentions: originalMessage.mentions,
      );

      var response = await zeytin.add(
          box: _messagesBox,
          tag: newMessageId,
          value: forwardedMessage.toJson());

      if (response.isSuccess) {
        await _updateCommunityLastMessage(
          targetCommunityId,
          forwardedMessage,
          sender,
        );
      }

      return response;
    } catch (e) {
      return ZeytinXResponse(isSuccess: false, message: e.toString());
    }
  }

  Future<List<ZeytinXMessage>> searchMessages({
    required String communityId,
    required String query,
  }) async {
    final allMessages = await getMessages(
      communityId: communityId,
      limit: 1000,
    );
    return allMessages
        .where(
          (m) =>
              !m.isDeleted &&
              m.text.toLowerCase().contains(query.toLowerCase()),
        )
        .toList();
  }

  Future<ZeytinXResponse> starMessage({
    required String messageId,
    required String userId,
  }) async {
    ZeytinXMessage? message = await getMessage(messageId: messageId);
    if (message == null) {
      return ZeytinXResponse(isSuccess: false, message: "Message not found");
    }

    final starredBy = List<String>.from(message.starredBy);
    if (!starredBy.contains(userId)) {
      starredBy.add(userId);
      message = message.copyWith(starredBy: starredBy);

      return await zeytin.add(
          box: _messagesBox, tag: messageId, value: message.toJson());
    }
    return ZeytinXResponse(isSuccess: true, message: "Already starred");
  }

  Future<ZeytinXResponse> unstarMessage({
    required String messageId,
    required String userId,
  }) async {
    ZeytinXMessage? message = await getMessage(messageId: messageId);
    if (message == null) {
      return ZeytinXResponse(isSuccess: false, message: "Message not found");
    }

    final starredBy = List<String>.from(message.starredBy);
    if (starredBy.contains(userId)) {
      starredBy.remove(userId);
      message = message.copyWith(starredBy: starredBy);
      return await zeytin.add(
          box: _messagesBox, tag: messageId, value: message.toJson());
    }
    return ZeytinXResponse(isSuccess: true, message: "Not starred");
  }

  Future<List<ZeytinXMessage>> getStarredMessages({
    required String userId,
  }) async {
    List<ZeytinXMessage> starred = [];
    var res = await zeytin.getBox(
      box: _messagesBox,
    );

    if (res.isSuccess && res.data != null) {
      res.data!.forEach((key, value) {
        if (value != null) {
          final m = ZeytinXMessage.fromJson(value);
          if (m.starredBy.contains(userId) && !m.isDeleted) starred.add(m);
        }
      });
    }

    starred.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return starred;
  }

  Future<ZeytinXResponse> pinMessage({
    required String messageId,
    required String pinnedBy,
    required String communityId,
  }) async {
    ZeytinXMessage? message = await getMessage(messageId: messageId);
    if (message == null) {
      return ZeytinXResponse(isSuccess: false, message: "Message not found");
    }
    if (message.chatId != communityId) {
      return ZeytinXResponse(
        isSuccess: false,
        message: "Message not in this community",
      );
    }

    message = message.copyWith(
      isPinned: true,
      pinnedBy: pinnedBy,
      pinnedTimestamp: DateTime.now(),
    );

    ZeytinXCommunityModel? community = await getCommunity(id: communityId);
    if (community != null) {
      final pinnedIDs = List<String>.from(community.pinnedMessageIDs);
      if (!pinnedIDs.contains(messageId)) {
        pinnedIDs.add(messageId);
        community = community.copyWith(pinnedMessageIDs: pinnedIDs);
        await zeytin.add(
            box: _communityBox, tag: communityId, value: community.toJson());
      }
    }

    return await zeytin.add(
        box: _messagesBox, tag: messageId, value: message.toJson());
  }

  Future<ZeytinXResponse> unpinMessage({
    required String messageId,
    required String communityId,
  }) async {
    ZeytinXMessage? message = await getMessage(messageId: messageId);
    if (message == null) {
      return ZeytinXResponse(isSuccess: false, message: "Message not found");
    }

    message = message.copyWith(
      isPinned: false,
      pinnedBy: null,
      pinnedTimestamp: null,
    );

    ZeytinXCommunityModel? community = await getCommunity(id: communityId);
    if (community != null) {
      final pinnedIDs = List<String>.from(community.pinnedMessageIDs);
      pinnedIDs.remove(messageId);
      community = community.copyWith(pinnedMessageIDs: pinnedIDs);
      await zeytin.add(
          box: _communityBox, tag: communityId, value: community.toJson());
    }

    return await zeytin.add(
        box: _messagesBox, tag: messageId, value: message.toJson());
  }

  Future<List<ZeytinXMessage>> getPinnedMessages({
    required String communityId,
  }) async {
    ZeytinXCommunityModel? community = await getCommunity(id: communityId);
    if (community == null) return [];

    List<ZeytinXMessage> pinnedMessages = [];
    for (var id in community.pinnedMessageIDs) {
      ZeytinXMessage? m = await getMessage(messageId: id);
      if (m != null && !m.isDeleted) pinnedMessages.add(m);
    }
    return pinnedMessages;
  }

  Future<ZeytinXResponse> markAsRead({
    required String messageId,
    required String userId,
  }) async {
    ZeytinXMessage? message = await getMessage(messageId: messageId);
    if (message == null) {
      return ZeytinXResponse(isSuccess: false, message: "Message not found");
    }

    final readBy = List<String>.from(message.statusInfo.readBy);
    if (!readBy.contains(userId)) {
      readBy.add(userId);
      final info = message.statusInfo.copyWith(
        readBy: readBy,
        readAt: DateTime.now(),
      );
      message = message.copyWith(
        statusInfo: info,
        status: ZeytinXMessageStatus.read,
      );

      return await zeytin.add(
          box: _messagesBox, tag: messageId, value: message.toJson());
    }
    return ZeytinXResponse(isSuccess: true, message: "Already read");
  }

  Future<ZeytinXResponse> markAsDelivered({
    required String messageId,
    required String userId,
  }) async {
    ZeytinXMessage? message = await getMessage(messageId: messageId);
    if (message == null) {
      return ZeytinXResponse(isSuccess: false, message: "Message not found");
    }

    final deliveredTo = List<String>.from(message.statusInfo.deliveredTo);
    if (!deliveredTo.contains(userId)) {
      deliveredTo.add(userId);
      final info = message.statusInfo.copyWith(
        deliveredTo: deliveredTo,
        deliveredAt: DateTime.now(),
      );
      message = message.copyWith(
        statusInfo: info,
        status: ZeytinXMessageStatus.delivered,
      );

      return await zeytin.add(
          box: _messagesBox, tag: messageId, value: message.toJson());
    }
    return ZeytinXResponse(isSuccess: true, message: "Already delivered");
  }

  Future<ZeytinXResponse> addReaction({
    required String messageId,
    required String userId,
    required String emoji,
  }) async {
    ZeytinXMessage? message = await getMessage(messageId: messageId);
    if (message == null) {
      return ZeytinXResponse(isSuccess: false, message: "Message not found");
    }

    final reactions = Map<String, List<ZeytinXReactionModel>>.from(
      message.reactions.reactions,
    );
    final list = List<ZeytinXReactionModel>.from(reactions[emoji] ?? []);

    if (!list.any((r) => r.userId == userId)) {
      list.add(
        ZeytinXReactionModel(
          emoji: emoji,
          userId: userId,
          timestamp: DateTime.now(),
        ),
      );
      reactions[emoji] = list;
      message = message.copyWith(
        reactions: ZeytinXMessageReactionsModel(reactions: reactions),
      );

      return await zeytin.add(
          box: _messagesBox, tag: messageId, value: message.toJson());
    }
    return ZeytinXResponse(isSuccess: true, message: "Already reacted");
  }

  Future<ZeytinXResponse> removeReaction({
    required String messageId,
    required String userId,
    required String emoji,
  }) async {
    ZeytinXMessage? message = await getMessage(messageId: messageId);
    if (message == null) {
      return ZeytinXResponse(isSuccess: false, message: "Message not found");
    }

    final reactions = Map<String, List<ZeytinXReactionModel>>.from(
      message.reactions.reactions,
    );
    final list = List<ZeytinXReactionModel>.from(reactions[emoji] ?? []);

    list.removeWhere((r) => r.userId == userId);
    if (list.isEmpty) {
      reactions.remove(emoji);
    } else {
      reactions[emoji] = list;
    }
    message = message.copyWith(
      reactions: ZeytinXMessageReactionsModel(reactions: reactions),
    );

    return await zeytin.add(
        box: _messagesBox, tag: messageId, value: message.toJson());
  }

  StreamSubscription<Map<String, dynamic>> listenMessages({
    required String communityId,
    required Function(ZeytinXMessage message) onMessageReceived,
    required Function(ZeytinXMessage message) onMessageUpdated,
    required Function(String messageId) onMessageDeleted,
  }) {
    return zeytin.observer.listen((eventMap) {
      final operation = ZeytinXOperation.fromMap(eventMap);
      if (operation.boxId != _messagesBox) return;

      if (operation.type == ZeytinOpType.delete) {
        if (operation.tag != null) {
          onMessageDeleted(operation.tag!);
        }
        return;
      }

      final rawData = operation.value?.value;
      if (rawData == null) return;

      try {
        final message = ZeytinXMessage.fromJson(rawData);
        if (message.chatId.trim() == communityId.trim()) {
          if (message.isDeleted) {
            onMessageDeleted(message.messageId);
          } else if (operation.type == ZeytinOpType.put) {
            onMessageUpdated(message);
            onMessageReceived(message);
          }
        }
      } catch (e) {
        ZeytinXPrint.errorPrint("WS ERROR: $e");
      }
    });
  }

  StreamSubscription<Map<String, dynamic>> listenCommunity({
    required ZeytinXUserModel user,
    required Function(ZeytinXCommunityModel community) onCreated,
    required Function(ZeytinXCommunityModel community) onUpdated,
    required Function(String communityId) onDeleted,
  }) {
    return zeytin.observer.listen((eventMap) {
      final operation = ZeytinXOperation.fromMap(eventMap);
      if (operation.boxId != _communityBox) return;

      if (operation.type == ZeytinOpType.delete) {
        if (operation.tag != null) {
          onDeleted(operation.tag!);
        }
        return;
      }

      final rawData = operation.value?.value;
      if (rawData != null) {
        try {
          final community = ZeytinXCommunityModel.fromJson(rawData);
          if (community.participants.any((p) => p.uid == user.uid)) {
            if (operation.type == ZeytinOpType.put) {
              onUpdated(community);
              onCreated(community);
            }
          }
        } catch (_) {}
      }
    });
  }

  Future<ZeytinXResponse> sendBoardPost({
    required String communityId,
    required ZeytinXUserModel sender,
    required String text,
    String? imageURL,
    Map<String, dynamic>? moreData,
  }) async {
    try {
      ZeytinXCommunityModel? community = await getCommunity(id: communityId);
      if (community == null) {
        return ZeytinXResponse(
          isSuccess: false,
          message: "Community not found",
        );
      }
      if (!community.admins.any((admin) => admin.uid == sender.uid)) {
        return ZeytinXResponse(
          isSuccess: false,
          message: "Only admins can post to board",
        );
      }

      final postId = _uuid.v4();
      final post = ZeytinXCommunityBoardPostModel(
        id: postId,
        communityId: communityId,
        sender: sender,
        text: text,
        imageURL: imageURL,
        seenBy: [],
        createdAt: DateTime.now(),
        moreData: moreData ?? {},
      );

      return await zeytin.add(
          box: _boardsBox, tag: postId, value: post.toJson());
    } catch (e) {
      return ZeytinXResponse(isSuccess: false, message: e.toString());
    }
  }

  Future<ZeytinXResponse> markBoardPostSeen({
    required String postId,
    required ZeytinXUserModel user,
  }) async {
    try {
      ZeytinXCommunityBoardPostModel? post;
      var res = await zeytin.get(
        box: _boardsBox,
        tag: postId,
      );

      if (res.isSuccess && res.data != null && res.data!['value'] != null) {
        post = ZeytinXCommunityBoardPostModel.fromJson(res.data!['value']);
      }

      if (post == null) {
        return ZeytinXResponse(isSuccess: false, message: "Post not found");
      }
      if (post.seenBy.contains(user.uid)) {
        return ZeytinXResponse(isSuccess: true, message: "Already seen");
      }

      final updatedSeenBy = List<String>.from(post.seenBy)..add(user.uid);
      final updatedPost = post.copyWith(seenBy: updatedSeenBy);

      return await zeytin.add(
          box: _boardsBox, tag: postId, value: updatedPost.toJson());
    } catch (e) {
      return ZeytinXResponse(isSuccess: false, message: e.toString());
    }
  }

  Future<int> getBoardPostSeenCount({required String postId}) async {
    int count = 0;
    var res = await zeytin.get(
      box: _boardsBox,
      tag: postId,
    );

    if (res.isSuccess && res.data != null && res.data!['value'] != null) {
      final post = ZeytinXCommunityBoardPostModel.fromJson(res.data!['value']);
      count = post.seenBy.length;
    }

    return count;
  }

  Future<ZeytinXResponse> deleteBoardPost({
    required String communityId,
    required String postId,
    required ZeytinXUserModel admin,
  }) async {
    try {
      ZeytinXCommunityModel? community = await getCommunity(id: communityId);
      if (community == null) {
        return ZeytinXResponse(
          isSuccess: false,
          message: "Community not found",
        );
      }
      if (!community.admins.any((a) => a.uid == admin.uid)) {
        return ZeytinXResponse(isSuccess: false, message: "Not authorized");
      }

      return await zeytin.remove(
        box: _boardsBox,
        tag: postId,
      );
    } catch (e) {
      return ZeytinXResponse(isSuccess: false, message: e.toString());
    }
  }

  Future<ZeytinXResponse> editBoardPost({
    required String communityId,
    required String postId,
    required ZeytinXUserModel admin,
    String? newText,
    String? newImageURL,
  }) async {
    try {
      ZeytinXCommunityModel? community = await getCommunity(id: communityId);
      if (community == null) {
        return ZeytinXResponse(
          isSuccess: false,
          message: "Community not found",
        );
      }
      if (!community.admins.any((a) => a.uid == admin.uid)) {
        return ZeytinXResponse(isSuccess: false, message: "Not authorized");
      }

      ZeytinXCommunityBoardPostModel? post;
      var res = await zeytin.get(
        box: _boardsBox,
        tag: postId,
      );

      if (res.isSuccess && res.data != null && res.data!['value'] != null) {
        post = ZeytinXCommunityBoardPostModel.fromJson(res.data!['value']);
      }

      if (post == null) {
        return ZeytinXResponse(isSuccess: false, message: "Post not found");
      }

      post = post.copyWith(
        text: newText ?? post.text,
        imageURL: newImageURL ?? post.imageURL,
        updatedAt: DateTime.now(),
      );

      return await zeytin.add(
          box: _boardsBox, tag: postId, value: post.toJson());
    } catch (e) {
      return ZeytinXResponse(isSuccess: false, message: e.toString());
    }
  }

  Future<List<ZeytinXCommunityBoardPostModel>> getBoardPosts({
    required String communityId,
  }) async {
    List<ZeytinXCommunityBoardPostModel> posts = [];
    var res = await zeytin.filter(
      box: _boardsBox,
      predicate: (data) => data["communityId"] == communityId,
    );

    if (res.isSuccess && res.data != null && res.data!['results'] != null) {
      for (var item in res.data!['results']) {
        if (item['value'] != null) {
          posts.add(ZeytinXCommunityBoardPostModel.fromJson(item['value']));
        }
      }
    }

    posts.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return posts;
  }
}
