class VkGroupPhotoCounting < Sinatra::Base
  register Sinatra::StaticAssets
  register Sinatra::Twitter::Bootstrap::Assets

  include Oauth
  include VkLikesCounter

  set public_folder: "public", static: true
  set :sessions, true
  set :inline_templates, true
  set :session_secret, "ieGaixa3eeoNg3oogAhP8soo1"
  set :logging, Logger::DEBUG

  get "/", layout: :layout do
    haml :welcome
  end

  get '/auth/:provider/callback' do
    session['user_id'] = auth_hash
    session['vk'] = VkMain.new(auth_hash[:credentials][:token])

    redirect '/groups'
  end

  before '/groups*' do
    check_auth!
  end

  get "/groups" do
    @groups = vk.get_groups

    haml :groups
  end

  get "/groups/:id" do
    @group = vk.find_group(params[:id])
    @group_albums = @group.albums

    haml :show_group
  end

  get "/groups/:id/albums/:album" do
    @group = vk.find_group(params[:id])
    @album = @group.album(params[:album])
    @photos = @album.photos

    haml :show_album
  end

  private

  def auth_hash
    request.env['omniauth.auth']
  end

  def user_id
    session['user_id']
  end

  def vk
    session['vk']
  end

  def check_auth!
    redirect '/' unless vk
  end
end
