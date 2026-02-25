import 'package:uuid/uuid.dart';
import 'package:zeytin_local_storage/zeytin_local_storage.dart';
import 'package:zeytinx/zeytinx.dart';

class ZeytinXUser {
  final ZeytinStorage zeytin;
  static const String _box = 'users';
  final _uuid = const Uuid();

  ZeytinXUser(this.zeytin);

  bool _isValidEmail(String email) {
    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+$');
    return emailRegex.hasMatch(email);
  }

  bool _isValidPassword(String password) {
    return password.length >= 6;
  }

  Future<ZeytinXResponse> create(
    String name,
    String email,
    String password,
  ) async {
    try {
      if (!_isValidEmail(email)) {
        return ZeytinXResponse(
          isSuccess: false,
          message: "Invalid format",
          error: "Please enter a valid email address.",
        );
      }
      if (!_isValidPassword(password)) {
        return ZeytinXResponse(
          isSuccess: false,
          message: "Weak password",
          error: "Your password must be at least 6 characters long.",
        );
      }
      bool existEmail = await exist(email);
      if (existEmail) {
        return ZeytinXResponse(
          isSuccess: false,
          message: "Email available",
          error: "This email is already registered.",
        );
      } else {
        String uid = _uuid.v1();
        var emptyUser = ZeytinXUserModel.empty();
        var newUser = emptyUser.copyWith(
          uid: uid,
          username: name,
          email: email,
          password: password,
          accountCreation: DateTime.now().toIso8601String(),
        );

        ZeytinXResponse? response;

        await zeytin.add(
          data: ZeytinValue(_box, uid, newUser.toJson()),
          onSuccess: () {
            response = ZeytinXResponse(
              isSuccess: true,
              message: "ok",
              data: newUser.toJson(),
            );
          },
          onError: (e, s) {
            response = ZeytinXResponse(
              isSuccess: false,
              message: "Error",
              error: e.toString(),
            );
          },
        );

        return response ??
            ZeytinXResponse(isSuccess: false, message: "Unknown error");
      }
    } catch (e) {
      return ZeytinXResponse(
        isSuccess: false,
        message: "Error",
        error: e.toString(),
      );
    }
  }

  Future<bool> isActive(
    ZeytinXUserModel user, {
    int thresholdSeconds = 10,
  }) async {
    ZeytinXUserModel? currentUser = await _getProfile(user.uid);
    if (currentUser == null) return false;

    if (currentUser.lastLoginTimestamp.isEmpty) return false;

    final lastSeenTime = DateTime.parse(currentUser.lastLoginTimestamp);
    final difference = DateTime.now().difference(lastSeenTime).inSeconds;

    return difference <= thresholdSeconds;
  }

  Future<ZeytinXResponse> updateUserActive(ZeytinXUserModel user) async {
    final updatedUser = user.copyWith(
      lastLoginTimestamp: DateTime.now().toIso8601String(),
    );

    ZeytinXResponse? response;

    await zeytin.add(
      data: ZeytinValue(_box, user.uid, updatedUser.toJson()),
      onSuccess: () {
        response = ZeytinXResponse(
          isSuccess: true,
          message: "ok",
          data: updatedUser.toJson(),
        );
      },
      onError: (e, s) {
        response = ZeytinXResponse(
          isSuccess: false,
          message: "Error",
          error: e.toString(),
        );
      },
    );

    return response ??
        ZeytinXResponse(isSuccess: false, message: "Unknown error");
  }

  Future<ZeytinXResponse> followUser({
    required String myUid,
    required String targetUid,
  }) async {
    try {
      ZeytinXUserModel? me = await getProfile(userId: myUid);
      ZeytinXUserModel? targetUser = await getProfile(userId: targetUid);

      if (me == null || targetUser == null) {
        return ZeytinXResponse(isSuccess: false, message: "User not found");
      }

      List<String> myFollowing = List<String>.from(me.following);
      if (!myFollowing.contains(targetUid)) myFollowing.add(targetUid);

      List<String> targetFollowers = List<String>.from(targetUser.followers);
      if (!targetFollowers.contains(myUid)) targetFollowers.add(myUid);

      bool success1 = false;
      bool success2 = false;
      String? errorMessage;

      await zeytin.add(
        data: ZeytinValue(
          _box,
          me.uid,
          me.copyWith(following: myFollowing).toJson(),
        ),
        onSuccess: () {
          success1 = true;
        },
        onError: (e, s) {
          errorMessage = e.toString();
        },
      );

      await zeytin.add(
        data: ZeytinValue(
          _box,
          targetUid,
          targetUser.copyWith(followers: targetFollowers).toJson(),
        ),
        onSuccess: () {
          success2 = true;
        },
        onError: (e, s) {
          errorMessage = e.toString();
        },
      );

      if (success1 && success2) {
        return ZeytinXResponse(
          isSuccess: true,
          message: "Followed successfully",
        );
      } else {
        return ZeytinXResponse(
          isSuccess: false,
          message: "Follow error",
          error: errorMessage,
        );
      }
    } catch (e) {
      return ZeytinXResponse(
        isSuccess: false,
        message: "Follow error",
        error: e.toString(),
      );
    }
  }

  Future<bool> isFollow({
    required String myUid,
    required String targetUid,
  }) async {
    ZeytinXUserModel? me = await _getProfile(myUid);
    if (me == null) return false;
    return me.following.contains(targetUid);
  }

  Future<ZeytinXResponse> unfollowUser({
    required String myUid,
    required String targetUid,
  }) async {
    try {
      ZeytinXUserModel? me = await getProfile(userId: myUid);
      ZeytinXUserModel? targetUser = await getProfile(userId: targetUid);

      if (me == null || targetUser == null) {
        return ZeytinXResponse(isSuccess: false, message: "User not found");
      }

      List<String> myFollowing = List<String>.from(me.following);
      myFollowing.remove(targetUid);

      List<String> targetFollowers = List<String>.from(targetUser.followers);
      targetFollowers.remove(myUid);

      bool success1 = false;
      bool success2 = false;
      String? errorMessage;

      await zeytin.add(
        data: ZeytinValue(
          _box,
          me.uid,
          me.copyWith(following: myFollowing).toJson(),
        ),
        onSuccess: () {
          success1 = true;
        },
        onError: (e, s) {
          errorMessage = e.toString();
        },
      );

      await zeytin.add(
        data: ZeytinValue(
          _box,
          targetUid,
          targetUser.copyWith(followers: targetFollowers).toJson(),
        ),
        onSuccess: () {
          success2 = true;
        },
        onError: (e, s) {
          errorMessage = e.toString();
        },
      );

      if (success1 && success2) {
        return ZeytinXResponse(
          isSuccess: true,
          message: "Unfollowed successfully",
        );
      } else {
        return ZeytinXResponse(
          isSuccess: false,
          message: "Unfollow error",
          error: errorMessage,
        );
      }
    } catch (e) {
      return ZeytinXResponse(
        isSuccess: false,
        message: "Unfollow error",
        error: e.toString(),
      );
    }
  }

  Future<ZeytinXResponse> blockUser({
    required String myUid,
    required String targetUid,
  }) async {
    try {
      ZeytinXUserModel? me = await getProfile(userId: myUid);
      if (me == null) {
        return ZeytinXResponse(isSuccess: false, message: "User not found");
      }

      List<String> myBlocked = List<String>.from(me.blockedUsers);
      if (!myBlocked.contains(targetUid)) myBlocked.add(targetUid);

      List<String> myFollowing = List<String>.from(me.following);
      myFollowing.remove(targetUid);

      ZeytinXResponse? response;

      await zeytin.add(
        data: ZeytinValue(
          _box,
          me.uid,
          me.copyWith(blockedUsers: myBlocked, following: myFollowing).toJson(),
        ),
        onSuccess: () {
          response = ZeytinXResponse(
            isSuccess: true,
            message: "User blocked and chat destroyed",
          );
        },
        onError: (e, s) {
          response = ZeytinXResponse(
            isSuccess: false,
            message: "Block error",
            error: e.toString(),
          );
        },
      );

      return response ??
          ZeytinXResponse(isSuccess: false, message: "Unknown error");
    } catch (e) {
      return ZeytinXResponse(
        isSuccess: false,
        message: "Block error",
        error: e.toString(),
      );
    }
  }

  Future<ZeytinXResponse> unblockUser({
    required String myUid,
    required String targetUid,
  }) async {
    try {
      ZeytinXUserModel? me = await getProfile(userId: myUid);
      if (me == null) {
        return ZeytinXResponse(isSuccess: false, message: "User not found");
      }

      List<String> myBlocked = List<String>.from(me.blockedUsers);
      myBlocked.remove(targetUid);

      ZeytinXResponse? response;

      await zeytin.add(
        data: ZeytinValue(
          _box,
          me.uid,
          me.copyWith(blockedUsers: myBlocked).toJson(),
        ),
        onSuccess: () {
          response = ZeytinXResponse(
            isSuccess: true,
            message: "User unblocked",
          );
        },
        onError: (e, s) {
          response = ZeytinXResponse(
            isSuccess: false,
            message: "Unblock error",
            error: e.toString(),
          );
        },
      );

      return response ??
          ZeytinXResponse(isSuccess: false, message: "Unknown error");
    } catch (e) {
      return ZeytinXResponse(
        isSuccess: false,
        message: "Unblock error",
        error: e.toString(),
      );
    }
  }

  Future<bool> isBlocked({
    required String myUid,
    required String targetUid,
  }) async {
    ZeytinXUserModel? me = await _getProfile(myUid);
    if (me == null) return false;
    return me.blockedUsers.contains(targetUid);
  }

  Future<bool> exist(String email) async {
    List<ZeytinXUserModel> users = await _getAllProfiles();
    for (var user in users) {
      if (user.email.toLowerCase() == email.toLowerCase()) {
        return true;
      }
    }
    return false;
  }

  Future<ZeytinXResponse> login(String email, String password) async {
    try {
      bool existE = await exist(email);
      if (existE) {
        List<ZeytinXUserModel> users = await _getAllProfiles();

        for (var user in users) {
          if (user.email.toLowerCase() == email.toLowerCase() &&
              user.password.trim() == password.trim()) {
            return ZeytinXResponse(
              isSuccess: true,
              message: "ok",
              data: user.toJson(),
            );
          }
        }
        return ZeytinXResponse(isSuccess: false, message: "Wrong password");
      } else {
        return ZeytinXResponse(isSuccess: false, message: "Account not found");
      }
    } catch (e) {
      return ZeytinXResponse(
        isSuccess: false,
        message: "Opps...",
        error: e.toString(),
      );
    }
  }

  Future<ZeytinXUserModel?> getProfile({required String userId}) async {
    return await _getProfile(userId);
  }

  Future<ZeytinXUserModel?> _getProfile(String userId) async {
    try {
      ZeytinXUserModel? user;

      await zeytin.get(
        boxId: _box,
        tag: userId,
        onSuccess: (result) {
          if (result.value != null) {
            user = ZeytinXUserModel.fromJson(result.value!);
          }
        },
        onError: (e, s) {},
      );

      return user;
    } catch (e) {
      return null;
    }
  }

  Future<List<ZeytinXUserModel>> getAllProfile() async {
    return await _getAllProfiles();
  }

  Future<List<ZeytinXUserModel>> _getAllProfiles() async {
    try {
      List<ZeytinXUserModel> users = [];

      await zeytin.getBox(
        boxId: _box,
        onSuccess: (results) {
          for (var element in results) {
            if (element.value != null) {
              users.add(ZeytinXUserModel.fromJson(element.value!));
            }
          }
        },
        onError: (e, s) {},
      );

      return users;
    } catch (e) {
      return [];
    }
  }

  Future<ZeytinXResponse> updateProfile(
    ZeytinXUserModel user,
    ZeytinXUserModel newUser,
  ) async {
    try {
      ZeytinXResponse? response;

      await zeytin.add(
        data: ZeytinValue(_box, user.uid, newUser.toJson()),
        onSuccess: () {
          response = ZeytinXResponse(
            isSuccess: true,
            message: "ok",
            data: newUser.toJson(),
          );
        },
        onError: (e, s) {
          response = ZeytinXResponse(
            isSuccess: false,
            message: e.toString(),
            error: e.toString(),
          );
        },
      );

      return response ??
          ZeytinXResponse(isSuccess: false, message: "Unknown error");
    } catch (e) {
      return ZeytinXResponse(
        isSuccess: false,
        message: e.toString(),
        error: e.toString(),
      );
    }
  }
}
