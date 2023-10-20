# frozen_string_literal: true

require 'sinatra'
require 'sinatra/reloader'
require 'json'
require 'rack'
require_relative 'memo'
require 'pg'

# データベース接続情報を設定
db_params = {
  host: 'localhost',      # ホスト名
  port: 5432,             # ポート番号
  dbname: 'memo_db',      # データベース名
  user: 'yoshinori', # データベースユーザー名
  password: 'hoehoe' # パスワード
}

# データベースから読み込み。JSON形式へ
def fetch_db(db_params)
  memos = []

  begin
    # データベースに接続
    connection = PG.connect(db_params)
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

memos_data = fetch_db(db_params)
# JSONからMemoクラスオブジェクトへ
memos = memos_data.map { |data| Memo.new(data['id'], data['subject'], data['content']) } if !memos_data.empty?

# HTMLエスケープ用
helpers do
  def h(text)
    Rack::Utils.escape_html(text)
  end

  def hattr(text)
    Rack::Utils.escape_path(text)
  end
end

get '/style.css' do
  content_type 'text/css'
end

get '/' do
  redirect '/memos'
end

get '/memos' do
  @memos = memos
  @title = 'メモアプリ'
  erb :index
end

get '/memos/new' do
  erb :new
end

post '/memos' do
  @title = '新規作成'
  new_memo = Memo.new(nil, params['subject'], params['content'])
  Memo.save_memos(memos, new_memo)
  redirect '/'
end

get '/memos/:memo_id' do
  @memo_id = p params[:memo_id].to_i
  memo = memos.find { |memo_block| memo_block.id.to_i == @memo_id }
  @subject = memo.subject
  @content = memo.content
  @title = @subject

  erb :show
end

get '/memos/:memo_id/edit' do
  @title = '編集'
  @memo_id = params[:memo_id].to_i
  memo = memos.find { |memo_block| memo_block.id.to_i == @memo_id }
  @subject = memo.subject
  @content = memo.content
  erb :edit
end

patch '/memos/:memo_id' do
  memo_id = params[:memo_id].to_i
  target_memo = memos.find { |memo| memo.id.to_i == memo_id }
  target_memo.subject = params['subject']
  target_memo.content = params['content']
  Memo.save_memos(memos, target_memo)
  redirect "/memos/#{target_memo.id}"
end

delete '/memos/:memo_id' do
  @memo_id = params[:memo_id].to_i
  memos.delete_if { |memo| memo.id.to_i == @memo_id }
  Memo.persist_memos(memos)
  redirect '/'
end
