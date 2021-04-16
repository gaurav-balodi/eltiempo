require 'test_helper'
require 'eltiempo/configuration'
require 'eltiempo/cli'
require 'rexml/document'

describe "Eltiempo configuration" do
  before(:all) do
  	Eltiempo.configure do |config|
	    config.affiliate_id = 'zdo2c683olan'
	    config.api_lang = 'es'
	  end
  end

  it "check configuration affiliate_id as 'zdo2c683olan'" do
    assert_equal ::Eltiempo.configuration.affiliate_id, 'zdo2c683olan'
  end

  it "check configuration api_lang as 'es'(spanish)" do
    assert_equal ::Eltiempo.configuration.api_lang, 'es'
  end

  it "check configuration api_lang set as 'en'(english)" do
    Eltiempo.configuration.api_lang = 'en'
    assert_equal ::Eltiempo.configuration.api_lang, 'en'
  end
end

describe "Eltiempo CLI" do
  before(:all) do
    Eltiempo.configure do |config|
      config.affiliate_id = 'zdo2c683olan'
      config.api_lang = 'es'
    end

    @city = 'Gava'
  end

  it 'raise this action is not available error' do
  	assert_raises Eltiempo::UnknownActionError do
  	  ::Eltiempo::CLI.new('today', @city)
  	end
  end

  it 'raise city not provided error' do
  	assert_raises Eltiempo::CityNotProvidedError do
  	  ::Eltiempo::CLI.new('-today', nil)
  	end
  end

  it 'returns average today temperature' do
	  assert_output(/The average of today's temperature in #{@city} is \d+°C/) { ::Eltiempo::CLI.new('-today', @city) }
  end

  it 'returns average minimum temperature' do
	  assert_output(/The average minimum temperature in #{@city} is \d+°C/) { ::Eltiempo::CLI.new('-av_min', @city) }
  end

  it 'returns average maximum temperature' do
	  assert_output(/The average maximum temperature in #{@city} is \d+°C/) { ::Eltiempo::CLI.new('-av_max', @city) }
  end
end

describe "Eltiempo parser" do
  include REXML
  before :each do
    Eltiempo.configure do |config|
      config.affiliate_id = 'zdo2c683olan'
      config.api_lang = 'es'
    end

    city = 'Gava'
    @parser = Eltiempo::Parser.new(city)
  end

  it "parser setting localidad on initialization" do
    assert @parser.localidad.is_a? Integer
  end

  it "parser setting XML Document on initialization " do
    assert @parser.xmldoc.is_a?(REXML::Document)
  end
end
