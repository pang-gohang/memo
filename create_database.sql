-- データベースの作成
CREATE DATABASE memo_db;

-- memo_db データベースを使用
\c memo_db;

-- テーブルの作成
CREATE TABLE memos (
  id SERIAL PRIMARY KEY,
  subject VARCHAR(255) NOT NULL,
  content TEXT
);