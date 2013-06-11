require 'httparty'
class ApplicationController < ActionController::Base
  include Weather
  include GoogleSuggest
  
  protect_from_forgery
  
  before_filter :detect_city
  
  def index
  end
  
  def category
    name = params[:name]    
    @category = Category.where(is_top: 1, name: name.capitalize).first
    if @category.blank?
      redirect_to root_url
      return
    end
  end
  
  def weather
    city = params[:city] || @city
    respond_to do |format|
      format.json do 
        render json: query_weather("#{city} Australia")
      end
    end
  end
  
  def favorite
    #TODO: track the favorite clicks
    render :nothing => true, :status => 200, :content_type => 'text/html'
  end
  
  def search_suggest
    respond_to do |format|
      format.json do 
        render json: google_suggests(params[:word])
      end
    end
  end
  
  def user_location # fuck!!! cannot use location as action method
    self.cookie_city = params[:city]
    redirect_to "/"
  end
  
  def url
    id = params[:id].split(/-/)
    link_id = id.first
    cat_id = id.last
    link = Link.find(link_id)
    if link.present?
      #TODO: track link clicks here
      redirect_to link.url
    else
      redirect_to root_url, alert: "Link not found."
    end
  end
  
  def urls
    category_id = params[:category_id]
    if category_id == "0"
      links = Link.top_categories_links
    else
      links = Link.descendant_links(category_id)
    end
    respond_to do |format|
      format.json do 
        render json: links.inject({}) {|m, l| m[l.id] = l.url; m }
      end
    end
  end
  
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
    cookies[:city] and cookies[:city].gsub('-', ' ')
  end
  
  def cookie_city=(city)
    cookies[:city] = city and city.gsub(' ', '-')
  end
end
