require 'eltiempo/version'
require 'eltiempo/configuration'

module Eltiempo
  class FetchXMLFileRequestError < StandardError; end
  class UnknownActionError < StandardError; end
  class CityNotProvidedError < StandardError; end
  class CityNotFoundError < StandardError; end
  class FetchCitiesRequestError < StandardError; end

  class << self
    attr_writer :configuration

    def configuration
      @configuration ||= Configuration.new
    end

    def reset
      @configuration = Configuration.new
    end

    def configure
      yield(configuration)
    end
  end
end
