require 'httparty'
class ApplicationController < ActionController::Base  
  protect_from_forgery
  
  before_filter :detect_city
  
private
  def detect_city
    if cookie_city.present?
      @city = cookie_city
    else
      @city = 'Melbourne, VIC'
      self.cookie_city = @city
    end
  end
  
  def cookie_city
    cookies[:city]
  end
  
  def cookie_city=(city)
    cookies[:city] = city
  end
end
