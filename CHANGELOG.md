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

- **ZeytinXMiner**: Artık verilere ulaşmak için doğrudan RAM'i kullanabilirsin! Bunun için bir işçiyi (Stream) göreve ata ve senin için veritabanını kazıyarak verileri RAM'e çeksin. Ve bom! Artık verilerine `await` kullanmadan erişebilirsin.
- **isInitialized** (getter): Zeytin motoru başlatıldı mı?
- **multiple**: Çoklu kutular arasında tek seferde birden fazla işlem yapabilirsin. Bu kodunun içinde kategorizasyonu ve düzeni destekler. DİKKAT: Daha az geri bildirim alacaksın.
- **update**: Çok pratik bir veri güncelleme metodu eklendi. Eski veriyi okur, sizin fonksiyonunuza verir, güncellediğiniz veriyi alıp otomatik olarak aynı yere tekrar yazar (üzerine yazar).
- getAllBoxes: Tüm kutuları çağır. "Bunu neden daha önce eklemediniz?" diyebilirsin. İnan ki sadece unuttum...
- exportToStream: Verileri, yavaş yavaş kazıyarak çeker. Bu sayede sistem yorulmaz. Bu işlemin sonunda elinizde tüm veritabanı olacak.
- exportToJson: Verileri tek seferde çeker ve size verir. Bu işlemin sonunda elinizde tüm veritabanı olacak. DİKKAT: Bu işlem çok fazla RAM tüketebilir.
- importFromJson: Tek seferde koca bir veritabanını sıfırdan (belki de bir yedek ile?) yazmanızı sağlar. Veri taşıma işleminde önerilir.
- `import 'dart:convert';`: Yeni kütüphane eklendi.

## 1.3.1

- The document (README.md) has been updated.
