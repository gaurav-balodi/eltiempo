module Eltiempo
  class Configuration
    attr_accessor :affiliate_id, :api_lang

    def initialize
      @affiliate_id = nil
      @api_lang = nil
    end
  end
end
