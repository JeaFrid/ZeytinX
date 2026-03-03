## 1.0.0

- Hiloo

## 1.1.0

- Dependency update due to the zeytin_local_storage update.

## 1.2.0

- The ZeytinX class has been developed.
- Database connection points have been created.

You can review: src/database.dart && utils/operation.dart

## 1.2.1

- License Changed

## 1.2.2

- Data security was ensured during data entry.
- Dependencies were reduced.

## 1.3.0

- **ZeytinXMiner**: You can now access data directly from RAM! To do this, assign a worker (Stream) to the task and let it mine the database and pull the data into RAM for you. And boom! You can now access your data without using `await`.
- **isInitialized** (getter): Has the Zeytin engine been started?
- **multiple**: You can perform multiple operations across multiple boxes at once. This supports categorization and organization within your code. NOTE: You will receive less feedback.
- **update**: A very practical data update method has been added. It reads the old data, gives it to your function, takes the updated data, and automatically writes it back to the same place (overwrites it).
- getAllBoxes: Call all boxes. You might ask, “Why didn't you add this before?” Believe me, I just forgot...
- exportToStream: Pulls the data slowly, bit by bit. This way, the system doesn't get overloaded. At the end of this process, you'll have the entire database.
- exportToJson: Pulls the data all at once and gives it to you. At the end of this process, you'll have the entire database. CAUTION: This process can consume a lot of RAM.
- importFromJson: Allows you to write an entire database from scratch (perhaps from a backup?) in one go. Recommended for data migration.
- `import ‘dart:convert’;`: New library added.

## 1.3.1

- The document (README.md) has been updated.

## 1.3.2

- The document (README.md) has been updated.

## 2.0.0

- The ZeytinX wrapper has been updated due to an update to the Zeytin engine (zeytin_local_storage package). Check the engine's change logs for all details.

## 2.1.0

- All ZeytinStorage classes have been recoded with ZeytinX. You will no longer need the zeytin_local_storage package for ZeytinStorage at the start.
- Some minor bug fixes.