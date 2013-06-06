class Category < ActiveRecord::Base
  HOME_TITLE = 'Australian Websites - Online Directory'
  TOP_CATEGORIES = (1001..1026)
  IMG_CATEGORIES = [10052, 10096]
  CATEGORY_TITLE = {1001 => 'News Australian | Australian News',
                    1002 => 'School Sport Australia | Australian sports',
                    1003 => 'PC World Australia | PC World',
                    1004 => 'Mobile Phones Australia',
                    1005 => 'Australian Job Search | Australian Government Jobs',
                    1006 => 'Insurance Companies | Insurance Online',
                    1007 => 'Smart Traveller | Smart Traveller Australia',
                    1008 => 'Australian Muscle Cars | Aussie Muscle Cars',
                    1009 => 'Australian Online Shopping Websites',
                    1010 => 'Catalogues Online',
                    1011 => 'Real estate Australia | Australian Real estate',
                    1012 => 'Australian Banks',
                    1013 => 'Australian Securities Exchange | Australian Stock Exchange',
                    1014 => 'Australian TV Guide | Video Sites',
                    1015 => 'Funny Games | Free Online Games',
                    1016 => 'Social Networking Sites',
                    1017 => 'Free Blog | Australian Blogs',
                    1018 => 'Dating Websites | Dating Sites Australia',
                    1019 => 'Lifestyle Food | Australian Food | Australian Lifestyle',
                    1020 => 'Womens Weekly Recipes  | Famous Australian Women',
                    1021 => 'Australian Book Review | Books Online Australia',
                    1022 => 'New Movies | Australian Movies',
                    1023 => 'Australian Music | Music Websites',
                    1024 => 'Email Addresses Australia',
                    1025 => 'Australian Education | Schools Website',
                    1026 => 'Australian Government Website | Australian Government'}

  CATEGORY_URL = {1001 => 'http://aulinks.com.au/news',
                  1002 => 'http://aulinks.com.au/sport',
                  1003 => 'http://aulinks.com.au/computer',
                  1004 => 'http://aulinks.com.au/mobile-phone',
                  1005 => 'http://aulinks.com.au/jobs',
                  1006 => 'http://aulinks.com.au/insurance',
                  1007 => 'http://aulinks.com.au/travel',
                  1008 => 'http://aulinks.com.au/cars',
                  1009 => 'http://aulinks.com.au/shopping',
                  1010 => 'http://aulinks.com.au/shop-catalogue',
                  1011 => 'http://aulinks.com.au/housing',
                  1012 => 'http://aulinks.com.au/banking',
                  1013 => 'http://aulinks.com.au/stock',
                  1014 => 'http://aulinks.com.au/video',
                  1015 => 'http://aulinks.com.au/game',
                  1016 => 'http://aulinks.com.au/social-network',
                  1017 => 'http://aulinks.com.au/blog',
                  1018 => 'http://aulinks.com.au/dating',
                  1019 => 'http://aulinks.com.au/life-&-style',
                  1020 => 'http://aulinks.com.au/women',
                  1021 => 'http://aulinks.com.au/book',
                  1022 => 'http://aulinks.com.au/movie',
                  1023 => 'http://aulinks.com.au/music',
                  1024 => 'http://aulinks.com.au/email',
                  1025 => 'http://aulinks.com.au/education',
                  1026 => 'http://aulinks.com.au/government'}
                  
  attr_accessible :hid, :is_top, :name
  
  after_initialize :init
  
  has_many :sub_relations, class_name: "CategoryRelation", foreign_key: :parent_id
  has_many :sub_categories, through: :sub_relations, source: :sub
  
  has_many :parent_relations, class_name: "CategoryRelation", foreign_key: :sub_id
  has_many :parent_categories, through: :parent_relations, source: :parent
  
  has_many :link_relations, class_name: "CategoryLink"
  has_many :links, through: :link_relations
  
  def title
    CATEGORY_TITLE[hid] || HOME_TITLE
  end
  
  def readable_title
    title.gsub('|', 'and').capitalize
  end
  
  def sorted_links
    self.links.order("category_links.show_order asc")
  end
  
  def subordinateli_categories
    self.sub_categories.where("category_relations.related = 0").order("category_relations.show_order asc")
  end
  
  def links_count
    self.links.count {|link| not link.is_sub? }
  end
  
  def related_categories
    self.sub_categories.where("category_relations.related = 1").order("category_relations.show_order asc")
  end
  
  def encode_name
    self.name.gsub(' ', '-').downcase
  end
  
  def encode_url
    "/#{encode_name}"
  end
  
  def desc
    
  end
  
private
  def init
    self.is_top ||= 0
  end
end
