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

# bundle exec ruby app.rb
