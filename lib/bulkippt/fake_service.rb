module Bulkippt

  class FakeService

    attr_reader :username, :token, :clips

    def initialize(username, token)
      @username = username
      @token = token
      @clips = Clips.new
    end

    def account
      if credentials_valid?(@username, @token) 
        {username: @username, token: @token}.to_json
      else 
        raise Kippt::APIError, "Can't find an user with this username and api_key"
      end
    end

    def credentials_valid?(username, token)
      return false if username != 'valid' && @token != 'valid'
      true
    end

  end

  class Clips
    def build
      Clip.new
    end
  end

  class Clip < OpenStruct
    def save
      self
    end
  end

end
