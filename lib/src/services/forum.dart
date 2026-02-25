import 'package:uuid/uuid.dart';
import 'package:zeytin_local_storage/zeytin_local_storage.dart';
import 'package:zeytinx/zeytinx.dart';

class ZeytinXForum {
  final ZeytinStorage zeytin;
  static const String _categoriesBox = 'forum_categories';
  static const String _threadsBox = 'forum_threads';
  final _uuid = const Uuid();

  ZeytinXForum(this.zeytin);

  Future<ZeytinXResponse> createCategory({
    required ZeytinXForumCategoryModel categoryModel,
  }) async {
    String id = _uuid.v1();
    var newCategory = categoryModel.copyWith(id: id);
    ZeytinXResponse? response;

    await zeytin.add(
      data: ZeytinValue(_categoriesBox, id, newCategory.toJson()),
      onSuccess: () {
        response = ZeytinXResponse(
          isSuccess: true,
          message: "ok",
          data: newCategory.toJson(),
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

  Future<ZeytinXResponse> deleteCategory({required String id}) async {
    ZeytinXResponse? response;

    await zeytin.remove(
      boxId: _categoriesBox,
      tag: id,
      onSuccess: () {
        response = ZeytinXResponse(isSuccess: true, message: "ok");
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

  Future<ZeytinXResponse> updateCategory({
    required String id,
    required ZeytinXForumCategoryModel categoryModel,
  }) async {
    ZeytinXResponse? response;
    var updatedCategory = categoryModel.copyWith(id: id);

    await zeytin.add(
      data: ZeytinValue(_categoriesBox, id, updatedCategory.toJson()),
      onSuccess: () {
        response = ZeytinXResponse(
          isSuccess: true,
          message: "ok",
          data: updatedCategory.toJson(),
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

  Future<List<ZeytinXForumCategoryModel>> getAllCategories() async {
    List<ZeytinXForumCategoryModel> list = [];

    await zeytin.getBox(
      boxId: _categoriesBox,
      onSuccess: (results) {
        for (var element in results) {
          if (element.value != null) {
            list.add(ZeytinXForumCategoryModel.fromJson(element.value!));
          }
        }
      },
      onError: (e, s) {
        ZeytinXPrint.errorPrint(e.toString());
      },
    );

    list.sort((a, b) => a.order.compareTo(b.order));
    return list;
  }

  Future<ZeytinXResponse> createThread({
    required ZeytinXForumThreadModel threadModel,
  }) async {
    String id = _uuid.v1();
    DateTime now = DateTime.now();
    var newThread = threadModel.copyWith(
      id: id,
      createdAt: now,
      lastActivityAt: now,
    );
    ZeytinXResponse? response;

    await zeytin.add(
      data: ZeytinValue(_threadsBox, id, newThread.toJson()),
      onSuccess: () {
        response = ZeytinXResponse(
          isSuccess: true,
          message: "ok",
          data: newThread.toJson(),
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

  Future<ZeytinXResponse> deleteThread({required String id}) async {
    ZeytinXResponse? response;

    await zeytin.remove(
      boxId: _threadsBox,
      tag: id,
      onSuccess: () {
        response = ZeytinXResponse(isSuccess: true, message: "ok");
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

  Future<ZeytinXResponse> updateThread({
    required String id,
    required ZeytinXForumThreadModel threadModel,
  }) async {
    ZeytinXResponse? response;
    var updatedThread = threadModel.copyWith(id: id);

    await zeytin.add(
      data: ZeytinValue(_threadsBox, id, updatedThread.toJson()),
      onSuccess: () {
        response = ZeytinXResponse(
          isSuccess: true,
          message: "ok",
          data: updatedThread.toJson(),
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

  Future<ZeytinXForumThreadModel> getThread({required String id}) async {
    ZeytinXForumThreadModel? thread;

    await zeytin.get(
      boxId: _threadsBox,
      tag: id,
      onSuccess: (result) {
        if (result.value != null) {
          thread = ZeytinXForumThreadModel.fromJson(result.value!);
        }
      },
      onError: (e, s) {},
    );

    return thread ?? ZeytinXForumThreadModel.empty();
  }

  Future<List<ZeytinXForumThreadModel>> getAllThreads() async {
    List<ZeytinXForumThreadModel> list = [];

    await zeytin.getBox(
      boxId: _threadsBox,
      onSuccess: (results) {
        for (var element in results) {
          if (element.value != null) {
            list.add(ZeytinXForumThreadModel.fromJson(element.value!));
          }
        }
      },
      onError: (e, s) {
        ZeytinXPrint.errorPrint(e.toString());
      },
    );

    list.sort((a, b) {
      DateTime dateA = a.lastActivityAt ?? DateTime(1970);
      DateTime dateB = b.lastActivityAt ?? DateTime(1970);
      return dateB.compareTo(dateA);
    });

    return list;
  }

  Future<List<ZeytinXForumThreadModel>> getThreadsByCategory(
    String categoryId,
  ) async {
    List<ZeytinXForumThreadModel> allThreads = await getAllThreads();
    return allThreads.where((t) => t.categoryId == categoryId).toList();
  }

  Future<ZeytinXResponse> addThreadLike({
    required ZeytinXUserModel user,
    required String threadId,
  }) async {
    ZeytinXForumThreadModel thread = await getThread(id: threadId);
    List<String> likes = List<String>.from(thread.likes);
    if (!likes.contains(user.uid)) {
      likes.add(user.uid);
      return await updateThread(
        id: threadId,
        threadModel: thread.copyWith(likes: likes),
      );
    }
    return ZeytinXResponse(isSuccess: true, message: "Already liked");
  }

  Future<ZeytinXResponse> removeThreadLike({
    required ZeytinXUserModel user,
    required String threadId,
  }) async {
    ZeytinXForumThreadModel thread = await getThread(id: threadId);
    List<String> likes = List<String>.from(thread.likes);
    if (likes.contains(user.uid)) {
      likes.remove(user.uid);
      return await updateThread(
        id: threadId,
        threadModel: thread.copyWith(likes: likes),
      );
    }
    return ZeytinXResponse(isSuccess: true, message: "Not liked");
  }

  Future<ZeytinXResponse> addView({required String threadId}) async {
    ZeytinXForumThreadModel thread = await getThread(id: threadId);
    return await updateThread(
      id: threadId,
      threadModel: thread.copyWith(viewCount: thread.viewCount + 1),
    );
  }

  Future<ZeytinXResponse> addEntry({
    required ZeytinXForumEntryModel entry,
    required String threadId,
  }) async {
    ZeytinXForumThreadModel thread = await getThread(id: threadId);
    if (thread.isLocked) {
      return ZeytinXResponse(isSuccess: false, message: "Thread is locked");
    }

    List<ZeytinXForumEntryModel> entries = List.from(thread.entries);
    DateTime now = DateTime.now();

    entries.add(
      entry.copyWith(id: _uuid.v1(), threadId: threadId, createdAt: now),
    );

    return await updateThread(
      id: threadId,
      threadModel: thread.copyWith(entries: entries, lastActivityAt: now),
    );
  }

  Future<ZeytinXResponse> deleteEntry({
    required String entryId,
    required String threadId,
  }) async {
    ZeytinXForumThreadModel thread = await getThread(id: threadId);
    List<ZeytinXForumEntryModel> entries = List.from(thread.entries);

    entries.removeWhere((element) => element.id == entryId);

    return await updateThread(
      id: threadId,
      threadModel: thread.copyWith(entries: entries),
    );
  }

  Future<ZeytinXResponse> editEntry({
    required String entryId,
    required String threadId,
    required String newText,
  }) async {
    ZeytinXForumThreadModel thread = await getThread(id: threadId);
    List<ZeytinXForumEntryModel> entries = List.from(thread.entries);

    int index = entries.indexWhere((e) => e.id == entryId);
    if (index != -1) {
      entries[index] = entries[index].copyWith(
        text: newText,
        isEdited: true,
        updatedAt: DateTime.now(),
      );
      return await updateThread(
        id: threadId,
        threadModel: thread.copyWith(entries: entries),
      );
    }
    return ZeytinXResponse(isSuccess: false, message: "Entry not found");
  }

  Future<ZeytinXResponse> addEntryLike({
    required ZeytinXUserModel user,
    required String threadId,
    required String entryId,
  }) async {
    ZeytinXForumThreadModel thread = await getThread(id: threadId);
    List<ZeytinXForumEntryModel> entries = List.from(thread.entries);
    bool updated = false;

    for (int i = 0; i < entries.length; i++) {
      if (entries[i].id == entryId) {
        List<String> likes = List.from(entries[i].likes);
        if (!likes.contains(user.uid)) {
          likes.add(user.uid);
          entries[i] = entries[i].copyWith(likes: likes);
          updated = true;
        }
        break;
      }
    }

    if (updated) {
      return await updateThread(
        id: threadId,
        threadModel: thread.copyWith(entries: entries),
      );
    }
    return ZeytinXResponse(
      isSuccess: true,
      message: "Already liked or entry not found",
    );
  }

  Future<ZeytinXResponse> removeEntryLike({
    required ZeytinXUserModel user,
    required String threadId,
    required String entryId,
  }) async {
    ZeytinXForumThreadModel thread = await getThread(id: threadId);
    List<ZeytinXForumEntryModel> entries = List.from(thread.entries);
    bool updated = false;

    for (int i = 0; i < entries.length; i++) {
      if (entries[i].id == entryId) {
        List<String> likes = List.from(entries[i].likes);
        if (likes.contains(user.uid)) {
          likes.remove(user.uid);
          entries[i] = entries[i].copyWith(likes: likes);
          updated = true;
        }
        break;
      }
    }

    if (updated) {
      return await updateThread(
        id: threadId,
        threadModel: thread.copyWith(entries: entries),
      );
    }
    return ZeytinXResponse(
      isSuccess: true,
      message: "Not liked or entry not found",
    );
  }

  Future<ZeytinXResponse> toggleThreadPin({
    required String threadId,
    required bool isPinned,
  }) async {
    ZeytinXForumThreadModel thread = await getThread(id: threadId);
    return await updateThread(
      id: threadId,
      threadModel: thread.copyWith(isPinned: isPinned),
    );
  }

  Future<ZeytinXResponse> toggleThreadLock({
    required String threadId,
    required bool isLocked,
  }) async {
    ZeytinXForumThreadModel thread = await getThread(id: threadId);
    return await updateThread(
      id: threadId,
      threadModel: thread.copyWith(isLocked: isLocked),
    );
  }

  Future<ZeytinXResponse> toggleThreadResolve({
    required String threadId,
    required bool isResolved,
  }) async {
    ZeytinXForumThreadModel thread = await getThread(id: threadId);
    return await updateThread(
      id: threadId,
      threadModel: thread.copyWith(isResolved: isResolved),
    );
  }
}
