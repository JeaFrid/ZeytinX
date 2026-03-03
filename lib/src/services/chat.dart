import 'dart:async';
import 'package:uuid/uuid.dart';
import 'package:zeytinx/zeytinx.dart';

class ZeytinXChat {
  final ZeytinX zeytin;
  static const String _chatsBox = 'chats';
  static const String _messagesBox = 'messages';
  static const String _myChatsBox = 'my_chats';
  final _uuid = const Uuid();

  ZeytinXChat(this.zeytin);

  Future<ZeytinXResponse> createChat({
    required String chatName,
    required List<ZeytinXUserModel> participants,
    required ZeytinXChatType type,
    String? chatPhotoURL,
    List<ZeytinXUserModel>? admins,
    Map<String, dynamic>? themeSettings,
    String? moreData,
  }) async {
    try {
      String chatId;
      if (type == ZeytinXChatType.private && participants.length == 2) {
        List<String> uids = participants.map((u) => u.uid).toList()..sort();
        chatId = "private_${uids[0]}_${uids[1]}";

        ZeytinXChatModel? existing = await getChat(chatId: chatId);
        if (existing != null) {
          return ZeytinXResponse(
            isSuccess: true,
            message: "Chat already exists",
            data: existing.toJson(),
          );
        }
      } else {
        chatId = _uuid.v4();
      }

      final now = DateTime.now();
      final newChat = ZeytinXChatModel.empty().copyWith(
        chatID: chatId,
        type: type,
        createdAt: now,
        chatName: chatName,
        chatPhotoURL: chatPhotoURL,
        themeSettings: themeSettings,
        participants: participants,
        admins: admins ?? (type == ZeytinXChatType.private ? [] : participants),
        moreData: moreData,
      );

      var response = await zeytin.add(
        box: _chatsBox,
        tag: chatId,
        value: newChat.toJson(),
      );

      if (response.isSuccess) {
        await _indexChatForParticipants(chatId, participants);
        return ZeytinXResponse(
          isSuccess: true,
          message: "Chat created successfully",
          data: newChat.toJson(),
        );
      }

      return response;
    } catch (e) {
      return ZeytinXResponse(
        isSuccess: false,
        message: "Error in createChat",
        error: e.toString(),
      );
    }
  }

  String getChatId({
    required List<ZeytinXUserModel> participants,
    required ZeytinXChatType type,
  }) {
    if (type == ZeytinXChatType.private && participants.length == 2) {
      List<String> uids = participants.map((u) => u.uid).toList()..sort();
      return "private_${uids[0]}_${uids[1]}";
    } else {
      return _uuid.v4();
    }
  }

  Future<void> _indexChatForParticipants(
    String chatId,
    List<ZeytinXUserModel> participants,
  ) async {
    for (var user in participants) {
      List<String> currentChatIds = [];
      var res = await zeytin.get(
        box: _myChatsBox,
        tag: user.uid,
      );

      if (res.isSuccess &&
          res.data != null &&
          res.data!['value'] != null &&
          res.data!['value']["chatIds"] != null) {
        currentChatIds = List<String>.from(res.data!['value']["chatIds"]);
      }

      if (!currentChatIds.contains(chatId)) {
        currentChatIds.add(chatId);
        await zeytin.add(
          box: _myChatsBox,
          tag: user.uid,
          value: {"chatIds": currentChatIds},
        );
      }
    }
  }

  Future<ZeytinXResponse> deleteChatAndAllMessage({
    required String chatId,
  }) async {
    try {
      ZeytinXChatModel? chat = await getChat(chatId: chatId);
      if (chat == null) {
        return ZeytinXResponse(isSuccess: false, message: "Chat not found");
      }

      final messages = await getMessages(chatId: chatId, limit: 5000);
      for (var m in messages) {
        await zeytin.remove(box: _messagesBox, tag: m.messageId);
      }

      for (var user in chat.participants) {
        var res = await zeytin.get(
          box: _myChatsBox,
          tag: user.uid,
        );

        if (res.isSuccess && res.data != null && res.data!['value'] != null) {
          List<String> currentChatIds = List<String>.from(
            res.data!['value']["chatIds"] ?? [],
          );
          currentChatIds.remove(chatId);
          await zeytin.add(
            box: _myChatsBox,
            tag: user.uid,
            value: {
              "chatIds": currentChatIds,
            },
          );
        }
      }

      return await zeytin.remove(
        box: _chatsBox,
        tag: chatId,
      );
    } catch (e) {
      return ZeytinXResponse(
        isSuccess: false,
        message: "Error terminating chat: $e",
      );
    }
  }

  Future<List<ZeytinXChatModel>> getChatsForUser({
    required ZeytinXUserModel user,
  }) async {
    List<ZeytinXChatModel> userChats = [];
    var indexRes = await zeytin.get(
      box: _myChatsBox,
      tag: user.uid,
    );

    if (indexRes.isSuccess &&
        indexRes.data != null &&
        indexRes.data!['value'] != null &&
        indexRes.data!['value']["chatIds"] != null) {
      List<String> chatIds =
          List<String>.from(indexRes.data!['value']["chatIds"]);
      for (var id in chatIds) {
        ZeytinXChatModel? chatData = await getChat(chatId: id);
        if (chatData != null) userChats.add(chatData);
      }
    }

    userChats.sort(
      (a, b) => b.lastMessageTimestamp.compareTo(a.lastMessageTimestamp),
    );
    return userChats;
  }

  Future<ZeytinXChatModel?> getChat({required String chatId}) async {
    var res = await zeytin.get(
      box: _chatsBox,
      tag: chatId,
    );

    if (res.isSuccess && res.data != null && res.data!['value'] != null) {
      return ZeytinXChatModel.fromJson(res.data!['value']);
    }
    return null;
  }

  Future<ZeytinXResponse> updateChat({
    required String chatId,
    String? chatName,
    String? chatPhotoURL,
    Map<String, dynamic>? themeSettings,
    bool? isMuted,
    bool? isArchived,
    bool? isBlocked,
    String? moreData,
  }) async {
    try {
      ZeytinXChatModel? chat = await getChat(chatId: chatId);
      if (chat == null) {
        return ZeytinXResponse(isSuccess: false, message: "Chat not found");
      }

      chat = chat.copyWith(
        chatName: chatName ?? chat.chatName,
        chatPhotoURL: chatPhotoURL ?? chat.chatPhotoURL,
        themeSettings: themeSettings ?? chat.themeSettings,
        isMuted: isMuted ?? chat.isMuted,
        isArchived: isArchived ?? chat.isArchived,
        isBlocked: isBlocked ?? chat.isBlocked,
        moreData: moreData ?? chat.moreData,
      );

      return await zeytin.add(
          box: _chatsBox, tag: chatId, value: chat.toJson());
    } catch (e) {
      return ZeytinXResponse(isSuccess: false, message: e.toString());
    }
  }

  Future<ZeytinXResponse> archiveChat({
    required String chatId,
    required bool archive,
  }) async {
    return await updateChat(chatId: chatId, isArchived: archive);
  }

  Future<ZeytinXResponse> muteChat({
    required String chatId,
    required bool mute,
  }) async {
    return await updateChat(chatId: chatId, isMuted: mute);
  }

  Future<ZeytinXResponse> blockChat({
    required String chatId,
    required bool block,
  }) async {
    return await updateChat(chatId: chatId, isBlocked: block);
  }

  Future<ZeytinXResponse> addParticipant({
    required String chatId,
    required ZeytinXUserModel user,
  }) async {
    try {
      ZeytinXChatModel? chat = await getChat(chatId: chatId);
      if (chat == null) {
        return ZeytinXResponse(isSuccess: false, message: "Chat not found");
      }

      final participants = chat.participants;
      if (participants.any((p) => p.uid == user.uid)) {
        return ZeytinXResponse(
          isSuccess: true,
          message: "Already a participant",
        );
      }

      participants.add(user);
      final updatedChat = chat.copyWith(participants: participants);

      var response = await zeytin.add(
          box: _chatsBox, tag: chatId, value: updatedChat.toJson());

      if (response.isSuccess) {
        await _indexChatForParticipants(chatId, [user]);
      }

      return response;
    } catch (e) {
      return ZeytinXResponse(isSuccess: false, message: e.toString());
    }
  }

  Future<ZeytinXResponse> removeParticipant({
    required String chatId,
    required ZeytinXUserModel user,
  }) async {
    try {
      ZeytinXChatModel? chat = await getChat(chatId: chatId);
      if (chat == null) {
        return ZeytinXResponse(isSuccess: false, message: "Chat not found");
      }

      final participants =
          chat.participants.where((p) => p.uid != user.uid).toList();
      final updatedChat = chat.copyWith(participants: participants);

      var response = await zeytin.add(
          box: _chatsBox, tag: chatId, value: updatedChat.toJson());

      if (response.isSuccess) {
        var res = await zeytin.get(
          box: _myChatsBox,
          tag: user.uid,
        );

        if (res.isSuccess && res.data != null && res.data!['value'] != null) {
          List<String> currentChatIds = List<String>.from(
            res.data!['value']["chatIds"] ?? [],
          );
          currentChatIds.remove(chatId);
          await zeytin.add(box: _myChatsBox, tag: user.uid, value: {
            "chatIds": currentChatIds,
          });
        }
      }

      return response;
    } catch (e) {
      return ZeytinXResponse(isSuccess: false, message: e.toString());
    }
  }

  Future<ZeytinXResponse> setTyping({
    required String chatId,
    required ZeytinXUserModel user,
    required bool isTyping,
  }) async {
    try {
      ZeytinXChatModel? chat = await getChat(chatId: chatId);
      if (chat == null) {
        return ZeytinXResponse(isSuccess: false, message: "Chat not found");
      }

      var typingUsers = List<ZeytinXUserModel>.from(chat.typingUsers);

      if (isTyping) {
        if (!typingUsers.any((u) => u.uid == user.uid)) {
          typingUsers.add(user);
        }
      } else {
        typingUsers.removeWhere((u) => u.uid == user.uid);
      }

      chat = chat.copyWith(typingUsers: typingUsers);

      return await zeytin.add(
          box: _chatsBox, tag: chatId, value: chat.toJson());
    } catch (e) {
      return ZeytinXResponse(isSuccess: false, message: e.toString());
    }
  }

  Future<ZeytinXResponse> updateUnreadCount({
    required String chatId,
    required int count,
  }) async {
    try {
      ZeytinXChatModel? chat = await getChat(chatId: chatId);
      if (chat == null) {
        return ZeytinXResponse(isSuccess: false, message: "Chat not found");
      }

      chat = chat.copyWith(unreadCount: count);
      return await zeytin.add(
          box: _chatsBox, tag: chatId, value: chat.toJson());
    } catch (e) {
      return ZeytinXResponse(isSuccess: false, message: e.toString());
    }
  }

  Future<ZeytinXResponse> sendMessage({
    required String chatId,
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
        chatId: chatId,
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
        await _updateChatLastMessage(chatId, message, sender);
        ZeytinXChatModel? chat = await getChat(chatId: chatId);
        if (chat != null) {
          await _indexChatForParticipants(chatId, chat.participants);
        }
      }

      return response;
    } catch (e) {
      return ZeytinXResponse(isSuccess: false, message: e.toString());
    }
  }

  StreamSubscription<Map<String, dynamic>> listenChats({
    required ZeytinXUserModel user,
    required Function(ZeytinXChatModel chat) onChatCreated,
    required Function(ZeytinXChatModel chat) onChatUpdated,
    required Function(String chatId) onChatDeleted,
  }) {
    return zeytin.observer.listen((event) {
      if (event['boxId'] != _chatsBox) return;

      final op = event["op"];
      final tag = event["tag"];
      final rawData = event["value"];

      if (op == "DELETE") {
        onChatDeleted(tag.toString());
        return;
      }

      if (rawData != null) {
        try {
          final chat = ZeytinXChatModel.fromJson(rawData);
          if (chat.participants.any((p) => p.uid == user.uid)) {
            if (op == "PUT") {
              onChatCreated(chat);
            } else if (op == "UPDATE") {
              onChatUpdated(chat);
            }
          }
        } catch (_) {}
      }
    });
  }

  StreamSubscription<Map<String, dynamic>> listen({
    required String chatId,
    required Function(ZeytinXMessage message) onMessageReceived,
    required Function(ZeytinXMessage message) onMessageUpdated,
    required Function(String messageId) onMessageDeleted,
  }) {
    return zeytin.observer.listen((event) {
      if (event['boxId'] != _messagesBox) return;

      final op = event["op"];
      final tag = event["tag"];
      final rawData = event["value"];

      if (op == "DELETE") {
        onMessageDeleted(tag.toString());
        return;
      }

      if (rawData == null) return;

      try {
        final message = ZeytinXMessage.fromJson(rawData);
        if (message.chatId.trim() == chatId.trim()) {
          if (message.isDeleted) {
            onMessageDeleted(message.messageId);
          } else if (op == "PUT") {
            onMessageReceived(message);
          } else if (op == "UPDATE") {
            onMessageUpdated(message);
          }
        }
      } catch (e) {
        ZeytinXPrint.errorPrint("WS ERROR: $e");
      }
    });
  }

  Future<List<ZeytinXMessage>> getMessages({
    required String chatId,
    int? limit,
    int? offset,
  }) async {
    List<ZeytinXMessage> messages = [];
    var res = await zeytin.filter(
      box: _messagesBox,
      predicate: (data) => data["chatId"] == chatId,
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
    required String targetChatId,
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
        chatId: targetChatId,
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
        await _updateChatLastMessage(targetChatId, forwardedMessage, sender);
      }

      return response;
    } catch (e) {
      return ZeytinXResponse(isSuccess: false, message: e.toString());
    }
  }

  Future<List<ZeytinXMessage>> searchMessages({
    required String chatId,
    required String query,
  }) async {
    final allMessages = await getMessages(chatId: chatId, limit: 1000);
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
    required String chatId,
  }) async {
    ZeytinXMessage? message = await getMessage(messageId: messageId);
    if (message == null) {
      return ZeytinXResponse(isSuccess: false, message: "Message not found");
    }
    if (message.chatId != chatId) {
      return ZeytinXResponse(
        isSuccess: false,
        message: "Message not in this chat",
      );
    }

    message = message.copyWith(
      isPinned: true,
      pinnedBy: pinnedBy,
      pinnedTimestamp: DateTime.now(),
    );

    ZeytinXChatModel? chat = await getChat(chatId: chatId);
    if (chat != null) {
      final pinnedIDs = List<String>.from(chat.pinnedMessageIDs);
      if (!pinnedIDs.contains(messageId)) {
        pinnedIDs.add(messageId);
        chat = chat.copyWith(pinnedMessageIDs: pinnedIDs);
        await zeytin.add(box: _chatsBox, tag: chatId, value: chat.toJson());
      }
    }

    return await zeytin.add(
        box: _messagesBox, tag: messageId, value: message.toJson());
  }

  Future<ZeytinXResponse> unpinMessage({
    required String messageId,
    required String chatId,
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

    ZeytinXChatModel? chat = await getChat(chatId: chatId);
    if (chat != null) {
      final pinnedIDs = List<String>.from(chat.pinnedMessageIDs);
      pinnedIDs.remove(messageId);
      chat = chat.copyWith(pinnedMessageIDs: pinnedIDs);
      await zeytin.add(box: _chatsBox, tag: chatId, value: chat.toJson());
    }

    return await zeytin.add(
        box: _messagesBox, tag: messageId, value: message.toJson());
  }

  Future<List<ZeytinXMessage>> getPinnedMessages({
    required String chatId,
  }) async {
    ZeytinXChatModel? chat = await getChat(chatId: chatId);
    if (chat == null) return [];

    List<ZeytinXMessage> pinnedMessages = [];
    for (var id in chat.pinnedMessageIDs) {
      ZeytinXMessage? m = await getMessage(messageId: id);
      if (m != null && !m.isDeleted) pinnedMessages.add(m);
    }
    return pinnedMessages;
  }

  Future<ZeytinXResponse> clearChatHistory({
    required String chatId,
    required String userId,
  }) async {
    try {
      final messages = await getMessages(chatId: chatId, limit: 1000);
      for (var message in messages) {
        if (message.senderId == userId) {
          await deleteMessage(messageId: message.messageId, userId: userId);
        }
      }
      return ZeytinXResponse(isSuccess: true, message: "Chat history cleared");
    } catch (e) {
      return ZeytinXResponse(isSuccess: false, message: e.toString());
    }
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

  Future<ZeytinXResponse> processSelfDestructMessages() async {
    try {
      final now = DateTime.now();
      var res = await zeytin.getBox(
        box: _messagesBox,
      );

      if (res.isSuccess && res.data != null) {
        for (var entry in res.data!.entries) {
          if (entry.value != null) {
            final message = ZeytinXMessage.fromJson(entry.value);
            if (message.selfDestructTimestamp != null &&
                message.selfDestructTimestamp!.isBefore(now) &&
                !message.isDeleted) {
              await deleteMessage(
                messageId: message.messageId,
                userId: message.senderId,
                deleteForEveryone: true,
              );
            }
          }
        }
      }

      return ZeytinXResponse(isSuccess: true, message: "Processed");
    } catch (e) {
      return ZeytinXResponse(isSuccess: false, message: e.toString());
    }
  }

  Future<ZeytinXResponse> createSystemMessage({
    required String chatId,
    required ZeytinXSystemMessageType type,
    String? userId,
    String? userName,
    String? oldValue,
    String? value,
  }) async {
    try {
      final messageId = _uuid.v4();
      final now = DateTime.now();

      final systemData = ZeytinXSystemMessageDataModel(
        type: type,
        userId: userId,
        userName: userName,
        oldValue: oldValue,
        value: value,
      );

      final message = ZeytinXMessage(
        messageId: messageId,
        chatId: chatId,
        senderId: "system",
        text: "System Message",
        timestamp: now,
        messageType: ZeytinXMessageType.system,
        status: ZeytinXMessageStatus.sent,
        isSystemMessage: true,
        systemMessageData: systemData,
      );

      var response = await zeytin.add(
          box: _messagesBox, tag: messageId, value: message.toJson());

      if (response.isSuccess) {
        ZeytinXChatModel? chat = await getChat(chatId: chatId);
        if (chat != null) {
          chat = chat.copyWith(
            lastMessage: _getSystemMessageText(
              type,
              userName,
              oldValue,
              value,
            ),
            lastMessageTimestamp: now,
          );
          await zeytin.add(box: _chatsBox, tag: chatId, value: chat.toJson());
        }
      }

      return response;
    } catch (e) {
      return ZeytinXResponse(isSuccess: false, message: e.toString());
    }
  }

  Future<void> _updateChatLastMessage(
    String chatId,
    ZeytinXMessage message,
    ZeytinXUserModel sender,
  ) async {
    ZeytinXChatModel? chat = await getChat(chatId: chatId);
    if (chat == null) return;

    chat = chat.copyWith(
      lastMessage: message.messageType == ZeytinXMessageType.text
          ? message.text
          : message.messageType.value,
      lastMessageTimestamp: message.timestamp,
      lastMessageSender: sender,
    );

    await zeytin.add(box: _chatsBox, tag: chatId, value: chat.toJson());
  }

  String _getSystemMessageText(
    ZeytinXSystemMessageType type,
    String? userName,
    String? oldValue,
    String? value,
  ) {
    switch (type) {
      case ZeytinXSystemMessageType.userJoined:
        return '$userName joined';
      case ZeytinXSystemMessageType.userLeft:
        return '$userName left';
      case ZeytinXSystemMessageType.groupCreated:
        return 'Group created by $userName';
      case ZeytinXSystemMessageType.nameChanged:
        return 'Name changed to $value';
      default:
        return 'System message';
    }
  }
}
