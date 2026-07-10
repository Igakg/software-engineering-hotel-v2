#!/usr/bin/env bash
# 全PlantUMLソースを docs/diagrams/ にPNGとして再生成する。
# 使い方: cd docs/puml && ./build.sh [対象.puml ...]（引数なしなら全図）
# 前提: Java 17+、plantuml.jar（下記PATHに配置。Graphvizは不要＝smetana使用）
set -euo pipefail
cd "$(dirname "$0")"

PLANTUML_JAR="${PLANTUML_JAR:-$HOME/.local/share/plantuml/plantuml.jar}"
if [ ! -f "$PLANTUML_JAR" ]; then
  echo "plantuml.jar が見つかりません: $PLANTUML_JAR" >&2
  echo "https://github.com/plantuml/plantuml/releases から取得し、環境変数 PLANTUML_JAR で指定してください。" >&2
  exit 1
fi

targets=("$@")
if [ ${#targets[@]} -eq 0 ]; then
  targets=([0-9]*.puml)
fi

java -Djava.awt.headless=true -jar "$PLANTUML_JAR" \
  -charset UTF-8 -Playout=smetana -tpng -o ../diagrams "${targets[@]}"
echo "生成完了: ${#targets[@]} ファイル -> ../diagrams/"
