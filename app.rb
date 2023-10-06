# frozen_string_literal: true

require 'sinatra'
require 'sinatra/reloader'
require 'json'
require 'rack'

memos = JSON.parse(File.read('data/memos.json'))

# HTMLエスケープ用
helpers do
  def h(text)
    Rack::Utils.escape_html(text)
  end
end

get '/style.css' do
  content_type 'text/css'
end

get '/' do
  @memos = memos
  erb :index
end

get '/new' do
  erb :new
end

post '/new' do
  subject = h(params['subject'])
  content = h(params['content'])
  edit_memo(subject, content, nil, memos)
  redirect '/'
end

get '/:memo_id' do
  @memo_id = params[:memo_id].to_i
  memo = memos.find { |memo_block| memo_block['id'] == @memo_id }
  @subject = h(memo['subject'])
  @content = h(memo['content'])
  erb :show
end

get '/:memo_id/edit' do
  @memo_id = params[:memo_id].to_i
  memo = memos.find { |memo_block| memo_block['id'] == @memo_id }
  @subject = h(memo['subject'])
  @content = h(memo['content'])
  erb :edit
end

patch '/:memo_id' do
  @memo_id = params[:memo_id].to_i
  subject = h(params['subject'])
  content = h(params['content'])
  edit_memo(subject, content, @memo_id, memos)
  redirect "/#{@memo_id}"
end

delete '/:memo_id' do
  @memo_id = params[:memo_id].to_i
  memos.delete_if { |memo| memo['id'] == @memo_id }
  redirect '/'
end

def create_new_memo(subject, content, memos)
  new_memo = {
    "id": memos.map { |memo| memo['id'] }.max + 1,
    "subject": subject,
    "content": content
  }
  memos << new_memo.transform_keys(&:to_s)
end

def edit_existing_memo(subject, content, memo_id, memos)
  memos.each do |memo|
    memo['subject'] = subject if memo['id'] == memo_id
    memo['content'] = content if memo['id'] == memo_id
  end
end

def save_memos_to_file(memos)
  File.open('data/memos.json', 'w') do |file|
    file.write(JSON.pretty_generate(memos.map { |memo| memo.transform_keys(&:to_s) }))
  end
end

def edit_memo(subject, content, memo_id, memos)
  if memo_id.nil?
    create_new_memo(subject, content, memos)
  else
    edit_existing_memo(subject, content, memo_id, memos)
  end
  save_memos_to_file(memos)
end
