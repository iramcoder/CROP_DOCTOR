# Keep all TensorFlow Lite classes from being deleted by R8 Minifier
-keep class org.tensorflow.lite.** { *; }
-dontwarn org.tensorflow.lite.**