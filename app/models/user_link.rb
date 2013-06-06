class UserLink < ActiveRecord::Base
  attr_accessible :Category, :ip, :is_friend, :location, :url
  
  after_initialize :init

private
  def init
    self.is_friend ||= 0
  end
end
