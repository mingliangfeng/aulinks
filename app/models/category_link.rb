class CategoryLink < ActiveRecord::Base
  attr_accessible :category_id, :link_id, :recommend, :show_order
  
  after_initialize :init
  
  belongs_to :category
  belongs_to :link

private
  def init
    self.recommend ||= 0
  end
end
