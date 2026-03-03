import 'package:uuid/uuid.dart';
import 'package:zeytinx/zeytinx.dart';

class ZeytinXProducts {
  final ZeytinX zeytin;
  static const String _box = 'products';
  final _uuid = const Uuid();

  ZeytinXProducts(this.zeytin);

  Future<ZeytinXResponse> createProduct({
    required ZeytinXProductModel productModel,
  }) async {
    String id = _uuid.v1();
    var newProduct = productModel.copyWith(id: id, createdAt: DateTime.now());

    return await zeytin.add(
      box: _box,
      tag: id,
      value: newProduct.toJson(),
    );
  }

  Future<ZeytinXResponse> deleteProduct({required String id}) async {
    return await zeytin.remove(
      box: _box,
      tag: id,
    );
  }

  Future<ZeytinXResponse> updateProduct({
    required String id,
    required ZeytinXProductModel productModel,
  }) async {
    var newProduct = productModel.copyWith(id: id);

    return await zeytin.add(
      box: _box,
      tag: id,
      value: newProduct.toJson(),
    );
  }

  Future<ZeytinXProductModel> getProduct({required String id}) async {
    var res = await zeytin.get(
      box: _box,
      tag: id,
    );

    if (res.isSuccess && res.data != null && res.data!['value'] != null) {
      return ZeytinXProductModel.fromJson(res.data!['value']);
    }
    return ZeytinXProductModel.empty();
  }

  Future<List<ZeytinXProductModel>> getAllProducts() async {
    List<ZeytinXProductModel> list = [];

    var res = await zeytin.getBox(
      box: _box,
    );

    if (res.isSuccess && res.data != null) {
      res.data!.forEach((key, value) {
        if (value != null) {
          list.add(ZeytinXProductModel.fromJson(value));
        }
      });
    }

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
