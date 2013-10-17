require 'erb'
require_relative 'params'
require_relative 'session'
require 'active_support/core_ext'

class ControllerBase
  attr_reader :params

  def initialize(req, res, route_params={})
    @request = req
    @response = res
    @route_params = route_params
  end

  def session
    @session ||= Session.new(@request)
  end

  def already_rendered?
  end

  def redirect_to(url)
    @already_built_response ||= false
    unless @already_built_response
      @response.status = 302
      @response['location'] = url
      @already_built_response = true
      @session.store_session(@response)
    end
  end

  def render_content(content, type)
    @already_built_response ||= false
    unless @already_built_response
      @response.content_type = type
      @response.body = content
      @already_built_response = true
      @session.store_session(@response)
    end
  end

  def render(template_name)
    controller_name = self.class.to_s.underscore
    f = File.read("views/#{controller_name}/#{template_name}.html.erb")
    template = ERB.new(f)
    t = template.result(binding)
    render_content(t, "text/html")
  end

  def invoke_action(name)
  end
end
