import 'package:uuid/uuid.dart';
import 'package:zeytin_local_storage/zeytin_local_storage.dart';
import 'package:zeytinx/zeytinx.dart';

class ZeytinXLibrary {
  final ZeytinStorage zeytin;
  static const String _booksBox = 'books';
  static const String _chaptersBox = 'chapters';
  final _uuid = const Uuid();

  ZeytinXLibrary(this.zeytin);

  Future<ZeytinXResponse> createBook({
    required ZeytinXBookModel bookModel,
  }) async {
    String id = _uuid.v1();
    var newBook = bookModel.copyWith(id: id);
    ZeytinXResponse? response;

    await zeytin.add(
      data: ZeytinValue(_booksBox, id, newBook.toJson()),
      onSuccess: () {
        response = ZeytinXResponse(
          isSuccess: true,
          message: "ok",
          data: newBook.toJson(),
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

  Future<ZeytinXResponse> deleteBook({required String id}) async {
    ZeytinXResponse? response;

    await zeytin.remove(
      boxId: _booksBox,
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

  Future<ZeytinXResponse> editBook({
    required String id,
    required ZeytinXBookModel bookModel,
  }) async {
    ZeytinXResponse? response;
    var newBook = bookModel.copyWith(id: id);

    await zeytin.add(
      data: ZeytinValue(_booksBox, id, newBook.toJson()),
      onSuccess: () {
        response = ZeytinXResponse(
          isSuccess: true,
          message: "ok",
          data: newBook.toJson(),
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

  Future<ZeytinXBookModel> getBook({required String id}) async {
    ZeytinXBookModel? book;

    await zeytin.get(
      boxId: _booksBox,
      tag: id,
      onSuccess: (result) {
        if (result.value != null) {
          book = ZeytinXBookModel.fromJson(result.value!);
        }
      },
      onError: (e, s) {},
    );

    // Eğer kitap bulunamazsa uygulamanın çökmesini engellemek için boş model dönüyoruz
    return book ?? ZeytinXBookModel.empty();
  }

  Future<ZeytinXResponse> addChapter({
    required ZeytinXChapterModel chapter,
  }) async {
    String id = _uuid.v1();
    var newChapter = chapter.copyWith(id: id);
    ZeytinXResponse? response;

    await zeytin.add(
      data: ZeytinValue(_chaptersBox, id, newChapter.toJson()),
      onSuccess: () {
        response = ZeytinXResponse(
          isSuccess: true,
          message: "ok",
          data: newChapter.toJson(),
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

  Future<ZeytinXResponse> deleteChapter({required String id}) async {
    ZeytinXResponse? response;

    await zeytin.remove(
      boxId: _chaptersBox,
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

  Future<List<ZeytinXChapterModel>> getBookChapters({
    required String bookID,
  }) async {
    List<ZeytinXChapterModel> list = [];

    await zeytin.filter(
      boxId: _chaptersBox,
      predicate: (data) => data["bookId"] == bookID,
      onSuccess: (results) {
        for (var item in results) {
          if (item.value != null) {
            list.add(ZeytinXChapterModel.fromJson(item.value!));
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

  Future<ZeytinXResponse> updateChapter({
    required String id,
    required ZeytinXChapterModel chapter,
  }) async {
    ZeytinXResponse? response;
    var updatedChapter = chapter.copyWith(id: id);

    await zeytin.add(
      data: ZeytinValue(_chaptersBox, id, updatedChapter.toJson()),
      onSuccess: () {
        response = ZeytinXResponse(
          isSuccess: true,
          message: "ok",
          data: updatedChapter.toJson(),
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

  Future<List<ZeytinXBookModel>> getAllBooks() async {
    List<ZeytinXBookModel> list = [];

    await zeytin.getBox(
      boxId: _booksBox,
      onSuccess: (results) {
        for (var element in results) {
          if (element.value != null) {
            list.add(ZeytinXBookModel.fromJson(element.value!));
          }
        }
      },
      onError: (e, s) {
        ZeytinXPrint.errorPrint(e.toString());
      },
    );

    return list;
  }

  Future<ZeytinXResponse> addLike({
    required ZeytinXUserModel user,
    required String bookID,
  }) async {
    ZeytinXBookModel book = await getBook(id: bookID);
    List<String> likes = List<String>.from(book.likes);

    if (!likes.contains(user.uid)) {
      likes.add(user.uid);
      return await editBook(
        id: bookID,
        bookModel: book.copyWith(likes: likes),
      );
    }
    return ZeytinXResponse(isSuccess: true, message: "Already liked");
  }

  Future<ZeytinXResponse> removeLike({
    required ZeytinXUserModel user,
    required String bookID,
  }) async {
    ZeytinXBookModel book = await getBook(id: bookID);
    List<String> likes = List<String>.from(book.likes);

    if (likes.contains(user.uid)) {
      likes.remove(user.uid);
      return await editBook(
        id: bookID,
        bookModel: book.copyWith(likes: likes),
      );
    }
    return ZeytinXResponse(isSuccess: true, message: "Not liked");
  }

  Future<ZeytinXResponse> addComment({
    required ZeytinXBookCommentModel comment,
    required String bookID,
  }) async {
    ZeytinXBookModel book = await getBook(id: bookID);
    var moreData = Map<String, dynamic>.from(book.moreData ?? {});
    List<dynamic> commentsRaw = moreData["comments"] ?? [];
    List<ZeytinXBookCommentModel> comments = commentsRaw
        .map((e) => ZeytinXBookCommentModel.fromJson(e))
        .toList();

    comments.add(comment.copyWith(id: _uuid.v1(), bookID: bookID));
    moreData["comments"] = comments.map((e) => e.toJson()).toList();

    return await editBook(
      id: bookID,
      bookModel: book.copyWith(moreData: moreData),
    );
  }

  Future<ZeytinXResponse> deleteComment({
    required String commentID,
    required String bookID,
  }) async {
    ZeytinXBookModel book = await getBook(id: bookID);
    var moreData = Map<String, dynamic>.from(book.moreData ?? {});
    List<dynamic> commentsRaw = moreData["comments"] ?? [];

    List<ZeytinXBookCommentModel> comments = commentsRaw
        .map((e) => ZeytinXBookCommentModel.fromJson(e))
        .toList();

    comments.removeWhere((element) => element.id == commentID);
    moreData["comments"] = comments.map((e) => e.toJson()).toList();

    return await editBook(
      id: bookID,
      bookModel: book.copyWith(moreData: moreData),
    );
  }

  Future<List<ZeytinXBookCommentModel>> getComments({
    required String bookID,
  }) async {
    ZeytinXBookModel book = await getBook(id: bookID);
    List<dynamic> commentsRaw = book.moreData?["comments"] ?? [];
    return commentsRaw.map((e) => ZeytinXBookCommentModel.fromJson(e)).toList();
  }

  Future<List<ZeytinXBookModel>> searchByISBN(String isbn) async {
    List<ZeytinXBookModel> results = [];

    await zeytin.search(
      boxId: _booksBox,
      field: "isbn",
      prefix: isbn,
      onSuccess: (list) {
        for (var item in list) {
          if (item.value != null) {
            results.add(ZeytinXBookModel.fromJson(item.value!));
          }
        }
      },
      onError: (e, s) {
        ZeytinXPrint.errorPrint(e.toString());
      },
    );

    return results;
  }
}
