require 'json'
require 'webrick'

class Session
  def initialize(req)
  	@req = req
  	@current_cookies = req.cookies
  	@current_cookies.each do |cookie|
  		@session = JSON.parse(cookie.value) if cookie.name == "_rails_lite_app"
  	end
  	@session ||= {}
  	puts "session is #{@session}"
  end

  def [](key)
  	puts "count is #{@session[key]}"
  	@session[key]
  end

  def []=(key, val)
  	@session[key] = val
  end

  def store_session(res)
  	new_cookie = WEBrick::Cookie.new("_rails_lite_app", @session.to_json)
  	puts "new cookie is #{new_cookie}"
  	res.cookies << new_cookie
  end
end
