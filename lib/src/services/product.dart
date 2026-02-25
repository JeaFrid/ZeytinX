import 'package:uuid/uuid.dart';
import 'package:zeytin_local_storage/zeytin_local_storage.dart';
import 'package:zeytinx/zeytinx.dart';

class ZeytinXProducts {
  final ZeytinStorage zeytin;
  static const String _box = 'products';
  final _uuid = const Uuid();

  ZeytinXProducts(this.zeytin);

  Future<ZeytinXResponse> createProduct({
    required ZeytinXProductModel productModel,
  }) async {
    String id = _uuid.v1();
    var newProduct = productModel.copyWith(id: id, createdAt: DateTime.now());
    ZeytinXResponse? response;

    await zeytin.add(
      data: ZeytinValue(_box, id, newProduct.toJson()),
      onSuccess: () {
        response = ZeytinXResponse(
          isSuccess: true,
          message: "ok",
          data: newProduct.toJson(),
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

  Future<ZeytinXResponse> deleteProduct({required String id}) async {
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

  Future<ZeytinXResponse> updateProduct({
    required String id,
    required ZeytinXProductModel productModel,
  }) async {
    ZeytinXResponse? response;
    var newProduct = productModel.copyWith(id: id);

    await zeytin.add(
      data: ZeytinValue(_box, id, newProduct.toJson()),
      onSuccess: () {
        response = ZeytinXResponse(
          isSuccess: true,
          message: "ok",
          data: newProduct.toJson(),
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

  Future<ZeytinXProductModel> getProduct({required String id}) async {
    ZeytinXProductModel? product;

    await zeytin.get(
      boxId: _box,
      tag: id,
      onSuccess: (result) {
        if (result.value != null) {
          product = ZeytinXProductModel.fromJson(result.value!);
        }
      },
      onError: (e, s) {},
    );
    return product ?? ZeytinXProductModel.empty();
  }

  Future<List<ZeytinXProductModel>> getAllProducts() async {
    List<ZeytinXProductModel> list = [];

    await zeytin.getBox(
      boxId: _box,
      onSuccess: (results) {
        for (var element in results) {
          if (element.value != null) {
            list.add(ZeytinXProductModel.fromJson(element.value!));
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
    required String productID,
  }) async {
    ZeytinXProductModel product = await getProduct(id: productID);
    List<String> likes = List<String>.from(product.likes);

    if (!likes.contains(user.uid)) {
      likes.add(user.uid);
      return await updateProduct(
        id: productID,
        productModel: product.copyWith(likes: likes),
      );
    }
    return ZeytinXResponse(isSuccess: true, message: "Already liked");
  }

  Future<ZeytinXResponse> removeLike({
    required ZeytinXUserModel user,
    required String productID,
  }) async {
    ZeytinXProductModel product = await getProduct(id: productID);
    List<String> likes = List<String>.from(product.likes);

    if (likes.contains(user.uid)) {
      likes.remove(user.uid);
      return await updateProduct(
        id: productID,
        productModel: product.copyWith(likes: likes),
      );
    }
    return ZeytinXResponse(isSuccess: true, message: "Not liked");
  }

  Future<ZeytinXResponse> addView({required String productID}) async {
    ZeytinXProductModel product = await getProduct(id: productID);
    return await updateProduct(
      id: productID,
      productModel: product.copyWith(viewCount: product.viewCount + 1),
    );
  }

  Future<ZeytinXResponse> addComment({
    required ZeytinXProductCommentModel comment,
    required String productID,
  }) async {
    ZeytinXProductModel product = await getProduct(id: productID);
    List<ZeytinXProductCommentModel> comments = List.from(product.comments);

    comments.add(
      comment.copyWith(
        id: _uuid.v1(),
        productId: productID,
        createdAt: DateTime.now(),
      ),
    );

    return await updateProduct(
      id: productID,
      productModel: product.copyWith(comments: comments),
    );
  }

  Future<ZeytinXResponse> deleteComment({
    required String commentID,
    required String productID,
  }) async {
    ZeytinXProductModel product = await getProduct(id: productID);
    List<ZeytinXProductCommentModel> comments = List.from(product.comments);

    comments.removeWhere((element) => element.id == commentID);

    return await updateProduct(
      id: productID,
      productModel: product.copyWith(comments: comments),
    );
  }

  Future<List<ZeytinXProductCommentModel>> getComments({
    required String productID,
  }) async {
    ZeytinXProductModel product = await getProduct(id: productID);
    return product.comments;
  }
}
