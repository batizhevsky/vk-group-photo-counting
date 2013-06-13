module VkLikesCounter
  class VkMain
    def initialize(token)
      @client = VkontakteApi::Client.new(token)

      self
    end

    def get_groups
      groups = @client.groups.get(extended: 1)
      groups.shift #первое значение - количество
      groups
    end

    def find_group(id)
      VkGroup.new(@client, id)
    end
  end

  class VkGroup
    def initialize(client, id)
      @client = client
      @id = id
      @likes_count = {}

      groups = @client.groups.get(extended: 1)
      groups.shift #первое значение - количество
      groups
    end

    def group
      @client.groups.getById(@id)
    end

    def albums
      @client.photos.getAlbums(gid: @id, need_covers: 1)
    end

    def album(id)
      VkAlbum.new(@client, id, @id)
    end

    def users_ids
      @users_ids ||= count_users_ids
    end

    def users_likes_ids(photo)
     if @likes_count.has_key?(photo)
       @likes_count[photo]
     else
       @likes_count[photo] = get_users_like_count(photo)
     end

    end

    private

    def get_users_like_ids(photo)
      photo = VkPhoto.new(@client, photo)
      likes_ids = photo.like_ids
      likes_ids & users_ids
    end

    def get_users_like_count(photo)
      get_users_like_ids(photo).count
    end

    def count_users_ids
      offset = 0
      step = 1000

      ids = []
      begin
        members = @client.groups.getMembers(gid: @id, count: step, offset: offset)
        ids += Array(members[:users])
        offset += step
        sleep 0.3
      end while members[:count] > ids.length

      ids
    end
  end

  class VkAlbum
    def initialize(client, id, gid)
      @client = client
      @id = id
      @gid = gid
      self
    end

    def info
      @client.photos.getAlbums(gid: @gid).select{ |a| a.aid == @id }
    end

    def title
      info.title
    end

    def thumb_src
      info.thumb_src
    end

    def photos
      @photos ||= @client.photos.get(gid: @gid, aid: @id, extended: 1)
    end

  end

  class VkPhoto
    def initialize(client, photo)
      @client = client
      @photo = photo
    end

    def like_ids
      offset = 0
      step = 1000
      ids = []

      begin
        likes = @client.likes.getList(type: 'photo', item_id: @photo.pid, owner_id: @photo.owner_id, count: step, offset: offset)
        ids += Array(likes[:users])
        offset += step
        sleep 0.3
      end while likes[:count] > ids.length

      ids
    end
  end
end
