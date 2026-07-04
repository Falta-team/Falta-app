# falta_feature brick

قالب Mason بيولّد فيتشر كامل بنفس بنية مشروع falta_app:
`data/models`, `data/repositories`, `domain/entities`, `domain/repositories`,
`domain/usecases`, `presentation/screens`, `presentation/widgets` + تيست تجريبي.

## 1. تثبيت Mason CLI (مرة وحدة بس)

```bash
dart pub global activate mason_cli
```

تأكد إنه اشتغل:
```bash
mason --version
```

## 2. ربط الـ brick بمشروعك

انسخ مجلد `feature_brick` كامل (هذا الملف + brick.yaml + __brick__) جوا
مشروع falta_app، مثلاً تحت مجلد جديد اسمه `bricks/`:

```
falta_app/
  bricks/
    feature_brick/
      brick.yaml
      __brick__/
  lib/
  pubspec.yaml
```

من جذر مشروع falta_app نفذ:
```bash
mason add falta_feature --path bricks/feature_brick
```

هاد بيضيف الـ brick لملف `mason.yaml` (بينخلق تلقائياً لو مش موجود).

## 3. توليد فيتشر جديد

من جذر المشروع:
```bash
mason make falta_feature
```
رح يسألك:
```
What is the feature name? notifications
```

بعد ما تكتب الاسم، رح يتولد تلقائياً:
```
lib/features/notifications/
  data/
    models/notifications_model.dart
    repositories/notifications_repository_impl.dart
  domain/
    entities/notifications_entity.dart
    repositories/notifications_repository.dart
    usecases/get_notifications.dart
  presentation/
    screens/notifications_screen.dart
    widgets/notifications_card.dart

test/features/notifications/domain/usecases/get_notifications_test.dart
```

ممكن كمان تمرر الاسم مباشرة بدون ما ينطرح عليك سؤال:
```bash
mason make falta_feature --feature_name subscription
```

## 4. متطلبات إضافية على pubspec.yaml

التيست المولّد بيحتاج باكج `mocktail` (للموك بالتيستات). أضفه إذا مش موجود:
```bash
flutter pub add dev:mocktail
```

## ملاحظات

- القالب بيستخدم `domain` (مش `domin`) — لاحظ إنه الفيتشرز القديمة (auth, courses,
  exams, profile, subscription) عندها typo بمجلد `domin`. لو رح تعدل القديم
  لاحقاً، خليه يطابق هاي التسمية الصح.
- الفيتشرز اللي اسمها أكتر من كلمة (مثلاً "user profile") اكتبها بمسافة عادي،
  الـ brick بيحولها تلقائياً لصيغة snake_case / PascalCase / إلخ حسب مكان
  الاستخدام.
- عدّل محتوى القوالب داخل `__brick__/` متى ما بدك تغيّر الشكل الافتراضي
  (مثلاً تضيف state management bloc/cubit لكل فيتشر).
