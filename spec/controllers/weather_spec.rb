require "spec_helper"

class WeatherHost
  include Weather

end

describe Weather do
  
  let(:obj) { WeatherHost.new }
  
  it "geo" do
    data = obj.geo("Mulgrave VIC Australia")
    data.should_not be_nil
    
    data = obj.geo("some_place_does_not_exist_on_earth")
    data.should be_nil
  end
  
  it "weather" do
    weather = obj.yahoo_weather("127074920000")
    weather[:success].should eql(0)
  end
  
  it "query_weather" do
    weather = obj.query_weather("Mulgrave VIC Australia")
    weather[:success].should eql(1)
  end
  
end
