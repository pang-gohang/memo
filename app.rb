# frozen_string_literal: true

require 'sinatra'
require 'sinatra/reloader'
require 'json'
require 'rack'

# ファイルが存在しない場合の初期データ
initial_data = [
  { "id": 1, "subject": "サンプルメモ1", "content": "これはサンプルメモ1です。" },
  { "id": 2, "subject": "サンプルメモ2", "content": "これはサンプルメモ2です。" }
]

# ファイルが存在しない場合に初期データを書き込む
unless File.exist?('data/memos.json')
  File.open('data/memos.json', 'w') do |file|
    file.write(JSON.pretty_generate(initial_data))
  end
end

memos = JSON.parse(File.read('data/memos.json'))

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
  @memos = memos
  @title = 'メモアプリ'
  erb :index
end

get '/new' do
  erb :new
end

post '/new' do
  @title = '新規作成'
  target_memo = {
  'id' => nil,
  'subject' => params['subject'],
  'content' => params['content']
  }
  save_memos(memos, target_memo)
  redirect '/'
end

get '/memos/:memo_id' do
  @memo_id = params[:memo_id].to_i
  memo = memos.find { |memo_block| memo_block['id'] == @memo_id }
  @subject = memo['subject']
  @content = memo['content']
  @title = @subject

  erb :show
end

get '/memos/:memo_id/edit' do
  @title = '編集'
  @memo_id = params[:memo_id].to_i
  memo = memos.find { |memo_block| memo_block['id'] == @memo_id }
  @subject = memo['subject']
  @content = memo['content']
  erb :edit
end

patch '/memos/:memo_id' do
  target_memo = {
  'id' => params[:memo_id].to_i,
  'subject' => params['subject'],
  'content' => params['content']
  }
  save_memos(memos, target_memo)
  redirect "/memos/#{target_memo['id']}"
end

delete '/memos/:memo_id' do
  @memo_id = params[:memo_id].to_i
  memos.delete_if { |memo| memo['id'] == @memo_id }
  persist_memos(memos)
  redirect '/'
end

def add_new_memo(memos, target_memo)
  target_memo['id'] = memos.map { |memo| memo['id'] }.max + 1
  memos << target_memo.transform_keys(&:to_s)
end

def update_memo(memos, target_memo)
  memos.each do |memo|
    memo['subject'] = target_memo['subject'] if memo['id'] == target_memo['id']
    memo['content'] = target_memo['content'] if memo['id'] == target_memo['id']
  end
end

def persist_memos(memos)
  File.open('data/memos.json', 'w') do |file|
    file.write(JSON.pretty_generate(memos.map { |memo| memo.transform_keys(&:to_s) }))
  end
end

def save_memos(memos, target_memo)
  if target_memo['id'].nil?
    add_new_memo(memos, target_memo)
  else
    update_memo(memos, target_memo)
  end
  persist_memos(memos)
end
