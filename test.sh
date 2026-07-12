#!/bin/bash
# 結合テスト（予約→チェックイン→チェックアウト）を実行する。
# 事前に db/start-db.sh でサーバ起動 + db/init-db.sh 済みであること。
set -e
cd "$(dirname "$0")"
[ -d bin ] || ./build.sh
java -Dfile.encoding=UTF-8 -cp bin:lib/hsqldb.jar SmokeTest
