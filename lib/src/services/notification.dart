import 'dart:async';
import 'package:uuid/uuid.dart';
import 'package:zeytin_local_storage/zeytin_local_storage.dart';
import 'package:zeytinx/zeytinx.dart';

class ZeytinXNotificationService {
  final ZeytinStorage zeytin;
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

      ZeytinXResponse? response;

      await zeytin.add(
        data: ZeytinValue(_box, id, notification.toJson()),
        onSuccess: () {
          response = ZeytinXResponse(
            isSuccess: true,
            message: "Notification sent successfully",
            data: notification.toJson(),
          );
        },
        onError: (e, s) {
          response = ZeytinXResponse(
            isSuccess: false,
            message: "Error sending notification: $e",
          );
        },
      );

      if (response != null && response!.isSuccess) {
        await _indexNotificationForUsers(id, targetUserIds);
        return response!;
      }

      return response ??
          ZeytinXResponse(isSuccess: false, message: "Unknown error");
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

      await zeytin.get(
        boxId: _indexBox,
        tag: uid,
        onSuccess: (result) {
          if (result.value != null &&
              result.value!["notificationIds"] != null) {
            currentIds = List<String>.from(result.value!["notificationIds"]);
          }
        },
        onError: (e, s) {},
      );

      if (!currentIds.contains(notificationId)) {
        currentIds.add(notificationId);
        await zeytin.add(
          data: ZeytinValue(_indexBox, uid, {"notificationIds": currentIds}),
        );
      }
    }
  }

  Future<List<ZeytinXNotificationModel>> _fetchUserNotificationsRaw(
    String userId,
  ) async {
    try {
      List<String> ids = [];

      await zeytin.get(
        boxId: _indexBox,
        tag: userId,
        onSuccess: (result) {
          if (result.value != null &&
              result.value!["notificationIds"] != null) {
            ids = List<String>.from(result.value!["notificationIds"]);
          }
        },
        onError: (e, s) {},
      );

      if (ids.isEmpty) return [];

      List<ZeytinXNotificationModel> notifications = [];

      for (var id in ids) {
        await zeytin.get(
          boxId: _box,
          tag: id,
          onSuccess: (dataRes) {
            if (dataRes.value != null) {
              notifications.add(
                ZeytinXNotificationModel.fromJson(dataRes.value!),
              );
            }
          },
          onError: (e, s) {},
        );
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

      await zeytin.getBox(
        boxId: _box,
        onSuccess: (results) {
          for (var element in results) {
            if (element.value != null) {
              list.add(ZeytinXNotificationModel.fromJson(element.value!));
            }
          }
        },
        onError: (e, s) {},
      );

      list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return list;
    } catch (e) {
      return [];
    }
  }

  Future<ZeytinXResponse> deleteNotification({
    required String notificationId,
  }) async {
    ZeytinXResponse? response;

    await zeytin.remove(
      boxId: _box,
      tag: notificationId,
      onSuccess: () {
        response = ZeytinXResponse(isSuccess: true, message: "ok");
      },
      onError: (e, s) {
        response = ZeytinXResponse(
          isSuccess: false,
          message: "Error deleting notification",
          error: e.toString(),
        );
      },
    );

    return response ??
        ZeytinXResponse(isSuccess: false, message: "Unknown error");
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
      String? errorMessage;

      await zeytin.get(
        boxId: _box,
        tag: notificationId,
        onSuccess: (result) {
          if (result.value != null) {
            notification = ZeytinXNotificationModel.fromJson(result.value!);
          }
        },
        onError: (e, s) {
          errorMessage = e.toString();
        },
      );

      if (errorMessage != null) {
        return ZeytinXResponse(isSuccess: false, message: errorMessage!);
      }

      if (notification == null) {
        return ZeytinXResponse(
          isSuccess: false,
          message: "Notification not found",
        );
      }

      if (!notification!.seenBy.contains(userId)) {
        final updatedSeenBy = List<String>.from(notification!.seenBy)
          ..add(userId);
        final updatedNotification = notification!.copyWith(
          seenBy: updatedSeenBy,
        );

        ZeytinXResponse? updateResponse;

        await zeytin.add(
          data: ZeytinValue(_box, notificationId, updatedNotification.toJson()),
          onSuccess: () {
            updateResponse = ZeytinXResponse(
              isSuccess: true,
              message: "Marked as seen",
            );
          },
          onError: (e, s) {
            updateResponse = ZeytinXResponse(
              isSuccess: false,
              message: e.toString(),
            );
          },
        );

        return updateResponse ??
            ZeytinXResponse(isSuccess: false, message: "Unknown error");
      }

      return ZeytinXResponse(isSuccess: true, message: "Already seen");
    } catch (e) {
      return ZeytinXResponse(isSuccess: false, message: e.toString());
    }
  }
}
