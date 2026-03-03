import 'dart:async';
import 'package:uuid/uuid.dart';
import 'package:zeytinx/zeytinx.dart';

class ZeytinXNotificationService {
  final ZeytinX zeytin;
  static const String _box = 'notifications';
  static const String _indexBox = 'my_notifications';
  final _uuid = const Uuid();

  ZeytinXNotificationService(this.zeytin);

  Future<ZeytinXResponse> sendNotification({
    required String title,
    required String description,
    required List<String> targetUserIds,
    String type = 'general',
    List<ZeytinXNotificationMediaModel>? media,
    bool isInApp = false,
    String? inAppTag,
    Map<String, dynamic>? moreData,
  }) async {
    try {
      final id = _uuid.v4();
      final now = DateTime.now();
      final notification = ZeytinXNotificationModel(
        id: id,
        title: title,
        description: description,
        createdAt: now,
        targetUserIds: targetUserIds,
        media: media ?? [],
        type: type,
        seenBy: [],
        isInApp: isInApp,
        inAppTag: inAppTag,
        moreData: moreData ?? {},
      );

      var response = await zeytin.add(
        box: _box,
        tag: id,
        value: notification.toJson(),
      );

      if (response.isSuccess) {
        await _indexNotificationForUsers(id, targetUserIds);
        return ZeytinXResponse(
          isSuccess: true,
          message: "Notification sent successfully",
          data: notification.toJson(),
        );
      }

      return response;
    } catch (e) {
      return ZeytinXResponse(
        isSuccess: false,
        message: "Error sending notification: $e",
      );
    }
  }

  Future<void> _indexNotificationForUsers(
    String notificationId,
    List<String> userIds,
  ) async {
    for (var uid in userIds) {
      List<String> currentIds = [];

      var result = await zeytin.get(
        box: _indexBox,
        tag: uid,
      );

      if (result.isSuccess &&
          result.data != null &&
          result.data!['value'] != null &&
          result.data!['value']["notificationIds"] != null) {
        currentIds =
            List<String>.from(result.data!['value']["notificationIds"]);
      }

      if (!currentIds.contains(notificationId)) {
        currentIds.add(notificationId);
        await zeytin.add(
          box: _indexBox,
          tag: uid,
          value: {"notificationIds": currentIds},
        );
      }
    }
  }

  Future<List<ZeytinXNotificationModel>> _fetchUserNotificationsRaw(
    String userId,
  ) async {
    try {
      List<String> ids = [];

      var result = await zeytin.get(
        box: _indexBox,
        tag: userId,
      );

      if (result.isSuccess &&
          result.data != null &&
          result.data!['value'] != null &&
          result.data!['value']["notificationIds"] != null) {
        ids = List<String>.from(result.data!['value']["notificationIds"]);
      }

      if (ids.isEmpty) return [];

      List<ZeytinXNotificationModel> notifications = [];

      for (var id in ids) {
        var dataRes = await zeytin.get(
          box: _box,
          tag: id,
        );

        if (dataRes.isSuccess &&
            dataRes.data != null &&
            dataRes.data!['value'] != null) {
          notifications.add(
            ZeytinXNotificationModel.fromJson(dataRes.data!['value']),
          );
        }
      }

      notifications.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return notifications;
    } catch (e) {
      return [];
    }
  }

  Future<List<ZeytinXNotificationModel>> getLastHourNotifications(
    String userId,
  ) async {
    final all = await _fetchUserNotificationsRaw(userId);
    final deadline = DateTime.now().subtract(const Duration(hours: 1));
    return all.where((n) => n.createdAt.isAfter(deadline)).toList();
  }

  Future<List<ZeytinXNotificationModel>> getLastDayNotifications(
    String userId,
  ) async {
    final all = await _fetchUserNotificationsRaw(userId);
    final deadline = DateTime.now().subtract(const Duration(days: 1));
    return all.where((n) => n.createdAt.isAfter(deadline)).toList();
  }

  Future<List<ZeytinXNotificationModel>> getLastMonthNotifications(
    String userId,
  ) async {
    final all = await _fetchUserNotificationsRaw(userId);
    final deadline = DateTime.now().subtract(const Duration(days: 30));
    return all.where((n) => n.createdAt.isAfter(deadline)).toList();
  }

  Future<List<ZeytinXNotificationModel>> getAllSentNotifications() async {
    try {
      List<ZeytinXNotificationModel> list = [];

      var results = await zeytin.getBox(
        box: _box,
      );

      if (results.isSuccess && results.data != null) {
        results.data!.forEach((key, value) {
          if (value != null) {
            list.add(ZeytinXNotificationModel.fromJson(value));
          }
        });
      }

      list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return list;
    } catch (e) {
      return [];
    }
  }

  Future<ZeytinXResponse> deleteNotification({
    required String notificationId,
  }) async {
    return await zeytin.remove(
      box: _box,
      tag: notificationId,
    );
  }

  Future<ZeytinXResponse> sendInAppNotification({
    required String title,
    required String description,
    required String tag,
    required List<String> targetUserIds,
    List<ZeytinXNotificationMediaModel>? media,
    Map<String, dynamic>? moreData,
  }) async {
    return await sendNotification(
      title: title,
      description: description,
      targetUserIds: targetUserIds,
      type: 'in_app',
      isInApp: true,
      inAppTag: tag,
      media: media,
      moreData: moreData,
    );
  }

  Future<List<ZeytinXNotificationModel>> getPendingInAppNotifications(
    String userId,
  ) async {
    final all = await _fetchUserNotificationsRaw(userId);

    return all.where((n) {
      return n.isInApp && !n.seenBy.contains(userId);
    }).toList();
  }

  Future<ZeytinXResponse> markAsSeen({
    required String notificationId,
    required String userId,
  }) async {
    try {
      ZeytinXNotificationModel? notification;

      var result = await zeytin.get(
        box: _box,
        tag: notificationId,
      );

      if (!result.isSuccess) {
        return ZeytinXResponse(isSuccess: false, message: result.message);
      }

      if (result.data != null && result.data!['value'] != null) {
        notification = ZeytinXNotificationModel.fromJson(result.data!['value']);
      }

      if (notification == null) {
        return ZeytinXResponse(
          isSuccess: false,
          message: "Notification not found",
        );
      }

      if (!notification.seenBy.contains(userId)) {
        final updatedSeenBy = List<String>.from(notification.seenBy)
          ..add(userId);
        final updatedNotification = notification.copyWith(
          seenBy: updatedSeenBy,
        );

        var updateResponse = await zeytin.add(
          box: _box,
          tag: notificationId,
          value: updatedNotification.toJson(),
        );

        if (updateResponse.isSuccess) {
          return ZeytinXResponse(
            isSuccess: true,
            message: "Marked as seen",
          );
        }

        return updateResponse;
      }

      return ZeytinXResponse(isSuccess: true, message: "Already seen");
    } catch (e) {
      return ZeytinXResponse(isSuccess: false, message: e.toString());
    }
  }
}
