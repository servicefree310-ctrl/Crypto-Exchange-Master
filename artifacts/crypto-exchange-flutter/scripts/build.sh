#!/usr/bin/env bash
set -e
cd "$(dirname "$0")/.."
BASE="${BASE_PATH:-/flutter/}"
flutter build web --release --base-href "$BASE"
