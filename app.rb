require 'sinatra'
require 'sinatra/reloader'
require 'json'

# JSONファイルの読み込み
memos = JSON.parse(File.read('data/memos.json'))

get '/' do
  @memos = memos
  erb :index
end

get '/new' do
  erb :new
end

post '/new' do
  # フォームから送信されたデータを取得
  subject = params['subject']
  content = params['content']
  edit_memo(subject, content, nil, memos)
  redirect '/'
end

get '/:memo_id' do
  @memo_id = params[:memo_id].to_i
  @memos = memos
  erb :show
end

get '/:memo_id/edit' do
  @memo_id = params[:memo_id].to_i
  erb :edit
end

get '/:memo_id/delete' do
  @memo_id = params[:memo_id].to_i
  erb :delete
end

def edit_memo(subject, content, memo_id, memos)
  # 新しいデータを作成
  new_memo = {
    "id": memo_id.nil? ? memos.length + 1 : memo_id,
    "subject": subject,
    "content": content
  }
  # 新しいデータを既存のデータに追加
  memos << new_memo.transform_keys(&:to_s)
  # 更新後のデータをJSON形式にシリアライズしてファイルに保存
  File.open('data/memos.json', 'w') do |file|
    file.write(JSON.pretty_generate(memos))
  end
end

# bundle exec ruby app.rb
