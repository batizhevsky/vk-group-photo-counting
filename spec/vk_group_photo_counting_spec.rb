require_relative "spec_helper"
require_relative "../vk_group_photo_counting.rb"

def app
  VkGroupPhotoCounter
end

describe VkGroupPhotoCounter do
  it "responds with a welcome message" do
    get '/'

    last_response.body.must_include 'Welcome to the Sinatra Template!'
  end
end
