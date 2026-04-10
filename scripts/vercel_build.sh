#!/usr/bin/env bash
# Build Flutter web on Vercel (Linux). Static files are served first; unknown
# paths fall through to index.html via vercel.json rewrites (GetX routes).
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

SDK_DIR="${ROOT}/.flutter-sdk"
if [[ ! -x "${SDK_DIR}/bin/flutter" ]]; then
  echo "Cloning Flutter stable (shallow)..."
  rm -rf "${SDK_DIR}"
  git clone https://github.com/flutter/flutter.git -b stable --depth 1 "${SDK_DIR}"
fi
export PATH="${SDK_DIR}/bin:${PATH}"

flutter config --no-analytics --enable-web
flutter precache --web
flutter pub get
flutter build web --release
