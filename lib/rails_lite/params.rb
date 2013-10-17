require 'uri'

class Params
  def initialize(req, route_params)
    @params = {}
    req.query_string

  end

  def [](key)
  end

  def to_s
  end

  #private
  def self.parse_www_encoded_form(www_encoded_form)
    url_arr = URI::decode_www_form(www_encoded_form)
    return nil if url_arr.nil?
    url_arr.each do |param_pair|
      @params[param_pair[0]] = param_pair[1]
    end
    @params
  end

  def parse_key(key)
  end
end
