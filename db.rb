# frozen_string_literal: true

require 'pg'

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
  memos
end
