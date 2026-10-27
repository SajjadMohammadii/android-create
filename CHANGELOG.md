# Changelog

## 1.1.0
- `android-create fetch group:artifact:version`: download a library in resumable pieces, verify its SHA-1 and install it in `~/.m2`, for big files that unstable mirrors keep cutting off
- `android-create gradle <tasks>`: run `./gradlew`, retry network failures and fetch the files that failed to download
- `run-android.sh` builds through `android-create gradle` when it is installed
- The `--iran` mirrors script reads fetched modules from `~/.m2` first (run `bash install.sh --iran` again to update it)
- `doctor` reports fetched libraries and an outdated mirrors script

## 1.0.0
- `android-create <Name> <package>`: new Kotlin + Jetpack Compose app from the terminal
- Reuses Gradle wrapper, AGP/Kotlin/library versions and compileSdk from your newest synced Android Studio project
- Supports AGP 9 built-in Kotlin and older kotlin-android setups
- One-click Run in VS Code (F5): build, install, restart the app and show its logs
- `./run-android.sh --watch`: rebuild and restart automatically on every save
- `android-create --vscode [DIR]`: add one-click Run to existing projects
- `android-create doctor`: check JDK, SDK, reference project, mirrors and devices
- `install.sh --iran`: Gradle mirrors and download retries for restricted networks
