
require 'open-uri'

class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  before_action :get_session

  rescue_from ActionView::MissingTemplate do |exception|
    # use exception.path to extract the path information
    # This does not work for partials
  end

  #meanwhile we will connect to a other applicaction to get session data
  def get_session_from_outside(token)
  	session=nil	
  	plsql.pr_web_vitalicia.obtener_perfil(token) do |cursor|            
      session = cursor.fetch_all
    end	

    #if session is not valid go to vitalicia home
    if session.present?
    	return session
    else
    	redirect_to "http://www.lavitalicia.com"
    end		
  end

  def get_session
      @token =  params[:token]
      @session= get_session_from_outside(@token).first
      logger.debug "USER: #{@session}"
  end

  #Oracle reports call
  def download_oracle_report(report_name, params)
      #searching in DB config server

      token = SecureRandom.urlsafe_base64
      system= System.first

      #creating URL
      url_request = "#{system.reports_oracle_server}#{system.reports_oracle_config}#{report_name}&destype=cache&desformat=pdf&#{params}"
 
      logger.debug "URL: #{url_request}"

      download = open(url_request)
      send_data(
        download.read, 
        :type => download.content_type,
        :filename => token,
        :disposition => 'inline'
      )
  end

  #pagination
  def get_rownum_by_page(page,record_per_page)     
     rownum = (((record_per_page.to_i * page.to_i)- record_per_page.to_i )+1)   
  end


  


end
