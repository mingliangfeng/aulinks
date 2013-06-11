# encoding: utf-8
require 'httparty'
require "uri"
module Weather
  YAHOO_LATLONG_SEARCH_URL = 'http://where.yahooapis.com/v1/places'
  YAHOO_WEATHER_API_URL = 'http://weather.yahooapis.com/forecastrss'
  APP_ID = 'aVexkdnV34G6JUeGXh7SCjUIsf3llnsv1Z9..dm2RUo_Ci3dFI5Ecj.Wq0tlsoIhiWi5kzgoC4gg24jScS1rg.dXusNOTmo-'
  
  def geo(address)
    response = HTTParty.get URI.escape("#{YAHOO_LATLONG_SEARCH_URL}.q('#{address}')"), :query => {'appid' => APP_ID}, :headers => {'Content-type' => 'text/xml'}
    data = response.parsed_response
    data['places'] and data['places']['place'] and data['places']['place']['woeid']
  end
  
  def query_weather(address)
    woeid = geo(address)
    yahoo_weather(woeid)
  end
  
  def yahoo_weather(woeid)
    return {success: 0} unless woeid.present?
    
    response = HTTParty.get YAHOO_WEATHER_API_URL, :query => {'u' => 'c', 'w' => woeid}
    data = response.parsed_response
    return {success: 0} if data["rss"]["channel"]["title"] == "Yahoo! Weather - Error"
    
    atmosphere = data["rss"]["channel"]["atmosphere"]
    wind = data["rss"]["channel"]["wind"]
    condition = data["rss"]["channel"]["item"]["condition"]
    forecasts = data["rss"]["channel"]["item"]["forecast"]
    link = data["rss"]["channel"]["item"]["link"]
    
    return {
      success: 1,
      'weather' => "#{condition['temp']}° #{condition['text'].gsub('/', ' / ')}, Wind: #{human_direction(wind['direction'])} #{wind['speed']} km/h, Humidity: #{atmosphere['humidity']}%",
      'forecasts' => build_forecasts(forecasts, link)
    }
  end
  
  def human_direction(dir)
     d = dir.to_i
     return 'N at' if d == 0 or d == 360
     return 'NE at' if d > 0 and d < 90
     return 'E at' if d == 90
     return 'SE at' if d > 90 and d < 180
     return 'S at' if d == 180
     return 'SW at' if d > 180 and d < 270
     return 'W at' if d == 270
     return 'NW at' if d > 270 and d < 360
     return ''
  end
  
  def build_forecasts(forecasts, link)
    forecast_strs = []
    forecasts.each do |forecast|
      day_of_week = forecast['day']
      low = forecast['low']
      high = forecast['high']
      icon = "http://l.yimg.com/a/i/us/we/52/#{forecast['code']}.gif"
      condition = forecast['text']
      forecast_strs << "<div><img src='#{icon}' /> <span>#{day_of_week}</span> #{low}° - <span>#{high}°</span> #{condition}</div>"      
    end
    forecast_strs << "<div id='weather-more'><a target='_blank' href='#{link}'>Full Forecast at Yahoo! Weather</a></div>"
    forecast_strs.join
  end
  
end