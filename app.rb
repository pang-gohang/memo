require 'sinatra'
require 'sinatra/reloader'
require 'json'

memos = JSON.parse(File.read('data/memos.json'))

get '/' do
  @memos = memos
  erb :index
end

get '/new' do
  erb :new
end

post '/new' do
  subject = params['subject']
  content = params['content']
  edit_memo(subject, content, nil, memos)
  redirect '/'
end

get '/:memo_id' do
  @memo_id = params[:memo_id].to_i
  memo = memos.find { |memo| memo['id'] == @memo_id }
  @subject = memo['subject']
  @content = memo['content']
  erb :show
end

get '/:memo_id/edit' do
  @memo_id = params[:memo_id].to_i
  memo = memos.find { |memo| memo['id'] == @memo_id }
  @subject = memo['subject']
  @content = memo['content']
  erb :edit
end

get '/:memo_id/delete' do
  @memo_id = params[:memo_id].to_i
  erb :delete
end

def edit_memo(subject, content, memo_id, memos)
  # memo_idが空の場合はメモ数からidをとる
  new_memo = {
    "id": memo_id.nil? ? memos.length + 1 : memo_id,
    "subject": subject,
    "content": content
  }
  memos << new_memo.transform_keys(&:to_s)
  File.open('data/memos.json', 'w') do |file|
    file.write(JSON.pretty_generate(memos))
  end
end

# bundle exec ruby app.rb
