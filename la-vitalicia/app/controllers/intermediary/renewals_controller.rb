class Intermediary::RenewalsController < ApplicationController

	before_action :get_data_policy, only: [:get_coverags_by_plan,
                                   :prerenew_by_policy] 

	def prerenew
				
		@name_search=params[:search]
        @data = nil 
        @policy_search= params[:searchpolicy]
        @office_search= params[:searchoffice]
        total_records= nil
        @total_pages = nil
        record_per_page = 10 #definir constante

        if params[:page].present?
           @page= params[:page]
         else  
           @page=1
        end  

		@name_inter  = @session[0]
		total_records= plsql.pr_web_vitalicia_intermediario.total_polizas_pre_renovar(@session[1],@name_search,@policy_search,@office_search)
		
		@total_pages = total_records / record_per_page
        
        rest=total_records % record_per_page
		if total_records > record_per_page  && rest > 0
			@total_pages = @total_pages+1 
	    end		

		plsql.pr_web_vitalicia_intermediario.polizas_pre_renovar(@session[1],@name_search,@policy_search, @office_search,
			get_rownum_by_page(@page,record_per_page),record_per_page) do |cursor|
			@data = cursor.fetch_all
		end	

        plsql.pr_web_vitalicia_intermediario.devuelve_oficinas do |cursor|
			@data_oficce = cursor.fetch_all
		end	
		logger.debug "prueba #{@data}"
	end


	def get_policy_plans
				
    	@policy_id   =  params[:idpolicy]

        logger.debug "policy_id: #{@policy_id}"
    	
    	plsql.pr_web_vitalicia_intermediario.obtener_asegurado(@session[1],@policy_id.to_i) do |cursor|
			@insured = cursor.fetch_all.first
		end	

		logger.debug "insured: #{@insured}"
		logger.debug "codigo intermediario: #{@session[1]}"

		plsql.pr_web_vitalicia_intermediario.obtener_planes_pre_renovar(@session[1],@policy_id.to_i) do |cursor|
			@policy_plans = cursor.fetch_all
		end	

		logger.debug "policy_plans: #{@policy_plans}"

	end

	def get_coverags_by_plan
		
    	@plan_code = params[:plan_code]
    	@plan_version = params[:plan_version]
    	@product_code = params[:product_code]
    	@ind_current = params[:ind_current]
    	
    	plsql.pr_web_vitalicia_intermediario.obtener_asegurado(@session[1],@policy_id.to_i) do |cursor|
			@insured = cursor.fetch_all.first
		end			

		plsql.pr_web_vitalicia_intermediario.obtener_oberturas_planes(
			@session[1],@policy_id.to_i,@product_code,@plan_code, @plan_version ) do |cursor|
				@coverags_plan = cursor.fetch_all
		end	
	end
	
	def prerenew_by_policy
    	    	
    	plan_code = params[:plan_code]
    	plan_version = params[:plan_version]
    	product_code = params[:product_code]
   	    @prerenewal = false

    	plsql.pr_web_vitalicia_intermediario.obtener_asegurado(@session[1],@policy_id.to_i) do |cursor|
			@insured = cursor.fetch_all.first
		end			

		plsql.pr_web_vitalicia_intermediario.obtener_oberturas_planes(
			@session[1],@policy_id.to_i,product_code,plan_code, plan_version ) do |cursor|
				@coverags_plan = cursor.fetch_all
		end		        

        @prerenewal=plsql.pr_web_vitalicia_intermediario.pre_renovar(@session[1],@policy_id.to_i,
        	product_code,plan_code,plan_version) 

	end	

	

	def renewal
				
		@name_search_ren=params[:searchren]
        @data_ren = nil 
        @policy_search_ren= params[:searchpolicyren]
        @office_search_ren= params[:searchofficeren]
        total_records= nil
        @total_pages_ren = nil
        record_per_page = 10 #definir constante

        if params[:pageren].present?
           @page_ren= params[:pageren]
         else  
           @page_ren=1
        end  

		@name_inter  = @session[0]
		total_records= plsql.pr_web_vitalicia_intermediario.total_polizas_renovadas(@session[1],@name_search_ren,@policy_search_ren,@office_search_ren)
		
		@total_pages_ren = total_records / record_per_page
        
        rest=total_records % record_per_page
		if total_records > record_per_page  && rest > 0
			@total_pages_ren = @total_pages_ren+1 
	    end		
        logger.debug "total_pages_ren #{@total_pages_ren}"
        
		plsql.pr_web_vitalicia_intermediario.polizas_renovadas(@session[1],@name_search_ren,@policy_search_ren, @office_search_ren,
			get_rownum_by_page(@page_ren,record_per_page),record_per_page) do |cursor|
			@data_ren = cursor.fetch_all
		end	

        plsql.pr_web_vitalicia_intermediario.devuelve_oficinas do |cursor|
			@data_oficce = cursor.fetch_all
		end	
		logger.debug "prueba #{@data_ren}"
	end

	def get_not_renewal_policy

      codeofficepolicy = params[:codeoffice]
      policy_id   =  params[:idpolicy]
      plsql.pr_web_vitalicia_intermediario.polizas_no_renovar(@session[1], policy_id.to_i,codeofficepolicy)
      logger.debug "POLIZA: #{policy_id.to_i} "

      flash[:alert] = "La póliza ha sido calificada como NO renovable, por lo cual no estará disponible en esta pantalla"
      redirect_to prerenew_intermediary_renewals_path(:token=>@token)   	

	end	

	def print_report_policy
		policy_id   =  params[:idpolicy]	
		product_code    =  params[:product_code] 
		print_config=nil

		plsql.pr_web_vitalicia.imprimir_reporte(policy_id.to_i) do |cursor|
			print_config = cursor.fetch_all
		end	

		report_params=""
		report=""
		#iteration for config projects
		print_config.each do |config|
			report = "#{config[2].downcase}.rep"
			report_params = report_params+ "&#{config[0]}=#{config[1]}"
		end					
		
		download_oracle_report(report, "&destype=cache&desformat=pdf#{report_params}")

	end

	#
	private

	def get_data_policy
		@policy_id   =  params[:idpolicy]
		@description_plan = params[:descplan]
		@total_bonus = params[:bonus]
	end	

end

