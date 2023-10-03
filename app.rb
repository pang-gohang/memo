require 'sinatra'
require 'sinatra/reloader'
require 'json'

# JSONファイルの読み込み
data = JSON.parse(File.read('data/memos.json'))

get '/' do
  @message = data # Rubyの変数を設定
  erb :index # ERBテンプレートを使用してHTMLを生成
end

get '/new' do
  @message = data # Rubyの変数を設定
  erb :new # ERBテンプレートを使用してHTMLを生成
end

get '/:memo_id' do
  @memo_id = params[:memo_id].to_i
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
