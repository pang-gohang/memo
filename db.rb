# frozen_string_literal: true

require 'pg'
require_relative 'memo'

# データベース接続情報を設定
DB_PARAMS = {
  host: 'localhost',      # ホスト名
  port: 5432,             # ポート番号
  dbname: 'memo_db',      # データベース名
  user: 'your_name', # データベースユーザー名
  password: 'your_password' # パスワード
}.freeze

def close_connection(connection)
  connection&.close
end

def prepare_statements(connection)
  connection.prepare('insert_memo', 'INSERT INTO memos (subject, content) VALUES ($1, $2)')
  connection.prepare('delete_memo', 'DELETE FROM memos WHERE id = $1')
  connection.prepare('update_memo', 'UPDATE memos SET subject = $1, content = $2 WHERE id = $3')
end

# データベースから読み込み。JSON形式へ
def fetch_db
  memos = []

  connection = PG.connect(DB_PARAMS)
  begin
    result = connection.exec('SELECT * FROM memos')
    result.each do |row|
      memos << {
        'id' => row['id'],
        'subject' => row['subject'],
        'content' => row['content']
      }
    end
  ensure
    close_connection(connection)
  end
  memos.map { |data| Memo.new(data['id'], data['subject'], data['content']) } if !memos.empty?
end

def add_memo(new_memo)
  connection = PG.connect(DB_PARAMS)
  begin
    prepare_statements(connection)
    connection.exec_prepared('insert_memo', [new_memo.subject, new_memo.content])
  ensure
    close_connection(connection)
  end
end

def delete_memo(memo_id)
  connection = PG.connect(DB_PARAMS)
  begin
    prepare_statements(connection)
    connection.exec_prepared('delete_memo', [memo_id])
  ensure
    close_connection(connection)
  end
end

def save_memos(target_memo)
  connection = PG.connect(DB_PARAMS)
  begin
    prepare_statements(connection)
    connection.exec_prepared('update_memo', [target_memo.subject, target_memo.content, target_memo.id])
  ensure
    close_connection(connection)
  end
end