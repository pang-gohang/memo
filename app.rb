# frozen_string_literal: true

require 'sinatra'
require 'sinatra/reloader'
require 'json'
require 'rack'
require_relative 'memo'

memos = []

memos_data = JSON.parse(File.read('data/memos.json'))
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
  @memo_id = params[:memo_id].to_i
  memo = memos.find { |memo_block| memo_block.id == @memo_id }
  @subject = memo.subject
  @content = memo.content
  @title = @subject

  erb :show
end

get '/memos/:memo_id/edit' do
  @title = '編集'
  @memo_id = params[:memo_id].to_i
  memo = memos.find { |memo_block| memo_block.id == @memo_id }
  @subject = memo.subject
  @content = memo.content
  erb :edit
end

patch '/memos/:memo_id' do
  memo_id = params[:memo_id].to_i
  target_memo = memos.find { |memo| memo.id == memo_id }
  target_memo.subject = params['subject']
  target_memo.content = params['content']
  Memo.save_memos(memos, target_memo)
  redirect "/memos/#{target_memo.id}"
end

delete '/memos/:memo_id' do
  @memo_id = params[:memo_id].to_i
  memos.delete_if { |memo| memo.id == @memo_id }
  Memo.persist_memos(memos)
  redirect '/'
end
