# ホテル予約システム（HRS）v2 — Loop1（最小要件）

Waseda-SE 提供の Java ベース（Form → Control → Manager → Dao → SqlDao ＋ Factory、HSQLDB 永続化）を土台に、最小要件（予約・チェックイン・チェックアウト）を完成させた実装と、その分析・設計ドキュメント。

- 分析・設計: [01_ドメイン分析.md](01_ドメイン分析.md) / [02_要求分析.md](02_要求分析.md) / [03_システム分析.md](03_システム分析.md) / [04_アーキテクチャ設計.md](04_アーキテクチャ設計.md)
- 図（PlantUML）: ソース [puml/](puml/)、PNG [diagrams/](diagrams/)（再生成は `cd puml && ./build.sh`）

## ディレクトリ構成

```
workspace02/
├── src/            実装本体（app / domain / util）※Waseda-SEベース＋checkout実装
├── lib/hsqldb.jar  HSQLDB 1.8.0
├── db/             schema.sql・DB起動/初期化スクリプト
├── tools/          DbInit（スキーマ適用）・SmokeTest（結合テスト）
├── puml/ diagrams/ PlantUMLソースと生成PNG
├── build.sh run.sh test.sh
└── 01〜04_*.md     分析・設計ドキュメント
```

## 実行方法

HSQLDB はサーバ方式（接続先 `jdbc:hsqldb:hsql://localhost`）。ターミナルを2つ使う。

```bash
# ターミナルA: DBサーバを起動したままにする
./db/start-db.sh

# ターミナルB: ビルド → スキーマ＋部屋シード投入 → 実行
./build.sh
./db/init-db.sh        # 初回、またはDBを初期化したいとき
./test.sh              # 結合テスト（予約→チェックイン→チェックアウト）
./run.sh               # コンソールUI（1:予約 2:チェックイン 3:チェックアウト 9:終了）
```

`test.sh`（SmokeTest）が「予約→チェックイン→チェックアウト」を通しで実行し、二重チェックアウトが拒否されることまで確認する。

## Loop1 で実装した範囲

- **チェックアウトの実装**：ベースで空欄だった `CheckOutRoomControl.checkOut()` / `CheckOutRoomForm.checkOut()` を実装（退室＝部屋を在室→不在に戻す ＋ 精算＝料金を未精算→精算済に）。
- **HSQLDB 整備**：`db/schema.sql`（ROOM/RESERVATION/AVAILABLEQTY/PAYMENT ＋ 部屋5室シード）、起動・初期化スクリプト。
- 予約・チェックイン・部屋在庫・支払は Waseda-SE ベースの実装をそのまま利用。

## 状態の用語とコード表現の対応

分析・設計ドキュメントの日本語用語と、実装（DB格納値）の対応。

| 概念 | 用語 | コード上の表現（DB格納値） |
| --- | --- | --- |
| 予約.状態 | 未利用 | `status = "create"`（予約作成後〜チェックイン前） |
| 予約.状態 | 利用済 | `status = "consume"`（チェックイン後） |
| 部屋.在室状況 | 不在 | `ROOM.stayingdate = ''`（客がいない＝割当可能） |
| 部屋.在室状況 | 在室 | `ROOM.stayingdate = 宿泊日`（客が在室中） |
| 料金.状態 | 未精算 | `status = "create"` |
| 料金.状態 | 精算済 | `status = "consume"` |

## 補足

- 最小要件のスコープ：全室一律 8000 円／泊・1泊固定・1名・会員なし。
- Loop2（保守）で 複数人数・会員登録・会員ランク割引・予約キャンセル（DeleteReservation）を追加予定。
