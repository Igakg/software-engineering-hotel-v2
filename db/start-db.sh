#!/bin/bash
# HSQLDBサーバを起動する（起動したまま別ターミナルでアプリを動かす）。
# 接続先は jdbc:hsqldb:hsql://localhost（別名は空文字）に一致させている。
cd "$(dirname "$0")/.."
exec java -cp lib/hsqldb.jar org.hsqldb.Server \
  -database.0 file:db/hoteldb -dbname.0 ""
