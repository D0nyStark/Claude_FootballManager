#!/usr/bin/env bash
# 아이폰용 웹앱 빌드 → docs/app (GitHub Pages: https://d0nystark.github.io/Claude_FootballManager/app/)
set -euo pipefail
cd "$(dirname "$0")/.."
flutter build web --release --no-web-resources-cdn --web-content-hash \
  --base-href /Claude_FootballManager/app/
out=build/web
# 이 빌드(dart2js + CanvasKit)가 쓰지 않는 렌더러 변형과 디버그 파일은 뺀다.
# Safari: canvaskit/canvaskit.wasm, 크롬 계열: canvaskit/chromium/
rm -rf "$out"/canvaskit/skwasm* "$out"/canvaskit/wimp* "$out"/canvaskit/webparagraph
find "$out" -name '*.symbols' -delete -o -name '*.map' -delete
rm -rf docs/app
cp -r "$out" docs/app
touch docs/.nojekyll
du -sh docs/app
