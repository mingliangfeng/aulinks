class LinkRelation < ActiveRecord::Base
  attr_accessible :parent_id, :show_order, :sub_id
  
  belongs_to :parent, class_name: "Link"
  belongs_to :sub, class_name: "Link"
end
