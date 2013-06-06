require 'spec_helper'

describe LinksFile do
  
  let(:normal_url) { "http://www.google.com.au" }
  let(:abstract_url) { "www.google.com.au" }
  let(:ending_url) { "http://www.google.com.au/" }
  
  it "abstract_url and format_url" do
    links_file = LinksFile.new
    "google.com.au".should eql(links_file.send(:abstract_url, normal_url))
    
    "http://www.google.com.au".should eql(links_file.send(:format_url, abstract_url))
    "http://www.google.com.au".should eql(links_file.send(:format_url, ending_url))
  end
end
