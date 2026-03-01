# ZeytinX 🫒

Developed with love by JeaFriday!

<p align="center">
  <a href="https://buymeacoffee.com/jeafriday">
    <img src="https://img.buymeacoffee.com/button-api/?text=Support me&emoji=☕&slug=jeafriday&button_colour=FFDD00&font_colour=000000&font_family=Cookie&outline_colour=000000&coffee_colour=ffffff" alt="Support me" />
  </a>
</p>

<p align="center">
  <a href="https://github.com/JeaFrid">
    <img src="https://img.shields.io/badge/GitHub-181717?style=for-the-badge&logo=github&logoColor=white" alt="GitHub" />
  </a>
  <a href="https://pub.dev/publishers/jeafriday.com/packages">
    <img src="https://img.shields.io/badge/Pub.dev-0175C2?style=for-the-badge&logo=dart&logoColor=white" alt="Pub.dev" />
  </a>
  <a href="https://www.linkedin.com/in/jeafriday/">
    <img src="https://img.shields.io/badge/LinkedIn-0A66C2?style=for-the-badge&logo=linkedin&logoColor=white" alt="LinkedIn" />
  </a>
  <a href="https://t.me/jeafrid">
    <img src="https://img.shields.io/badge/Telegram-26A8EA?style=for-the-badge&logo=telegram&logoColor=white" alt="Telegram" />
  </a>
</p>

| Phase / Test               | Description                                    | Volume / Details       | Execution Time |
| :------------------------- | :--------------------------------------------- | :--------------------- | :------------- |
| **Preparation**            | Mock data generation in RAM                    | 60,000 items           | -              |
| **Test 1.1: Batch Write**  | Single operation insertion (`addBatch`)        | 50,000 items           | 1,731 ms       |
| **Test 1.2: Single Write** | Individual sequential insertions (`add`)       | 10,000 items           | 110 ms         |
| **Maintenance**            | Database compaction & index repair (`compact`) | Entire DB              | 4,644 ms       |
| **Test 2: Read**           | Random individual data retrieval               | 1,000 items (0 errors) | 3,104 ms       |
| **Test 3: Update**         | Random individual data modification            | 1,000 items (0 errors) | 2,878 ms       |
| **Verification**           | Cold read from disk after clearing RAM         | 9.23 MB file size      | 1,818 ms       |
| **Test 4: Delete**         | Individual deletions (blocks of 10,000)        | 60,000 items           | 319 ms         |



**ZeytinX** is an "all-inclusive" local data management and module library prepared to develop massive, large-scale applications (social media, e-commerce, forum, messaging, community, etc.) using the `zeytin_local_storage` infrastructure.

This package; offers almost everything an application might need under a single roof with standardized models, from user management to real-time chat, from Discord-like community structures to e-commerce carts.

## 📖 Table of Contents

1. [Installation](#1-installation)
2. [Basic Concepts and Helpers](#2-basic-concepts-and-helpers)
   - ZeytinXResponse
   - ZeytinXPrint & Time Format
3. [ZeytinX Engine (Core Database)](#3-zeytinx-engine-core-database)
   - Initialization
   - Basic CRUD Operations (Add, Get, Update, Remove)
   - Batch Operations and Export/Import
4. [ZeytinXMiner 🚀 (Lightning Fast Data Over RAM)](#4-zeytinx-miner--lightning-fast-data-over-ram)
5. [Modules and Services](#5-modules-and-services)
   - [👤 User Management (ZeytinXUser)](#-user-management-zeytinxuser)
   - [🌍 Social Media (ZeytinXSocial)](#-social-media-zeytinxsocial)
   - [💬 Chat and Messaging (ZeytinXChat)](#-chat-and-messaging-zeytinxchat)
   - [🏰 Community System (ZeytinXCommunity)](#-community-system-zeytinxcommunity)
   - [🛍️ E-Commerce (Store & Products)](#-e-commerce-store--products)
   - [🏛️ Forum System (ZeytinXForum)](#-forum-system-zeytinxforum)
   - [📚 Library / Books (ZeytinXLibrary)](#-library--books-zeytinxlibrary)
   - [🔔 Notification System (ZeytinXNotification)](#-notification-system-zeytinxnotification)
6. [Full Enum List](#6-full-enum-list)

---

## 1. Installation

Add the packages to your `pubspec.yaml` file:

```
flutter pub add zeytinx
```

or

```yaml
dependencies:
  zeytinx: ^1.3.0
```

Include it in your project:

```dart
import 'package:zeytinx/zeytinx.dart';
```

---

## 2. Basic Concepts and Helpers

Before moving on to ZeytinX's modules, you must know how the system talks to you.

### ZeytinXResponse

Almost every function in ZeytinX (creating a user, sending a message, fetching data) returns you a standard `ZeytinXResponse` object.

```dart
class ZeytinXResponse {
  final bool isSuccess; // Is the operation successful?
  final String message; // Operation result message ("Oki Doki!", "Error", etc.)
  final Map<String, dynamic>? data; // Returned data (if any)
  final String? error; // Error detail (if any)
}
```

### ZeytinXPrint & Extensions

Tools are available to colorize your console outputs and convert dates to social media format.

```dart
// Colored console outputs
ZeytinXPrint.successPrint("User added!"); // Green
ZeytinXPrint.errorPrint("Password too short!"); // Red
ZeytinXPrint.warningPrint("Attention, missing data."); // Yellow

// Date Formatting (Social media style)
DateTime date = DateTime.now().subtract(Duration(hours: 2));
print(date.timeAgo); // Output: "2 hours ago" (or "Just now", "3 days ago", etc.)
```

---

## 3. ZeytinX Engine (Core Database)

All modules in the ZeytinX package basically require the `ZeytinX` class or directly `ZeytinStorage`. Let's boot up our database first.

### Starting the Engine

```dart
import 'package:zeytinx/zeytinx.dart';

void main() async {
  // We set up the engine by determining Namespace and TruckID (Truck Identity).
  final coreDB = ZeytinX("my_app_namespace", "main_truck");

  // We start the engine by providing a directory.
  await coreDB.initialize("./my_local_database");

  if(coreDB.isInitialized) {
    ZeytinXPrint.successPrint("Engine is ready!");
  }
}
```

### Basic CRUD (Add, Read, Update, Delete)

If you want to write your own custom data instead of using ready-made modules, you can use `coreDB`'s basic methods.

```dart
// 1. Adding Data (Add)
ZeytinXResponse addRes = await coreDB.add(
  box: "my_custom_box", // Table / Box name
  tag: "user_123",      // Unique key (Assigns UUID if left empty)
  value: {"name": "Jea", "role": "Admin"}, // Map to be stored
);

// 2. Reading Data (Get)
ZeytinXResponse getRes = await coreDB.get(box: "my_custom_box", tag: "user_123");
if (getRes.isSuccess) {
  print(getRes.data?['value']); // {"name": "Jea", "role": "Admin"}
}

// 3. Updating Data (Update - came with v1.3.0)
// Gives you the previous data, you save it back in its updated form.
await coreDB.update(
  box: "my_custom_box",
  tag: "user_123",
  value: (currentValue) async {
    currentValue["role"] = "SuperAdmin";
    return currentValue;
  }
);

// 4. Deleting Data (Remove)
await coreDB.remove(box: "my_custom_box", tag: "user_123");
```

### Batch Operations and Export/Import (Backup)

Methods that came with v1.3.0 to move, export, or perform multiple operations on the database:

```dart
// Export the entire database as JSON (Watch out for RAM!)
var exportRes = await coreDB.exportToJson();

// Slowly extract the data without tiring the system
coreDB.exportToStream().listen((res) {
  print("Box exported: ${res.message}");
});

// Set up the massive database from scratch from a ready JSON backup
await coreDB.importFromJson(jsonStr: '{"box1": {"tag1": {"a": "b"}}}');

// Multiple Box Operation (Intervening in many boxes at the same time)
await coreDB.multiple(
  processes: (boxes) async {
    // Perform operations on all boxes...
    return ZeytinXResponse(isSuccess: true, message: "Done");
  },
  onSuccess: () async => ZeytinXResponse(isSuccess: true, message: "Successful"),
  onError: (e, s) async => ZeytinXResponse(isSuccess: false, message: e),
);
```

---

## 4. ZeytinXMiner 🚀 (Lightning Fast Data Over RAM)

**ZeytinXMiner**, which came with v1.3.0, mines your database from your disk and extracts it to RAM (memory). You no longer need to use `await` to access data!

```dart
// Connect the engine to the miner
final miner = ZeytinXMiner(coreDB);

// Assign workers to the task. Starts copying the database to RAM in the background.
miner.assignWorkers();

// Access data SYNCHRONOUSLY (without await)! BOOM!
Map<String, dynamic>? userData = miner.get("my_custom_box", "user_123");

// Filter all data in the box (Works instantly)
List<Map<String, dynamic>> admins = miner.filter(
  "my_custom_box",
  (data) => data["role"] == "Admin"
);

// Dispose of it to prevent memory leaks when you are done
miner.dispose();
```

---

## 5. Modules and Services

The real power of ZeytinX is the ready-made massive architectures it wrote for you. All services work with the `ZeytinStorage` class under the engine.

### 👤 User Management (`ZeytinXUser`)

Manages registration, login, following, blocking, and activity status. All these operations return via `ZeytinXUserModel`. Everything including the user's school, job, address, theme, and biography has been thought of inside the class.

```dart
// Start the service
final userService = ZeytinXUser(coreDB.zeytin!);

// 1. Register
ZeytinXResponse registerRes = await userService.create(
  "jeafriday",             // Username
  "jea@example.com",       // Email
  "securepassword123"      // Password (Must be at least 6 characters)
);

// 2. Login
ZeytinXResponse loginRes = await userService.login("jea@example.com", "securepassword123");
ZeytinXUserModel myUser = ZeytinXUserModel.fromJson(loginRes.data!);

// 3. Following / Unfollowing a User
await userService.followUser(myUid: myUser.uid, targetUid: "target_id");
bool isFollowing = await userService.isFollow(myUid: myUser.uid, targetUid: "target_id");
await userService.unfollowUser(myUid: myUser.uid, targetUid: "target_id");

// 4. Blocking a User
await userService.blockUser(myUid: myUser.uid, targetUid: "target_id");

// 5. Activity Status (Online/Offline)
await userService.updateUserActive(myUser); // Updates last seen
bool online = await userService.isActive(myUser, thresholdSeconds: 30); // 30 seconds rule
```

---

### 🌍 Social Media (`ZeytinXSocial`)

Covers post sharing, liking, commenting, and comment liking operations. The basic model is `ZeytinXSocialModel`.

```dart
final socialService = ZeytinXSocial(coreDB.zeytin!);

// 1. Creating a Post
var newPost = ZeytinXSocialModel(
  user: myUser,
  text: "Writing code with ZeytinX is great!",
  category: "Software",
  images: ["url1.jpg", "url2.jpg"] // Optional
);
ZeytinXResponse postRes = await socialService.createPost(postModel: newPost);
String postId = postRes.data!["id"];

// 2. Liking a Post and Removing the Like
await socialService.addLike(user: myUser, postID: postId);
await socialService.removeLike(user: myUser, postID: postId);

// 3. Commenting
var comment = ZeytinXSocialCommentsModel(
  user: myUser,
  text: "I totally agree!"
);
await socialService.addComment(comment: comment, postID: postId);

// 4. Liking a Comment
await socialService.addCommentLike(user: myUser, postID: postId, commentID: "comment_id");

// 5. Fetching the Feed (Feed)
List<ZeytinXSocialModel> feed = await socialService.getAllPost();
```

---

### 💬 Chat and Messaging (`ZeytinXChat`)

It is ideal for building structures similar to WhatsApp or Telegram. Supports end-to-end encryption keys, including Self Destruct messages.

```dart
final chatService = ZeytinXChat(coreDB.zeytin!);

// 1. Starting a Private or Group Chat
var chatRes = await chatService.createChat(
  chatName: "Coding Group",
  participants: [user1, user2],
  type: ZeytinXChatType.group, // private, group, channel, etc.
);
String chatId = chatRes.data!["chatID"];

// 2. Sending a Message
await chatService.sendMessage(
  chatId: chatId,
  sender: user1,
  text: "Greetings everyone!",
  messageType: ZeytinXMessageType.text, // image, video, file, system, etc.
);

// 3. Listening to Real-Time Messages
chatService.listen(
  chatId: chatId,
  onMessageReceived: (message) => print("New Message: ${message.text}"),
  onMessageUpdated: (message) => print("Edited: ${message.text}"),
  onMessageDeleted: (messageId) => print("Deleted: $messageId"),
);

// 4. Advanced Message Operations
await chatService.addReaction(messageId: "msg_id", userId: user1.uid, emoji: "🔥");
await chatService.starMessage(messageId: "msg_id", userId: user1.uid);
await chatService.markAsRead(messageId: "msg_id", userId: user1.uid);
await chatService.pinMessage(messageId: "msg_id", pinnedBy: user1.uid, chatId: chatId);

// 5. System Messages (E.g.: "Ahmet joined the group")
await chatService.createSystemMessage(
  chatId: chatId,
  type: ZeytinXSystemMessageType.userJoined,
  userName: "Ahmet"
);
```

---

### 🏰 Community System (`ZeytinXCommunity`)

Supports hierarchical structures in the style of Discord, Slack, or MS Teams. Includes invite codes (with limit and duration restrictions), sub-rooms, announcement boards.

```dart
final communityService = ZeytinXCommunity(coreDB.zeytin!);

// 1. Creating a Community (Server)
var comRes = await communityService.createCommunity(
  name: "Flutter Developers",
  creator: myUser,
  participants: [myUser],
  description: "Turkey's largest Flutter community!"
);
String comId = comRes.data!["id"];

// 2. Creating Sub Rooms (Channels)
await communityService.createRoom(
  communityId: comId,
  admin: myUser,
  roomName: "general-chat",
  type: ZeytinXRoomType.text, // can also be voice or announcement
);

// 3. Creating an Invite Code (Time and Use Limited)
var inviteRes = await communityService.createInviteCode(
  communityId: comId,
  admin: myUser,
  duration: Duration(days: 1), // Valid for 1 Day
  maxUses: 10,                 // Only 10 people can use it
);
String code = inviteRes.data!["code"];

// 4. Joining with an Invite Code (The other party's code)
var validate = await communityService.validateInviteCode(code: code);
if(validate.isSuccess) {
  await communityService.useInviteCode(code: code);
  await communityService.joinCommunity(communityId: comId, user: targetUser);
}

// 5. Sending a Board Announcement
await communityService.sendBoardPost(
  communityId: comId,
  sender: myUser,
  text: "Rules have been updated, please read."
);
```

---

### 🛍️ E-Commerce (Store & Products)

Prepares the database for store management, product showcase, stock, view counts, cart systems. (`ZeytinXStore` and `ZeytinXProducts`)

```dart
final storeService = ZeytinXStore(coreDB.zeytin!);
final productService = ZeytinXProducts(coreDB.zeytin!);

// 1. Opening a Store
var storeModel = ZeytinXStoreModel(
  id: "",
  name: "Jea's Tech Shop",
  description: "Cheap and quality technology.",
  owners: [myUser],
  isVerified: true,
);
var storeRes = await storeService.createStore(storeModel: storeModel);

// 2. Adding a Product
var productModel = ZeytinXProductModel(
  id: "",
  storeId: storeRes.data!["id"],
  title: "ZeytinX Pro License",
  price: 99.99,
  currency: "USD",
  stock: 150,
  category: "Software",
);
var prodRes = await productService.createProduct(productModel: productModel);

// 3. Increasing Product View Count
await productService.addView(productID: prodRes.data!["id"]);

// 4. Commenting/Rating a Product
var review = ZeytinXProductCommentModel(
  id: "",
  productId: prodRes.data!["id"],
  user: myUser,
  text: "A very fast database package, I loved it.",
  rating: 5.0
);
await productService.addComment(comment: review, productID: prodRes.data!["id"]);
```

---

### 🏛️ Forum System (`ZeytinXForum`)

It is for creating categorized discussion boards like DonanımHaber, Reddit, etc.

```dart
final forumService = ZeytinXForum(coreDB.zeytin!);

// 1. Create a Category
var cat = ZeytinXForumCategoryModel(id: "", title: "Technology News", description: "...");
var catRes = await forumService.createCategory(categoryModel: cat);

// 2. Open a Thread
var thread = ZeytinXForumThreadModel(
  id: "",
  categoryId: catRes.data!["id"],
  user: myUser,
  title: "Where is Artificial Intelligence Going?",
  content: "What do you think the latest language models..."
);
var threadRes = await forumService.createThread(threadModel: thread);

// 3. Enter an Entry (Reply) to the Thread
var entry = ZeytinXForumEntryModel(
  id: "",
  threadId: threadRes.data!["id"],
  user: user2,
  text: "I think they will take over humanity."
);
await forumService.addEntry(entry: entry, threadId: threadRes.data!["id"]);

// 4. Marking the Thread as Solved/Locked
await forumService.toggleThreadLock(threadId: threadRes.data!["id"], isLocked: true);
```

---

### 📚 Library / Books (`ZeytinXLibrary`)

It is for book reading, chapter adding, and book reviewing platforms similar to Wattpad or Goodreads.

```dart
final libService = ZeytinXLibrary(coreDB.zeytin!);

// 1. Create a Book
var book = ZeytinXBookModel(
  id: "",
  isbn: "978-3-16-148410-0",
  title: "Planet Dart",
  authors: [myUser],
  publisher: "JeaFriday Press",
  likes: []
);
var bookRes = await libService.createBook(bookModel: book);

// 2. Add a Chapter
var chapter = ZeytinXChapterModel(
  id: "",
  bookId: bookRes.data!["id"],
  title: "Chapter 1: Variables",
  content: "Once upon a time, starting with the word var...",
  order: 1
);
await libService.addChapter(chapter: chapter);

// 3. Search Book by ISBN
List<ZeytinXBookModel> results = await libService.searchByISBN("978-3-16-148410-0");
```

---

### 🔔 Notification System (`ZeytinXNotification`)

Allows you to send general announcements or In-App notifications to users.

```dart
final notifService = ZeytinXNotificationService(coreDB.zeytin!);

// 1. Sending In-App Notification
await notifService.sendInAppNotification(
  title: "New Follower",
  description: "Ahmet started following you.",
  tag: "follow_event",
  targetUserIds: [myUser.uid],
);

// 2. Fetching Unread Notifications
var pending = await notifService.getPendingInAppNotifications(myUser.uid);

// 3. Marking as Seen
await notifService.markAsSeen(notificationId: pending.first.id, userId: myUser.uid);
```

---

## 6. Full Enum List

Below are the enum definitions used in the package that standardize the database architecture. You can shape your application according to these rules without dealing with custom types.

**ZeytinOpType** (Database Operation Type):

- `put` / `update`: Adding/updating data
- `delete`: Single data deletion
- `deleteBox`: Deleting the table
- `batch`: Multiple data entry
- `clearAll`: Resetting everything

**ZeytinXChatType** (Chat Types):

- `private`: Private (One-to-one)
- `privGroup`: Private Group
- `superGroup`: Super Group
- `channel`: Announcement Channel
- `voiceChat`: Voice Chat Room
- `muteChat`: Mute Chat
- `group`: Normal Group

**ZeytinXMessageType** (Message Content Types):

- `text`: Text
- `image`: Image
- `video`: Video
- `audio`: Audio
- `file`: File
- `location`: Location
- `contact`: Contact Card
- `sticker`: Sticker
- `system`: System message (A joined, etc.)

**ZeytinXMessageStatus** (Message Delivery Status):

- `sending`: Sending
- `sent`: Reached the server
- `delivered`: Delivered to the other party
- `read`: Read
- `failed`: Failed to send

**ZeytinXSystemMessageType** (System Message Types):

- `userJoined`, `userLeft`, `groupCreated`, `nameChanged`, `photoChanged`, `adminAdded`, `adminRemoved`, `callStarted`, `callEnded`, `messagePinned`, `chatSecured`, `disappearingTimerChanged`, `none`.

**ZeytinXCommunityModelType** & **ZeytinXRoomType**:
Community types are similar to the chat structure. Sub rooms (Rooms) can be `text`, `voice`, or `announcement`.

**ZeytinXFileType**:
Media/file distinctions within the platform are kept as `image`, `video`, `doc`, `url`, `or`.

Support Zeytin!💚
