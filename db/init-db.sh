#!/bin/bash
# 起動中のHSQLDBサーバに schema.sql（テーブル定義＋部屋シード）を適用する
set -e
cd "$(dirname "$0")/.."
[ -d bin ] || ./build.sh
java -cp bin:lib/hsqldb.jar DbInit db/schema.sql
