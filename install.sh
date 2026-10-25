#!/usr/bin/env bash
# Installer for android-create (Linux).
#
#   bash install.sh             install / update android-create for the current user
#   bash install.sh --iran      also configure Gradle for restricted networks (mirrors + retries)
#   bash install.sh --uninstall remove android-create (and the --iran settings)

set -euo pipefail

HERE="$(cd "$(dirname "$0")" && pwd)"
BIN_DIR="$HOME/.local/bin"
RC="$HOME/.bashrc"
GRADLE_HOME_DIR="${GRADLE_USER_HOME:-$HOME/.gradle}"
INIT_SCRIPT="$GRADLE_HOME_DIR/init.d/android-create-mirrors.gradle"
GRADLE_PROPS="$GRADLE_HOME_DIR/gradle.properties"
MARK_BEGIN="# >>> android-create >>>"
MARK_END="# <<< android-create <<<"

IRAN=0; UNINSTALL=0
for arg in "$@"; do
    case "$arg" in
        --iran) IRAN=1 ;;
        --uninstall) UNINSTALL=1 ;;
        -h|--help) sed -n '2,7p' "$0"; exit 0 ;;
        *) echo "Unknown option: $arg" >&2; exit 2 ;;
    esac
done

remove_block() {  # remove_block <file>
    [[ -f "$1" ]] || return 0
    sed -i "/^$MARK_BEGIN\$/,/^$MARK_END\$/d" "$1"
}

if (( UNINSTALL )); then
    rm -f "$BIN_DIR/android-create" "$INIT_SCRIPT"
    remove_block "$RC"
    remove_block "$GRADLE_PROPS"
    echo "android-create removed. Open a new terminal to finish."
    exit 0
fi

# --- 1. Command ---------------------------------------------------------------
mkdir -p "$BIN_DIR"
install -m 755 "$HERE/bin/android-create" "$BIN_DIR/android-create"
echo "Installed: $BIN_DIR/android-create"

# --- 2. Environment variables in ~/.bashrc --------------------------------------
JBR=""
for d in /snap/android-studio/current/jbr /snap/android-studio/current/android-studio/jbr \
         /opt/android-studio/jbr "$HOME/android-studio/jbr" \
         "$HOME/.local/share/JetBrains/Toolbox/apps/android-studio/jbr" /usr/local/android-studio/jbr; do
    if [[ -x "$d/bin/java" ]]; then JBR="$d"; break; fi
done
SDK=""
for d in "${ANDROID_HOME:-}" "$HOME/Android/Sdk" "$HOME/Android/sdk"; do
    if [[ -n "$d" && -d "$d" ]]; then SDK="$d"; break; fi
done

remove_block "$RC"
{
    echo "$MARK_BEGIN"
    echo 'export PATH="$HOME/.local/bin:$PATH"'
    if [[ -n "$SDK" ]]; then
        echo "export ANDROID_HOME=\"$SDK\""
        echo 'export PATH="$ANDROID_HOME/platform-tools:$PATH"'
    fi
    # Use Android Studio's JDK so terminal and IDE share one Gradle daemon
    [[ -n "$JBR" ]] && echo "export JAVA_HOME=\"$JBR\""
    echo "$MARK_END"
} >> "$RC"
echo "Updated $RC (PATH${SDK:+, ANDROID_HOME}${JBR:+, JAVA_HOME})"
[[ -z "$SDK" ]] && echo "Warning: Android SDK not found (expected ~/Android/Sdk). Open Android Studio once to install it."

# --- 3. Optional: restricted networks --------------------------------------------
if (( IRAN )); then
    mkdir -p "$(dirname "$INIT_SCRIPT")"
    install -m 644 "$HERE/extras/iran-mirrors.gradle" "$INIT_SCRIPT"
    echo "Installed Gradle mirrors: $INIT_SCRIPT"

    touch "$GRADLE_PROPS"
    remove_block "$GRADLE_PROPS"
    cat >> "$GRADLE_PROPS" <<PROPS
$MARK_BEGIN
# Unstable connections: retry more and wait longer
systemProp.org.gradle.internal.repository.max.retries=10
systemProp.org.gradle.internal.repository.initial.backoff=2000
systemProp.org.gradle.internal.http.connectionTimeout=120000
systemProp.org.gradle.internal.http.socketTimeout=120000
$MARK_END
PROPS
    echo "Updated $GRADLE_PROPS (download retries and timeouts)"

    for old in "$GRADLE_HOME_DIR"/init.d/*.gradle; do
        [[ -f "$old" && "$old" != "$INIT_SCRIPT" ]] || continue
        grep -q 'beforeSettings' "$old" && continue   # settings-level mirrors are fine
        if grep -q 'allprojects' "$old" && grep -qi 'maven' "$old"; then
            echo "Note: $old also adds repositories and may conflict with new projects."
            echo "      If Gradle sync fails, rename it:  mv '$old' '$old.bak'"
        fi
    done
    pkill -f GradleDaemon 2>/dev/null || true
fi

echo
echo "Done! Open a NEW terminal (or run: source ~/.bashrc), then:"
echo "    android-create doctor"
echo "    android-create MyApp com.yourname.myapp"
