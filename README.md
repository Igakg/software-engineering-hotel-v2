# ホテル予約システム（HRS）v2 — Loop1（最小要件）／Loop2（保守）

Waseda-SE 提供の Java ベース（Form → Control → Manager → Dao → SqlDao ＋ Factory、HSQLDB 永続化）を土台に、**最小要件を完成させた Loop1** と、そこへ保守として機能拡張を設計した **Loop2** の、分析・設計ドキュメントと実装。

本課題は「最小要件を作る」→「保守で拡張する」の**2ループ**で構成する。

- **Loop1（最小要件）**：予約・チェックイン・チェックアウトを完成。→ [Loop1 で実装した範囲](#loop1-で実装した範囲)
- **Loop2（保守）**：複数人数・会員登録・会員ランク割引・予約キャンセルを追加。各図は Loop1 からの**差分**として提示。→ [Loop2（保守）で追加した範囲](#loop2保守で追加した範囲)

- 分析・設計（Loop1）: [01_ドメイン分析.md](01_ドメイン分析.md) / [02_要求分析.md](02_要求分析.md) / [03_システム分析.md](03_システム分析.md) / [04_アーキテクチャ設計.md](04_アーキテクチャ設計.md)
- 保守（Loop2 差分）: [05_保守_Loop2差分.md](05_保守_Loop2差分.md)
- 図（PlantUML）: ソース [puml/](puml/)、PNG [diagrams/](diagrams/)。Loop2 の図は `L2-` プレフィックス（**オレンジ＝Loop2で追加した要素**）。再生成は `cd puml && ./build.sh`

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

## Loop2（保守）で追加した範囲

Loop1 の設計・実装を**壊さずに**（サブクラス・新規クラス・カラム追加・オーバーロードのみで）、保守として次の4機能を追加する。分析・設計（Step1〜4）は完了し各図に反映済み。**Java 実装（Step5）は現在準備中**（本 README の実行手順は Loop1 の範囲）。

### 追加した機能

| # | 機能 | 概要 |
| --- | --- | --- |
| ① | 複数人数 | 予約が人数を持ち、部屋の**定員**以下で割当。料金に人数を反映（8000円 × 人数） |
| ② | 会員登録（UC4・新設） | 会員番号を発行し、氏名・ランクを登録 |
| ③ | 会員ランク割引 | ランク（一般/シルバー/ゴールド＝0/0.05/0.10）に応じチェックアウトで割引 |
| ④ | 予約キャンセル（UC5・新設） | 未利用の予約をハード削除し、空室数を +1 で戻す（DeleteReservation） |

- 宿泊日数は **1泊固定のまま**。部屋種別・グレードによる料金差は**扱わない**（割引は会員ランクのみ）。
- 料金式：**宿泊料 ＝ 8000円 × 人数 ×（1 − ランク.割引率）**（例：シルバー2名＝16000×(1−0.05)＝15,200円）

### Loop1 からの主な変更点

| 観点 | Loop1 | Loop2 |
| --- | --- | --- |
| ユースケース | UC1予約・UC2チェックイン・UC3チェックアウト（3件） | ＋ UC4会員登録・UC5予約キャンセル（5件） |
| 人数 | 1名固定 | 予約に人数、部屋に定員（人数 ≤ 定員で割当） |
| 料金 | 一律 8000円／泊 | 8000×人数×(1−割引率) |
| 会員 | なし | 会員資格・会員ランクを導入、割引を適用 |
| キャンセル | なし | 未利用予約を削除し空室数を戻す |
| 部屋:料金 の多重度 | 1 : 1 | 1 : *（人数・会員により料金が変わりうる） |

### 追加したクラス／パッケージ

Loop1 と**同じ DAO＋Factory パターン**で追加（一方向依存 ui→app→domain は維持）。

| レイヤ | 追加クラス（パッケージ） |
| --- | --- |
| 境界・制御 | `RegisterMembershipForm`/`RegisterMembershipControl`（app.membership）、`DeleteReservationForm`/`DeleteReservationControl`（app.cancel） |
| ドメイン | `MembershipManager`・`MembershipDao`・`MembershipSqlDao`・`Membership`・`MemberRank`（domain.membership） |
| Factory 拡張 | `ManagerFactory.getMembershipManager()`、`DaoFactory.getMembershipDao()` |
| 既存クラスへの追加 | `Reservation`（人数・会員番号）、`Room`（定員）、`Payment`（会員番号）、`ReservationDao.deleteReservation()`、`ReservationManager.cancelReservation()`、`RoomManager.assignCustomer(date, 人数)`、`PaymentManager.createPayment(…, 人数, 会員番号)`、`PaymentManager ..> MembershipManager`（割引率照会） |

## 状態の用語とコード表現の対応

分析・設計ドキュメントの日本語用語と、実装（DB格納値）の対応。

### Loop1

| 概念 | 用語 | コード上の表現（DB格納値） |
| --- | --- | --- |
| 予約.状態 | 未利用 | `status = "create"`（予約作成後〜チェックイン前） |
| 予約.状態 | 利用済 | `status = "consume"`（チェックイン後） |
| 部屋.在室状況 | 不在 | `ROOM.stayingdate = ''`（客がいない＝割当可能） |
| 部屋.在室状況 | 在室 | `ROOM.stayingdate = 宿泊日`（客が在室中） |
| 料金.状態 | 未精算 | `status = "create"` |
| 料金.状態 | 精算済 | `status = "consume"` |

### Loop2（追加分・実装予定）

| 概念 | 用語 | コード上の表現（DB格納値） |
| --- | --- | --- |
| 予約.人数 | 宿泊人数 | `RESERVATION.numberofguests`（int、1以上・部屋の定員以下） |
| 予約.会員番号 | 会員番号（任意） | `RESERVATION.membernumber`（会員のとき会員番号、非会員は空） |
| 部屋.定員 | 定員 | `ROOM.capacity`（int、割当可否の判定に使用） |
| 料金.会員番号 | 会員番号 | `PAYMENT.membernumber`（精算時の割引率照会に使用） |
| 会員ランク | 一般 | `MEMBERSHIP.rank = "一般"`（割引率 0.00） |
| 会員ランク | シルバー | `MEMBERSHIP.rank = "シルバー"`（割引率 0.05） |
| 会員ランク | ゴールド | `MEMBERSHIP.rank = "ゴールド"`（割引率 0.10） |

## 補足

- Loop1 のスコープ：全室一律 8000 円／泊・1泊固定・1名・会員なし。
- Loop2 のスコープ：複数人数・会員登録・会員ランク割引・予約キャンセル（DeleteReservation）を追加。1泊固定・部屋グレードなしは維持。
