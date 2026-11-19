#!/bin/zsh
# Fabrique assets/mPASTE.icns à partir de make_icon.swift.
set -euo pipefail
cd "$(dirname "$0")"
swiftc -o /tmp/mpaste_icon make_icon.swift && /tmp/mpaste_icon mPASTE_1024.png
rm -rf mPASTE.iconset && mkdir mPASTE.iconset
for sz in 16 32 128 256 512; do
  sips -z $sz $sz mPASTE_1024.png --out mPASTE.iconset/icon_${sz}x${sz}.png >/dev/null
  sips -z $((sz*2)) $((sz*2)) mPASTE_1024.png --out mPASTE.iconset/icon_${sz}x${sz}@2x.png >/dev/null
done
iconutil -c icns mPASTE.iconset -o mPASTE.icns && rm -rf mPASTE.iconset
