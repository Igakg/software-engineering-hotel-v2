-- HRS 最小要件版 スキーマ＋部屋シード（HSQLDB 1.8.0）
DROP TABLE PAYMENT IF EXISTS;
DROP TABLE AVAILABLEQTY IF EXISTS;
DROP TABLE RESERVATION IF EXISTS;
DROP TABLE ROOM IF EXISTS;

-- 部屋：stayingdate が空文字='不在'、日付入り='在室'
CREATE TABLE ROOM (roomnumber VARCHAR(16), stayingdate VARCHAR(16));
-- 予約：status は create='未利用'、consume='利用済'
CREATE TABLE RESERVATION (reservationnumber VARCHAR(32), stayingdate VARCHAR(16), status VARCHAR(16));
-- 日別空室数
CREATE TABLE AVAILABLEQTY (date VARCHAR(16), qty VARCHAR(16));
-- 料金：status は create='未精算'、consume='精算済'
CREATE TABLE PAYMENT (roomnumber VARCHAR(16), stayingdate VARCHAR(16), amount VARCHAR(16), status VARCHAR(16));

-- 部屋マスタ（全5室、初期は全て「不在」）
INSERT INTO ROOM (roomnumber, stayingdate) VALUES ('101', '');
INSERT INTO ROOM (roomnumber, stayingdate) VALUES ('102', '');
INSERT INTO ROOM (roomnumber, stayingdate) VALUES ('201', '');
INSERT INTO ROOM (roomnumber, stayingdate) VALUES ('202', '');
INSERT INTO ROOM (roomnumber, stayingdate) VALUES ('301', '');
