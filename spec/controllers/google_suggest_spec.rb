require "spec_helper"

class GoogleSuggestHost
  include GoogleSuggest

end

describe GoogleSuggest do
  
  let(:obj) { GoogleSuggestHost.new }
  
  it "suggest" do
    data = obj.google_suggests("hose")
    data.length.should eql(10)
  end
  
end