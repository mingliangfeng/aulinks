require "spec_helper"

describe ApplicationController do
  describe "routing" do

    it "routes to /admin" do
      visit "/admin"
      current_path.should == "/admin/login"
    end
    
    it "routes to /banking" do
      expect(get("/banking")).to route_to(controller: "application", action: "category", name: "banking")
      #visit "/banking"
      #current_path.should == "/banking"
    end
    
    it "routes to none existent urls" do
      visit "/none-existing-category"
      current_path.should == "/"
      
      expect(:get => "/none/existing/url").not_to be_routable
    end

  end
end
