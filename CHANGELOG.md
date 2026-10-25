# Changelog

## 1.0.0
- `android-create <Name> <package>`: new Kotlin + Jetpack Compose app from the terminal
- Reuses Gradle wrapper, AGP/Kotlin/library versions and compileSdk from your newest synced Android Studio project
- Supports AGP 9 built-in Kotlin and older kotlin-android setups
- One-click Run in VS Code (F5): build, install, restart the app and show its logs
- `./run-android.sh --watch`: rebuild and restart automatically on every save
- `android-create --vscode [DIR]`: add one-click Run to existing projects
- `android-create doctor`: check JDK, SDK, reference project, mirrors and devices
- `install.sh --iran`: Gradle mirrors and download retries for restricted networks
