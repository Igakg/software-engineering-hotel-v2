#!/bin/bash
# コンソールUI(CUI)を起動する。事前に db/start-db.sh でHSQLDBサーバ起動 + db/init-db.sh が必要
set -e
cd "$(dirname "$0")"
[ -d bin ] || ./build.sh
java -Dfile.encoding=UTF-8 -cp bin:lib/hsqldb.jar app.cui.CUI
