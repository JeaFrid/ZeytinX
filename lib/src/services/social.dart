import 'package:uuid/uuid.dart';
import 'package:zeytin_local_storage/zeytin_local_storage.dart';
import 'package:zeytinx/zeytinx.dart';

class ZeytinXSocial {
  final ZeytinStorage zeytin;
  static const String _box = 'social';
  final _uuid = const Uuid();

  ZeytinXSocial(this.zeytin);

  Future<ZeytinXResponse> createPost({
    required ZeytinXSocialModel postModel,
  }) async {
    String id = _uuid.v1();
    ZeytinXResponse? response;

    var newPost = postModel.copyWith(id: id);

    await zeytin.add(
      data: ZeytinValue(_box, id, newPost.toJson()),
      onSuccess: () {
        response = ZeytinXResponse(
          isSuccess: true,
          message: "ok",
          data: newPost.toJson(),
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

  Future<ZeytinXResponse> deletePost({required String id}) async {
    ZeytinXResponse? response;

    await zeytin.remove(
      boxId: _box,
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

  Future<ZeytinXResponse> editPost({
    required String id,
    required ZeytinXSocialModel postModel,
  }) async {
    ZeytinXResponse? response;
    var newPost = postModel.copyWith(id: id);

    await zeytin.add(
      data: ZeytinValue(_box, id, newPost.toJson()),
      onSuccess: () {
        response = ZeytinXResponse(
          isSuccess: true,
          message: "ok",
          data: newPost.toJson(),
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

  Future<ZeytinXResponse> addLike({
    required ZeytinXUserModel user,
    required String postID,
  }) async {
    ZeytinXSocialModel post = await getPost(id: postID);
    if ((post.likes ?? []).contains(user.uid)) {
      return ZeytinXResponse(isSuccess: true, message: "message");
    } else {
      List<dynamic> likes = List.from(post.likes ?? []);
      likes.add(user.uid);
      ZeytinXSocialModel newPost = post.copyWith(likes: likes);
      await editPost(id: postID, postModel: newPost);
      return ZeytinXResponse(isSuccess: true, message: "message");
    }
  }

  Future<ZeytinXResponse> removeLike({
    required ZeytinXUserModel user,
    required String postID,
  }) async {
    ZeytinXSocialModel post = await getPost(id: postID);
    if ((post.likes ?? []).contains(user.uid)) {
      List<dynamic> likes = List.from(post.likes ?? []);
      likes.remove(user.uid);
      ZeytinXSocialModel newPost = post.copyWith(likes: likes);
      await editPost(id: postID, postModel: newPost);
      return ZeytinXResponse(isSuccess: true, message: "message");
    } else {
      return ZeytinXResponse(isSuccess: true, message: "message");
    }
  }

  Future<ZeytinXResponse> addComment({
    required ZeytinXSocialCommentsModel comment,
    required String postID,
  }) async {
    ZeytinXSocialModel post = await getPost(id: postID);
    List<ZeytinXSocialCommentsModel> comments = List.from(post.comments ?? []);
    comments.add(comment.copyWith(id: _uuid.v1()));
    ZeytinXSocialModel newPost = post.copyWith(comments: comments);
    await editPost(id: postID, postModel: newPost);
    return ZeytinXResponse(isSuccess: true, message: "ok");
  }

  Future<ZeytinXResponse> deleteComment({
    required String commentID,
    required String postID,
  }) async {
    ZeytinXSocialModel post = await getPost(id: postID);
    List<ZeytinXSocialCommentsModel> comments = List.from(post.comments ?? []);
    comments.removeWhere((element) => element.id == commentID);
    ZeytinXSocialModel newPost = post.copyWith(comments: comments);
    await editPost(id: postID, postModel: newPost);
    return ZeytinXResponse(isSuccess: true, message: "ok");
  }

  Future<ZeytinXResponse> addCommentLike({
    required ZeytinXUserModel user,
    required String postID,
    required String commentID,
  }) async {
    ZeytinXSocialModel post = await getPost(id: postID);

    List<ZeytinXSocialCommentsModel> comments = List.from(post.comments ?? []);
    bool updated = false;

    for (int i = 0; i < comments.length; i++) {
      if (comments[i].id == commentID) {
        List<String> commentLikes = List.from(comments[i].likes ?? []);

        if (!commentLikes.contains(user.uid)) {
          commentLikes.add(user.uid);
          comments[i] = comments[i].copyWith(likes: commentLikes);
          updated = true;
        }
        break;
      }
    }

    if (updated) {
      ZeytinXSocialModel newPost = post.copyWith(comments: comments);
      await editPost(id: postID, postModel: newPost);
      return ZeytinXResponse(isSuccess: true, message: "Comment liked");
    }

    return ZeytinXResponse(
      isSuccess: false,
      message: "No comments found or it's already liked.",
    );
  }

  Future<ZeytinXResponse> removeCommentLike({
    required ZeytinXUserModel user,
    required String postID,
    required String commentID,
  }) async {
    ZeytinXSocialModel post = await getPost(id: postID);

    List<ZeytinXSocialCommentsModel> comments = List.from(post.comments ?? []);
    bool updated = false;

    for (int i = 0; i < comments.length; i++) {
      if (comments[i].id == commentID) {
        List<String> commentLikes = List.from(comments[i].likes ?? []);

        if (commentLikes.contains(user.uid)) {
          commentLikes.remove(user.uid);
          comments[i] = comments[i].copyWith(likes: commentLikes);
          updated = true;
        }
        break;
      }
    }

    if (updated) {
      ZeytinXSocialModel newPost = post.copyWith(comments: comments);
      await editPost(id: postID, postModel: newPost);
      return ZeytinXResponse(isSuccess: true, message: "Comment like removed");
    }

    return ZeytinXResponse(
      isSuccess: false,
      message: "No comments or likes found.",
    );
  }

  Future<List<ZeytinXSocialCommentsModel>> getComments({
    required String postID,
    int? limit,
    int? offset,
  }) async {
    ZeytinXSocialModel post = await getPost(id: postID);
    List<ZeytinXSocialCommentsModel> allComments = post.comments ?? [];

    if (offset != null && offset >= allComments.length) {
      return [];
    }

    int startIndex = offset ?? 0;
    int endIndex = limit != null ? startIndex + limit : allComments.length;

    if (endIndex > allComments.length) {
      endIndex = allComments.length;
    }

    if (startIndex >= endIndex) {
      return [];
    }

    return allComments.sublist(startIndex, endIndex);
  }

  Future<ZeytinXSocialModel> getPost({required String id}) async {
    ZeytinXSocialModel? post;

    await zeytin.get(
      boxId: _box,
      tag: id,
      onSuccess: (result) {
        if (result.value != null) {
          post = ZeytinXSocialModel.fromJson(result.value!);
        }
      },
      onError: (e, s) {},
    );
    return post ?? ZeytinXSocialModel.fromJson({});
  }

  Future<List<ZeytinXSocialModel>> getAllPost() async {
    List<ZeytinXSocialModel> list = [];

    await zeytin.getBox(
      boxId: _box,
      onSuccess: (results) {
        for (var element in results) {
          if (element.value != null) {
            list.add(ZeytinXSocialModel.fromJson(element.value!));
          }
        }
      },
      onError: (e, s) {
        ZeytinXPrint.errorPrint(e.toString());
      },
    );

    return list;
  }
}
