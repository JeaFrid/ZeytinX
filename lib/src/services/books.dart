import 'package:uuid/uuid.dart';
import 'package:zeytinx/zeytinx.dart';

class ZeytinXLibrary {
  final ZeytinX zeytin;
  static const String _booksBox = 'books';
  static const String _chaptersBox = 'chapters';
  final _uuid = const Uuid();

  ZeytinXLibrary(this.zeytin);

  Future<ZeytinXResponse> createBook({
    required ZeytinXBookModel bookModel,
  }) async {
    String id = _uuid.v1();
    var newBook = bookModel.copyWith(id: id);

    return await zeytin.add(
      box: _booksBox,
      tag: id,
      value: newBook.toJson(),
    );
  }

  Future<ZeytinXResponse> deleteBook({required String id}) async {
    return await zeytin.remove(
      box: _booksBox,
      tag: id,
    );
  }

  Future<ZeytinXResponse> editBook({
    required String id,
    required ZeytinXBookModel bookModel,
  }) async {
    var newBook = bookModel.copyWith(id: id);

    return await zeytin.add(
      box: _booksBox,
      tag: id,
      value: newBook.toJson(),
    );
  }

  Future<ZeytinXBookModel> getBook({required String id}) async {
    var res = await zeytin.get(
      box: _booksBox,
      tag: id,
    );

    if (res.isSuccess && res.data != null && res.data!['value'] != null) {
      return ZeytinXBookModel.fromJson(res.data!['value']);
    }

    return ZeytinXBookModel.empty();
  }

  Future<ZeytinXResponse> addChapter({
    required ZeytinXChapterModel chapter,
  }) async {
    String id = _uuid.v1();
    var newChapter = chapter.copyWith(id: id);

    return await zeytin.add(
      box: _chaptersBox,
      tag: id,
      value: newChapter.toJson(),
    );
  }

  Future<ZeytinXResponse> deleteChapter({required String id}) async {
    return await zeytin.remove(
      box: _chaptersBox,
      tag: id,
    );
  }

  Future<List<ZeytinXChapterModel>> getBookChapters({
    required String bookID,
  }) async {
    List<ZeytinXChapterModel> list = [];

    var res = await zeytin.filter(
      box: _chaptersBox,
      predicate: (data) => data["bookId"] == bookID,
    );

    if (res.isSuccess && res.data != null && res.data!['results'] != null) {
      for (var item in res.data!['results']) {
        if (item['value'] != null) {
          list.add(ZeytinXChapterModel.fromJson(item['value']));
        }
      }
    }

    list.sort((a, b) => a.order.compareTo(b.order));
    return list;
  }

  Future<ZeytinXResponse> updateChapter({
    required String id,
    required ZeytinXChapterModel chapter,
  }) async {
    var updatedChapter = chapter.copyWith(id: id);

    return await zeytin.add(
      box: _chaptersBox,
      tag: id,
      value: updatedChapter.toJson(),
    );
  }

  Future<List<ZeytinXBookModel>> getAllBooks() async {
    List<ZeytinXBookModel> list = [];

    var res = await zeytin.getBox(
      box: _booksBox,
    );

    if (res.isSuccess && res.data != null) {
      res.data!.forEach((key, value) {
        if (value != null) {
          list.add(ZeytinXBookModel.fromJson(value));
        }
      });
    }

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
    List<ZeytinXBookCommentModel> comments =
        commentsRaw.map((e) => ZeytinXBookCommentModel.fromJson(e)).toList();

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

    List<ZeytinXBookCommentModel> comments =
        commentsRaw.map((e) => ZeytinXBookCommentModel.fromJson(e)).toList();

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

    var res = await zeytin.search(
      box: _booksBox,
      field: "isbn",
      prefix: isbn,
    );

    if (res.isSuccess && res.data != null && res.data!['results'] != null) {
      for (var item in res.data!['results']) {
        if (item['value'] != null) {
          results.add(ZeytinXBookModel.fromJson(item['value']));
        }
      }
    }

    return results;
  }
}
