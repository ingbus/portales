class Provider::InsurabilitiesController < ApplicationController
  # include SelectComboCollections

  def index        
    @area_code = params[:area_code]
    @mobile_phone = params[:mobile_phone]
    @document_type = params[:document_type]
    @document_number = params[:document_number]
    @name_prvdr  = @session[0]
    @insureds = [0][1]

    if params[:commit]
      if @area_code.present? && @mobile_phone.present? && @document_type.present? && @document_number.present?
          #search in PL/SQL
        plsql.pr_web_vitalicia_proveedor.polizas_asegurabilidad(@session[1],
                                                                @document_type,@document_number, 
                                                                @area_code,
                                                                @mobile_phone) do |cursor|
          @insureds = cursor.fetch_all
          logger.debug "@insureds: #{@insureds}"

        end 
        
      else
        flash.now[:alert] = "Se debe completar todos los campos" +
                            " para poder realizar la consulta"  
      end  
    end  
    

  end

  def show_insured
    @insured = params[:insured]
  end

  def show_modal_ticket_request
    
    @policy_id = params[:policy_id]
    @insured_number = params[:insured_number]
    @insured_name = params[:insured_name]
    @area_code = params[:area_code]
    @mobile_phone = params[:mobile_phone]
  end

  def create_ticket
    @policy_id = params[:policy_id]
    @insured_number = params[:insured_number]
    area_code = params[:area_code]
    mobile_phone = params[:mobile_phone]

    @ticket_number = plsql.pr_web_vitalicia_proveedor.crear_ticket(@session[1], 
                                                                   @policy_id.to_i, 
                                                                   @insured_number.to_i,
                                                                   area_code,
                                                                   mobile_phone)[:cnumticket]
  end

  def list_recent_tickets

    @policy_id = params[:policy_id]
    @insured_number = params[:insured_number]
    @policy_number = params[:policy_number]
    @insured_name = params[:insured_name]
    @doc_type = params[:doc_type]
    @doc_number = params[:doc_number]

    plsql.pr_web_vitalicia_proveedor.tickets_asegurabilidad(@session[1],
                                                            @policy_id.to_i,
                                                            @insured_number.to_i) do |cursor|
      @tickets = cursor.fetch_all
    end     
  end

  def cancel_request
    
  end
end
