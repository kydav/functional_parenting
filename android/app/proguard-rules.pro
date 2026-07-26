# Keep source/line info so Crashlytics stack traces stay readable.
-keepattributes SourceFile,LineNumberTable
-keepattributes *Annotation*,Signature,Exceptions,InnerClasses
-renamesourcefileattribute SourceFile

# Flutter embedding (usually covered by Flutter's own rules, kept defensively).
-keep class io.flutter.** { *; }
-dontwarn io.flutter.**

# Firebase / Google (ship consumer rules, but keep to be safe with R8).
-keep class com.google.firebase.** { *; }
-keep class com.google.android.gms.** { *; }
-dontwarn com.google.firebase.**
-dontwarn com.google.android.gms.**

# RevenueCat (purchases_flutter).
-keep class com.revenuecat.purchases.** { *; }
-dontwarn com.revenuecat.purchases.**

# Play Core (used by Flutter's deferred components; avoid missing-class warnings).
-dontwarn com.google.android.play.core.**
