class FrontController < ApplicationController
  include Weather
  include GoogleSuggest
  
  caches_page :index
  caches_page :category
  
  def index
  end
  
  def category
    name = params[:name]    
    @category = Category.where(is_top: 1, name: Category.decode_name(name)).first
    if @category.blank?
      redirect_to root_url
      return
    end
  end
  
  def weather
    city = params[:city] || @city
    respond_to do |format|
      format.json do 
        render json: {'city' => city}.merge(query_weather("#{city} Australia"))
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
    links = Rails.cache.fetch("links-#{category_id}") do
      if category_id == "0"
        ls = Link.top_categories_links
      else
        ls = Link.descendant_links(category_id)
      end
      ls.inject({}) {|m, l| m[l.id] = l.url; m }
    end
    respond_to do |format|
      format.json do 
        render json: links
      end
    end
  end
  
end
