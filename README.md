# android-create

Create Android apps (Kotlin + Jetpack Compose) from the terminal, like `flutter create`, and run them on your phone with one key in VS Code.

```bash
android-create MyApp com.yourname.myapp
```

The project is generated, opened in VS Code, and pressing **F5** builds it, installs it on your phone and starts it.

---

## Contents

1. [Features](#features)
2. [Requirements](#requirements)
3. [Installation](#installation)
4. [Usage](#usage)
5. [Running on a Device](#running-on-a-device)
6. [Building an APK](#building-an-apk)
7. [How It Works](#how-it-works)
8. [Restricted Networks](#restricted-networks)
9. [Troubleshooting](#troubleshooting)
10. [Uninstall](#uninstall)
11. [Limitations](#limitations)
12. [Contributing](#contributing)
13. [License](#license)

---

## Features

- **One command** creates a complete Kotlin + Jetpack Compose project (Version Catalog, Kotlin DSL, release configuration).
- **One key to run** in VS Code: `F5` builds, installs, restarts the app with your latest changes and streams its logs.
- **Auto-reload**: rebuilds and restarts the app every time you save a file.
- **Uses your existing setup**: Gradle, AGP, Kotlin and library versions are copied from your newest Android Studio project, so new projects build with what already works on your machine.
- **AGP 9 ready**: supports built-in Kotlin as well as the classic `kotlin-android` plugin.
- **`doctor` command** that checks your JDK, SDK, reference project and connected devices.
- **Optional network setup** for regions where Google and Gradle servers are restricted.

---

## Requirements

| Requirement      | Notes                                                                 |
| ---------------- | --------------------------------------------------------------------- |
| Linux            | Tested on Ubuntu. Windows and macOS are not supported yet.            |
| Android Studio   | Provides the Android SDK, a JDK and the first Gradle sync.            |
| VS Code          | The `code` command must be available in the terminal.                 |
| Android device   | Connected over USB, or via wireless debugging on Android 11 or later. |

---

## Installation

### Step 1: Prepare Android Studio

> **This step is required.** android-create copies its configuration from the newest project that has **synced successfully** in Android Studio. Without one, it falls back to built-in defaults that may not match your installed SDK.

1. Install Android Studio and launch it once. The setup wizard installs the Android SDK into `~/Android/Sdk`.

   ```bash
   sudo snap install android-studio --classic
   ```

2. Create a project with **File > New > New Project > Empty Activity**. Keep the default location, `~/AndroidStudioProjects`.

3. Wait until **Gradle sync finishes without errors**. The first sync downloads several hundred megabytes and can take a few minutes. If it fails, see [Troubleshooting](#troubleshooting).

4. Open **Tools > SDK Manager** and make sure the following are installed:

   | Tab           | Package                                                          |
   | ------------- | ---------------------------------------------------------------- |
   | SDK Platforms | The version used by the project (`compileSdk` in `app/build.gradle.kts`) |
   | SDK Tools     | Android SDK Build-Tools                                          |
   | SDK Tools     | Android SDK Platform-Tools                                       |
   | SDK Tools     | Android SDK Command-line Tools                                   |

5. *(Recommended)* Run the app once from Android Studio to confirm everything works.

You do not need to open Android Studio again after this.

### Step 2: Install android-create

```bash
git clone https://github.com/SajjadMohammadii/android-create.git
cd android-create
bash install.sh
source ~/.bashrc
```

In regions with restricted access to Google or Gradle servers, use `bash install.sh --iran` instead. See [Restricted Networks](#restricted-networks).

The installer:

- installs the command to `~/.local/bin/android-create`;
- sets `PATH`, `ANDROID_HOME` and `JAVA_HOME` in `~/.bashrc`, pointing `JAVA_HOME` to Android Studio's bundled JDK so the terminal and the IDE share one Gradle daemon.

Running the installer again updates the command without duplicating any settings.

### Step 3: Verify

```bash
android-create doctor
```

The output should end with `Everything looks good.`

---

## Usage

### Create a project

```bash
android-create <Name> <package> [options]
```

| Argument / Option | Description                                                            |
| ----------------- | ---------------------------------------------------------------------- |
| `Name`            | App and folder name. Letters, digits and `_`, starting with a letter.  |
| `package`         | Application ID, for example `com.yourname.myapp`.                      |
| `--min-sdk N`     | Minimum Android API level, 21 to 36. Default: `24`.                    |
| `--no-open`       | Do not open the project in VS Code.                                    |

> **Choose the application ID carefully.** It cannot be changed after the app is published, and app stores reject `com.example`.

### All commands

| Command                                     | Description                                          |
| ------------------------------------------- | ---------------------------------------------------- |
| `android-create <Name> <package>`           | Create a new project                                 |
| `android-create --vscode [DIR]`             | Add one-key Run to an existing project               |
| `android-create doctor`                     | Check the development environment                    |
| `android-create gradle <tasks...>`          | Run `./gradlew`, retrying network failures and fetching files the connection keeps cutting off |
| `android-create fetch group:artifact:version` | Download one library in resumable, SHA-1 verified pieces into `~/.m2` |
| `android-create --version`                  | Show the version                                     |
| `android-create --help`                     | Show help                                            |

### Environment variables

| Variable             | Description                                                                |
| -------------------- | -------------------------------------------------------------------------- |
| `ANDROID_CREATE_REF` | Path of the Android Studio project to copy configuration from.             |
| `ANDROID_SERIAL`     | Device to run on when several are connected (used by `run-android.sh`).    |
| `ANDROID_CREATE_ATTEMPTS` | How many times `android-create gradle` tries a build that fails on the network (default 8). |

### Generated project

```text
MyApp/
├── app/
│   ├── build.gradle.kts
│   ├── proguard-rules.pro
│   └── src/main/
│       ├── AndroidManifest.xml
│       ├── java/com/yourname/myapp/MainActivity.kt
│       └── res/values/
│           ├── strings.xml
│           └── themes.xml
├── gradle/
│   ├── libs.versions.toml
│   └── wrapper/
├── .vscode/
│   ├── launch.json
│   ├── settings.json
│   └── tasks.json
├── build.gradle.kts
├── gradle.properties
├── gradlew
├── run-android.sh
└── settings.gradle.kts
```

---

## Running on a Device

### Prepare the device (once)

1. Open **Settings > About phone** and tap **Build number** seven times to enable Developer options.
2. Open **Settings > Developer options** and enable **USB debugging**. On Xiaomi devices, also enable **Install via USB**.
3. Connect the device and accept the **Allow USB debugging** prompt. Select **Always allow from this computer**.
4. Confirm the device is listed with the state `device`:

   ```bash
   adb devices
   ```

### Run from VS Code

| Action                                                    | Shortcut          |
| --------------------------------------------------------- | ----------------- |
| Build, install, restart the app and show its logs         | `F5`              |
| Run again with your latest changes                        | `Ctrl+Shift+F5`   |
| Same as `F5`, as a build task                             | `Ctrl+Shift+B`    |
| Rebuild and restart automatically on every save           | Select **Run on Android (auto-reload on save)** in the Run and Debug panel, then press `F5` |

### Run from the terminal

```bash
./run-android.sh              # build, install, restart and show logs
./run-android.sh --watch      # rebuild and restart on every save
./run-android.sh --no-logs    # do not show logs after starting
./run-android.sh --release    # use the release build type
```

Every run stops the running app and starts the newly installed build, so you always see your latest changes.

When `android-create` is installed, `run-android.sh` builds through `android-create gradle`, so a dropped connection is retried instead of failing the run.

### Add one-key Run to an existing project

```bash
android-create --vscode ~/AndroidStudioProjects/SomeApp
```

Existing files with the same names are backed up with a `.bak` suffix.

---

## Building an APK

### Debug APK

For testing or sharing. It is signed with a debug key and cannot be published.

```bash
./gradlew assembleDebug
```

Output: `app/build/outputs/apk/debug/app-debug.apk`

### Release APK

A release APK must be signed with your own key. The setup below is done once per app.

**1. Create a keystore**

```bash
mkdir -p ~/keys
keytool -genkeypair -v -keystore ~/keys/myapp.jks -alias myapp \
  -keyalg RSA -keysize 2048 -validity 10000
```

> **Back up the keystore file and its password in several safe places.** If you lose them, you can never publish an update to your app again.

**2. Create `key.properties` in the project root**

This file is listed in `.gitignore` and must never be committed.

```properties
storeFile=/home/<user>/keys/myapp.jks
storePassword=<password>
keyAlias=myapp
keyPassword=<password>
```

**3. Configure signing in `app/build.gradle.kts`**

At the top of the file:

```kotlin
import java.util.Properties

val keystoreProps = Properties().apply {
    val file = rootProject.file("key.properties")
    if (file.exists()) file.inputStream().use { load(it) }
}
```

Inside the `android { }` block, before `buildTypes`:

```kotlin
signingConfigs {
    create("release") {
        if (keystoreProps.isNotEmpty()) {
            storeFile = file(keystoreProps["storeFile"] as String)
            storePassword = keystoreProps["storePassword"] as String
            keyAlias = keystoreProps["keyAlias"] as String
            keyPassword = keystoreProps["keyPassword"] as String
        }
    }
}
```

Inside `buildTypes { release { } }`:

```kotlin
signingConfig = signingConfigs.getByName("release")
```

**4. Build**

```bash
./gradlew assembleRelease
```

Output: `app/build/outputs/apk/release/app-release.apk`

> Before every release, increase `versionCode` and update `versionName` in `app/build.gradle.kts`. App stores reject a `versionCode` that was already published.

---

## How It Works

1. **Find a reference project.** The newest project in `~/AndroidStudioProjects` that contains a Gradle wrapper.
2. **Copy its configuration.**
   - Gradle wrapper, so the Gradle distribution already on your machine is reused
   - AGP, Kotlin, Compose BOM and AndroidX library versions
   - `compileSdk`, and `buildToolsVersion` when set
3. **Detect the Kotlin setup.** AGP 9 built-in Kotlin, or the `kotlin-android` plugin.
4. **Generate the project**, including `run-android.sh` and the VS Code configuration.

`run-android.sh` reads the application ID from `app/build.gradle.kts` at runtime, so renaming the package keeps it working.

---

## Restricted Networks

Some Google and Gradle servers are not reachable from certain regions, including Iran. The installer can configure Gradle for this:

```bash
bash install.sh --iran
```

| Change                                                | Effect                                                                                     |
| ----------------------------------------------------- | ------------------------------------------------------------------------------------------ |
| `~/.gradle/init.d/android-create-mirrors.gradle`      | Adds [Aliyun](https://developer.aliyun.com/mvn/guide) Maven mirrors first for every Gradle build: Android Studio, android-create and Flutter projects. No per-project changes needed. |
| `~/.gradle/gradle.properties`                         | Increases download retries and timeouts so short connection drops do not fail the build.  |

### Big files that never finish downloading

On unstable connections the mirrors often cut large libraries off half way (the Kotlin compiler, KSP, Robolectric's Android runtime: 40 to 200 MB). Gradle then starts the file over from zero on every retry and never finishes it.

`android-create gradle` handles this for you: when a build fails with `Could not download <file> (<group:artifact:version>)`, it fetches that file itself and runs the build again. You can also fetch a library by hand:

```bash
android-create fetch org.jetbrains.kotlin:kotlin-compiler-embeddable:2.2.0
```

`fetch` downloads in resumable pieces (each drop continues where it stopped, alternating Maven Central, Aliyun and Google), checks the repository's SHA-1, and installs the library, its POM and any parent POM in `~/.m2/repository`. Fetched modules are listed in `~/.m2/android-create-fetched.txt`; the mirrors script installed by `bash install.sh --iran` reads exactly those modules from `~/.m2` first, in every project, with no change to the project itself.

### Installing SDK packages through a mirror

The SDK Manager downloads from `dl.google.com`. If it is unreachable, use the Tencent Cloud mirror:

```bash
SDK_TEST_BASE_URL=https://mirrors.cloud.tencent.com/AndroidSDK/ \
  ~/Android/Sdk/cmdline-tools/latest/bin/sdkmanager "build-tools;36.0.0"
```

Replace `build-tools;36.0.0` with the package you need, for example `platforms;android-36`.

---

## Troubleshooting

Start with:

```bash
android-create doctor
```

<details>
<summary><code>Plugin 'org.gradle.toolchains.foojay-resolver-convention' was not found</code></summary>

<br>

New Android Studio templates add this plugin to download JDKs automatically. It is not needed when a JDK is installed. Remove this block from `settings.gradle.kts`:

```kotlin
plugins {
    id("org.gradle.toolchains.foojay-resolver-convention") version "..."
}
```

</details>

<details>
<summary><code>Build was configured to prefer settings repositories over project repositories but repository 'maven' was added by initialization script</code></summary>

<br>

An older script in `~/.gradle/init.d/` adds repositories to every project, which new templates forbid. Disable it and install the compatible mirrors:

```bash
mv ~/.gradle/init.d/<old-script>.gradle ~/.gradle/init.d/<old-script>.gradle.bak
bash install.sh --iran
```

</details>

<details>
<summary><code>Plugin [id: 'com.android.application', version: '...'] was not found</code></summary>

<br>

Gradle caches "not found" results for 24 hours. Force a fresh lookup:

```bash
./gradlew help --refresh-dependencies
```

Also make sure **Offline Mode** is turned off in Android Studio's Gradle panel.

</details>

<details>
<summary><code>Remote host terminated the handshake</code></summary>

<br>

The connection dropped during a download. Build through `android-create gradle`, which retries and fetches files that keep getting cut off:

```bash
android-create gradle assembleDebug
```

`bash install.sh --iran` raises the number of automatic retries. See [Big files that never finish downloading](#big-files-that-never-finish-downloading).

</details>

<details>
<summary><code>Unable to download toolchain matching the requirements ({languageVersion=25, ...})</code></summary>

<br>

The project requests a specific JDK in `gradle/gradle-daemon-jvm.properties`. Either point `JAVA_HOME` to Android Studio's bundled JDK (the installer does this), or disable the requirement:

```bash
mv gradle/gradle-daemon-jvm.properties gradle/gradle-daemon-jvm.properties.bak
```

In Android Studio, set **Settings > Build, Execution, Deployment > Build Tools > Gradle > Gradle JDK** to the bundled JDK (`jbr`).

</details>

<details>
<summary><code>Failed to find target with hash string 'android-XX'</code></summary>

<br>

The SDK platform required by `compileSdk` is not installed. Install it with the SDK Manager, or lower `compileSdk` and `targetSdk` in `app/build.gradle.kts` to an installed version:

```bash
ls ~/Android/Sdk/platforms
```

</details>

<details>
<summary><code>Failed to find Build Tools revision XX</code></summary>

<br>

Install the required version with the SDK Manager, or through the mirror described in [Restricted Networks](#restricted-networks).

</details>

<details>
<summary><code>adb</code> shows <code>no permissions</code> or <code>unauthorized</code></summary>

<br>

**`no permissions`:**

```bash
sudo apt install android-sdk-platform-tools-common
sudo usermod -aG plugdev $USER
```

Log out and back in, then reconnect the device.

**`unauthorized`:** unlock the device and accept the USB debugging prompt.

**Empty list:** try another cable (some cables only charge) and set the USB mode to **File transfer**.

</details>

<details>
<summary><code>F5</code> does nothing in VS Code</summary>

<br>

- Open the project folder itself in VS Code, not a parent folder.
- Make sure the script is executable: `chmod +x run-android.sh`.
- Use `Ctrl+Shift+B` or `./run-android.sh`, which do the same thing.

</details>

<details>
<summary><code>code: command not found</code></summary>

<br>

```bash
sudo snap install code --classic
```

Or, in VS Code: `Ctrl+Shift+P` > **Shell Command: Install 'code' command in PATH**.

</details>

<details>
<summary>Gradle does not use my HTTP proxy</summary>

<br>

Gradle ignores the `http_proxy` environment variables. Add your proxy to `~/.gradle/gradle.properties`:

```properties
systemProp.http.proxyHost=127.0.0.1
systemProp.http.proxyPort=10809
systemProp.https.proxyHost=127.0.0.1
systemProp.https.proxyPort=10809
```

Gradle cannot download anything while the proxy is off.

</details>

---

## Uninstall

```bash
bash install.sh --uninstall
```

This removes the command, its `~/.bashrc` settings and, if installed, the network settings. Your projects are not affected.

---

## Limitations

- **Linux only.** Tested on Ubuntu.
- **Auto-reload is not hot reload.** Each change triggers a rebuild, reinstall and restart, which takes a few seconds and resets the app state. For instant UI previews, use Compose Preview or Live Edit in Android Studio.
- `run-android.sh` runs the `app` module only.

---

## Contributing

Issues and pull requests are welcome. Please run ShellCheck before submitting:

```bash
shellcheck -S warning bin/android-create install.sh
```

---

## License

[MIT](LICENSE)
