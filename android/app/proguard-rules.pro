# Flutter
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }

# Firebase
-keep class com.google.firebase.** { *; }
-dontwarn com.google.firebase.**

# Google Sign-In
-keep class com.google.android.gms.** { *; }
-dontwarn com.google.android.gms.**

# Keep model classes
-keep class com.lamsa.application.** { *; }

# Prevent R8 from removing needed classes
-keepattributes *Annotation*
-keepattributes SourceFile,LineNumberTable
