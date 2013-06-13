class VkGroupPhotoCounting < Sinatra::Base
  register Sinatra::StaticAssets
  include Oauth
  include VkLikesCounter

  set public_folder: "public", static: true
  set :sessions, true
  set :inline_templates, true
  set :session_secret, "ieGaixa3eeoNg3oogAhP8soo1"

  # set :auth { |value| TODO: check auth


  get "/" do
    erb :welcome
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

  get '/auth/:provider/callback' do
    session['user_id'] = auth_hash
    session['vk'] = VkMain.new(auth_hash[:credentials][:token])

    redirect '/groups'
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
end
