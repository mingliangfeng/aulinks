class Link < ActiveRecord::Base
  CITY_DESC = {'SYD' => 'Sydney, New South Wales',
                  'MEL' => 'Melbourne, Victoria',
                  'BNE' => 'Brisbane, Queensland',
                  'PER' => 'Perth, Western Australia',
                  'ADL' => 'Adelaide, South Australia',
                  'CBR' => 'Canberra, Australian Capital Territory',
                  'AU' => 'Australia'}
                  
  attr_accessible :favicon, :info, :name, :title, :url
  
  has_many :sub_relations, class_name: "LinkRelation", foreign_key: :parent_id
  has_many :sub_links, through: :sub_relations, source: :sub
  
  has_many :parent_relations, class_name: "LinkRelation", foreign_key: :sub_id
  has_many :parent_links, through: :parent_relations, source: :parent
  
  has_many :category_relations, class_name: "CategoryLink"
  has_many :categories, through: :category_relations
  
  scope :hot_links, joins(category_relations: :category).includes(category_relations: :category).where("category_links.recommend" => 1).order("category_links.show_order asc")
  
  def city_desc
    CITY_DESC[self.info]
  end
  
  def is_sub?
    self.info == "^"
  end
  
end
