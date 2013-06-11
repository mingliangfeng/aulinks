# encoding: utf-8
module GoogleSuggest
  GOOGLE_SUGGEST_API_URL = 'http://suggestqueries.google.com/complete/search'
  
  def google_suggests(word)
    result = HTTParty.get(GOOGLE_SUGGEST_API_URL, :query => {'jsonp' => 'aulinks', 'hl' => 'en', 'output' => 'toolbar', 'q' => word})
    return [] unless result and result["toplevel"] and result["toplevel"]["CompleteSuggestion"]
    
    result["toplevel"]["CompleteSuggestion"].map {|suggest| suggest["suggestion"]["data"] }
  end
  
end