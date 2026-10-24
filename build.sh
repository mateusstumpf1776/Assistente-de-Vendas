#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")"
: "${ANDROID_SDK_ROOT:?Configure ANDROID_SDK_ROOT}"
tools="$ANDROID_SDK_ROOT/build-tools/35.0.0"
platform="$ANDROID_SDK_ROOT/platforms/android-35/android.jar"
mkdir -p build/classes build/dex
"$tools/aapt" package -f -M AndroidManifest.xml -S res -A assets -I "$platform" -F build/unsigned.apk
javac -source 8 -target 8 -bootclasspath "$platform:$tools/core-lambda-stubs.jar" -d build/classes src/br/com/essencia/controle/MainActivity.java
"$tools/d8" --lib "$platform" --min-api 26 --output build/dex build/classes/br/com/essencia/controle/*.class
(cd build/dex && zip -q ../unsigned.apk classes.dex)
"$tools/zipalign" -p -f 4 build/unsigned.apk build/aligned.apk
"$tools/apksigner" sign --ks signing/essencia.jks --ks-pass file:signing/password.txt --ks-key-alias essencia --out build/Essencia-Controle.apk build/aligned.apk
"$tools/apksigner" verify --verbose build/Essencia-Controle.apk
