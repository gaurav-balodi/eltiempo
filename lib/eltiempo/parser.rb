require 'json'
require 'net/http'
require 'rexml/document'

module Eltiempo
  class Parser
    include REXML

    TEMPERATURE_KEYS = {
      en: {
        min: 'Minimum Temperature',
        max: 'Maximum Temperature'
      },
      es: {
        min: 'Temperatura Mínima',
        max: 'Temperatura Máxima'
      }
    }

    TIEMPO_API_URL = "http://api.tiempo.com/index.php?api_lang=%{api_lang}&localidad=%{localidad}&affiliate_id=%{affiliate_id}"

    TIEMPO_CITY_URL = "https://api.tiempo.com/peticionBuscador.php?lang=%{lang}&texto=%{city}"

    attr_reader :city, :xmldoc, :localidad

    def initialize(city)
      @city = city
      @localidad = fetch_city_localidad
      @xmldoc = fetch_xml_file
    end

    def today_forecast
      min_text, max_text = TEMPERATURE_KEYS[::Eltiempo.configuration.api_lang.to_sym].values
      min_forecast = XPath.first(xmldoc, "//var[./name[contains(text(),'#{min_text}')]]/data/forecast")["value"].to_i
      max_forecast = XPath.first(xmldoc, "//var[./name[contains(text(),'#{max_text}')]]/data/forecast")["value"].to_i
      (min_forecast + max_forecast) / 2
    end

    def avg_min_forecast
      avg_forecast
    end

    def avg_max_forecast
      avg_forecast('max')
    end

    private

    def avg_forecast(action='min')
      value = TEMPERATURE_KEYS[::Eltiempo.configuration.api_lang.to_sym][action.to_sym]
      element = XPath.first(xmldoc, "//var[./name[contains(text(),'#{value}')]]")
      XPath.each(element, "./data/forecast").inject(0){|sum, el| sum + el['value'].to_i } / 7
    end

    def fetch_xml_file
      response = Net::HTTP.get_response(URI(format(TIEMPO_API_URL, api_lang: ::Eltiempo.configuration.api_lang, localidad: localidad, affiliate_id: ::Eltiempo.configuration.affiliate_id)))

      raise FetchXMLFileRequestError, 'fetch XML file request did\'nt finish correctly' unless response.is_a? Net::HTTPSuccess

      Document.new(response.body)
    end

    def fetch_city_localidad
      response = Net::HTTP.get_response(URI(format(TIEMPO_CITY_URL, lang: ::Eltiempo.configuration.api_lang, city: @city)))

      raise FetchCitiesRequestError, 'fetching cities failed' unless response.is_a? Net::HTTPSuccess

      json_parsed_response = JSON.parse(response.body)
      if json_parsed_response['localidad'].size > 0
        json_parsed_response['localidad'][0]['id']
      else
        raise CityNotFoundError, 'city not found'
      end
    end
  end
end
