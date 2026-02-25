import 'package:zeytin_local_storage/zeytin_local_storage.dart';
import 'package:zeytinx/zeytinx.dart';

Future<void> main() async {
  // 1. Storage Configuration and Initialization
  final zeytin = ZeytinStorage(
    namespace: "zeytinx_example_ns",
    truckID: "example_truck",
  );

  String dbPath = "./zeytinx_example_db";
  await zeytin.initialize(dbPath);

  // 2. Setup Services
  final userService = ZeytinXUser(zeytin);
  final socialService = ZeytinXSocial(zeytin);
  final chatService = ZeytinXChat(zeytin);

  // 3. User Operations
  var aliceRes = await userService.create(
    "alice",
    "alice@wonderland.com",
    "password123",
  );
  var bobRes = await userService.create(
    "bob",
    "bob@builder.com",
    "password123",
  );

  if (!aliceRes.isSuccess || !bobRes.isSuccess) {
    return;
  }

  ZeytinXUserModel alice = ZeytinXUserModel.fromJson(aliceRes.data!);
  ZeytinXUserModel bob = ZeytinXUserModel.fromJson(bobRes.data!);

  await userService.followUser(myUid: alice.uid, targetUid: bob.uid);

  // 4. Social Media Operations
  var postModel = ZeytinXSocialModel(
    user: alice,
    text: "Doing great things with ZeytinX and ZeytinLocalStorage!",
    category: "Developer",
  );

  var postRes = await socialService.createPost(postModel: postModel);
  if (postRes.isSuccess) {
    String postId = postRes.data!["id"];

    await socialService.addLike(user: bob, postID: postId);

    var comment = ZeytinXSocialCommentsModel(
      user: bob,
      text: "I totally agree!",
    );
    await socialService.addComment(comment: comment, postID: postId);
  }

  // 5. Chat Operations
  var chatRes = await chatService.createChat(
    chatName: "Alice & Bob Secret Chat",
    participants: [alice, bob],
    type: ZeytinXChatType.private,
  );

  if (chatRes.isSuccess) {
    String chatId = chatRes.data!["chatID"];

    await chatService.sendMessage(
      chatId: chatId,
      sender: alice,
      text: "Hi Bob! Zeytin Engine works perfectly.",
      messageType: ZeytinXMessageType.text,
    );
  }

  // 6. Cleanup
  await zeytin.deleteAll();
}
