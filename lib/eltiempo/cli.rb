require 'eltiempo/parser'

module Eltiempo
  class CLI
    OUTPUT_RESPONSE = "The %{action} temperature in %{city} is %{temperature}°C"
    ALLOWED_ACTIONS_WITH_TEXT = {
      '-today': "average of today's",
      '-av_min': 'average minimum',
      '-av_max': 'average maximum'
    }

    def initialize(action, city)
      action_sym = action.to_sym
      allowed_actions_with_text_keys = ALLOWED_ACTIONS_WITH_TEXT.keys
      raise UnknownActionError, "this action is not available. Please use from these options: #{allowed_actions_with_text_keys.join(', ')}" unless allowed_actions_with_text_keys.include?(action_sym)
      raise CityNotProvidedError, 'city not provided' unless city
      @city = city
      configure_parser
      # TODO: Try to find alternative way for send method
      puts format(OUTPUT_RESPONSE, action: ALLOWED_ACTIONS_WITH_TEXT[action_sym], city: @city, temperature: self.send(action.sub('-', '')))
    end

    def today
      @parser.today_forecast
    end

    def av_min
      @parser.avg_min_forecast
    end

    def av_max
      @parser.avg_max_forecast
    end

    private
    def configure_parser
      @parser = Parser.new(@city)
    end
  end
end
