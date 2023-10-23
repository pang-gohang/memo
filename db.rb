# frozen_string_literal: true

require 'pg'
require_relative 'memo'

# データベース接続情報を設定
DB_PARAMS = {
  host: 'localhost',      # ホスト名
  port: 5432,             # ポート番号
  dbname: 'memo_db',      # データベース名
  user: 'yoshinori', # データベースユーザー名
  password: 'hoehoe' # パスワード
}

# データベースから読み込み。JSON形式へ
def fetch_db
  memos = []

  begin
    # データベースに接続
    connection = PG.connect(DB_PARAMS)
    # テーブルからデータを取得
    result = connection.exec('SELECT * FROM memos')
    # 取得したデータをmemosに格納
    result.each do |row|
      memos << {
        'id' => row['id'],
        'subject' => row['subject'],
        'content' => row['content']
      }
    end
  rescue PG::Error => e
    puts "データベースエラー: #{e.message}"
  ensure
    connection.close if connection
  end
  # JSONからMemoクラスオブジェクトへ
  memos.map { |data| Memo.new(data['id'], data['subject'], data['content']) } if !memos.empty?
end

def add_memo(new_memo)
  begin
    # データベースに接続
    conn = PG.connect(DB_PARAMS)

    # 新しいメモをデータベースに挿入
    conn.exec_params('INSERT INTO memos (subject, content) VALUES ($1, $2)', [new_memo.subject, new_memo.content])

    puts '新しいメモをデータベースに挿入しました'
  rescue PG::Error => e
    puts "データベースエラー: #{e.message}"
  ensure
    conn.close if conn
  end
end

def delete_memo(memo_id)
  conn = PG.connect(DB_PARAMS)
  conn.exec_params('DELETE FROM memos WHERE id = $1', [memo_id])
end
