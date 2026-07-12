#!/bin/bash
# 本体(src)＋ツール(tools)をコンパイルして bin/ へ出力する
set -e
cd "$(dirname "$0")"
rm -rf bin
mkdir -p bin
javac -encoding UTF-8 -cp lib/hsqldb.jar -d bin $(find src tools -name "*.java")
echo "コンパイル完了: bin/"
