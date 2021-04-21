# this was an attempt at routing OPTIONS requests
# controllers/web_hits_controller.rb
  class WebHitsController < ApplicationController
    def create
      if access_allowed?
        set_access_control_headers
        head :created
      else
        head :forbidden
      end
    end

    def options
      if access_allowed?
        set_access_control_headers
        head :ok
      else
        head :forbidden
      end
    end

    private
    def set_access_control_headers
      headers['Access-Control-Allow-Origin'] = request.env['HTTP_ORIGIN']
      headers['Access-Control-Allow-Methods'] = 'POST, GET, OPTIONS'
      headers['Access-Control-Max-Age'] = '1000'
      headers['Access-Control-Allow-Headers'] = '*,x-requested-with'
    end


    def access_allowed?
      allowed_sites = [request.env['HTTP_ORIGIN']] #you might query the DB or something, this is just an example
      return allowed_sites.include?(request.env['HTTP_ORIGIN'])
    end
  end
