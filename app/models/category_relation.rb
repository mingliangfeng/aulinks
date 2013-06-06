class CategoryRelation < ActiveRecord::Base
  attr_accessible :parent_id, :show_order, :sub_id
  attr_accessible :related # 0: parent-sub; 1: related
  
  after_initialize :init
  
  belongs_to :parent, class_name: "Category"
  belongs_to :sub, class_name: "Category"

private
  def init
    self.related ||= 0
  end
end
