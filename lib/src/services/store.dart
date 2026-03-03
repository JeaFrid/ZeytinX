import 'package:uuid/uuid.dart';
import 'package:zeytinx/zeytinx.dart';

class ZeytinXStore {
  final ZeytinX zeytin;
  static const String _box = 'stores';
  final _uuid = const Uuid();

  ZeytinXStore(this.zeytin);

  Future<ZeytinXResponse> createStore({
    required ZeytinXStoreModel storeModel,
  }) async {
    String id = _uuid.v1();
    var newStore = storeModel.copyWith(id: id, createdAt: DateTime.now());

    return await zeytin.add(
      box: _box,
      tag: id,
      value: newStore.toJson(),
    );
  }

  Future<ZeytinXResponse> deleteStore({required String id}) async {
    return await zeytin.remove(
      box: _box,
      tag: id,
    );
  }

  Future<ZeytinXResponse> updateStore({
    required String id,
    required ZeytinXStoreModel storeModel,
  }) async {
    var newStore = storeModel.copyWith(id: id);

    return await zeytin.add(
      box: _box,
      tag: id,
      value: newStore.toJson(),
    );
  }

  Future<ZeytinXStoreModel> getStore({required String id}) async {
    var res = await zeytin.get(
      box: _box,
      tag: id,
    );

    if (res.isSuccess && res.data != null && res.data!['value'] != null) {
      return ZeytinXStoreModel.fromJson(res.data!['value']);
    }

    return ZeytinXStoreModel.empty();
  }

  Future<List<ZeytinXStoreModel>> getAllStores() async {
    List<ZeytinXStoreModel> list = [];

    var res = await zeytin.getBox(
      box: _box,
    );

    if (res.isSuccess && res.data != null) {
      res.data!.forEach((key, value) {
        if (value != null) {
          list.add(ZeytinXStoreModel.fromJson(value));
        }
      });
    }

    return list;
  }
}
