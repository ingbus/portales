class Provider::MedicamentsController < ApplicationController
  
  before_action :search_params,only:[:index, 
                                     :request_medicament,
                                     :show_insured,
                                     :confirm_medicament_request]

  before_action :set_medicament_item, only: [:delete_medicament_item,
                                             :edit_medicament_item,
                                             :update_medicament_item]                   
                                                                
  before_action :get_insured_info, only: [:confirm_medicament_request,
                                          :request_medicament
                                          ]                                          

  def index  	   
    @insureds = nil

    if params[:commit]
      if @area_code.present? && @mobile_phone.present? && @document_type.present? && @document_number.present?
          #search in PL/SQL
        
        plsql.pr_web_vitalicia_proveedor.asegurados_medicamentos(@session[1],
                                                                @document_type,
                                                                @document_number) do |cursor|
          @insureds = cursor.fetch_all
          logger.debug "@insureds: #{@insureds}"          
          #search mains insured claims
          if @insureds.present?
            main_insured = @insureds.first
            plsql.pr_web_vitalicia_proveedor.siniestro_asegurado(@session[1],
                                                                  main_insured[0],
                                                                  main_insured[1]) do |cursor_c|
              @claims = cursor_c.fetch_all
            end   
          end  
          #end search
        end         
      else
        flash.now[:alert] = "Se debe completar todos los campos" +
                            " para poder realizar la consulta"  
      end  
    end  
  end


  def show_insured
    @insured = params[:insured]
    policy_id = params[:policy_id].to_i
    insured_id = params[:insured_id].to_i

    logger.debug "policy_id: #{policy_id}" 
    logger.debug "insured_id: #{insured_id}" 

    plsql.pr_web_vitalicia_proveedor.siniestro_asegurado(@session[1],
                                                          policy_id,
                                                          insured_id) do |cursor_c|
      @claims = cursor_c.fetch_all
    end  


  end

  def request_medicament
    @claim_id =  params[:claim_id].to_i
    @insured_id = params[:insured_id].to_i
    @claim_number =  params[:claim_number].to_i
     
    
    @medicament_request = MedicamentRequest.includes(:medicament_request_items).where("claim_id = ? and 
                                                   claim_number = ? and
                                                   insured_id = ? and 
                                                   session_token = ? and 
                                                   acsel_request_id is null",
                                                   @claim_id, 
                                                   @claim_number,
                                                   @insured_id,
                                                   @session[1]).order("medicament_request_items.created_at desc").first

    if !@medicament_request
      # session_token ==> provider_code (acsel)
      @medicament_request =  MedicamentRequest.new(claim_id: @claim_id, claim_number: @claim_number, insured_id: @insured_id, session_token: @session[1])
      @medicament_request.save       
    end  

  end

  def request_medicament_item
    @medicament_request_id = request[:medicament_request_id]    
    @medicament_request_item = MedicamentRequestItem.new  
    @medicaments = {:id => "seleccionar"}      
       
  end

  def create_medicament_item   
    
     @medicament_request_item = MedicamentRequestItem.new(medicament_request_item_params)
     if @medicament_request_item.save
        @medicament_request = MedicamentRequest.includes(:medicament_request_items).
                                             order("medicament_request_items.created_at desc").
                                             find(@medicament_request_item.medicament_request_id)
        @save = true
     else
            
        @save = false
       
     end                                           
     
  end

  def delete_medicament_item
    
    medicament_request_id =  @medicament_request_item.medicament_request_id    
    @medicament_request_item.destroy
    @medicament_request =  MedicamentRequest.includes(:medicament_request_items).
                                             order("medicament_request_items.created_at desc").
                                             find(medicament_request_id)
  
  end

  def edit_medicament_item    
    plsql.pr_web_vitalicia_proveedor.obtener_medicamento(@medicament_request_item.medicament_code.to_i) do |cursor_c|
      @medicaments = cursor_c.fetch_all
    end
  end

  def update_medicament_item 
    @medicament_request_item = MedicamentRequestItem.find(params[:id])   
    if @medicament_request_item.update_attributes(medicament_request_item_params)      
      @medicament_request = MedicamentRequest.includes(:medicament_request_items).
                                              order("medicament_request_items.created_at desc").
                                              find(@medicament_request_item.medicament_request_id)        
      @save = true                                        
    else
      @save = false
    end
  end

  def confirm_medicament_request
    @medicament_request =  MedicamentRequest.includes(:medicament_request_items).
                                              order("medicament_request_items.created_at desc").
                                              find(params[:id])

    @medicament_order_number = plsql.pr_web_vitalicia_proveedor.crear_orden_medicamento(:nideorden=>@medicament_request.id)[:cnumorden] 
    logger.debug "@medicament_order_number #{@medicament_order_number}"
    if @medicament_order_number != '0'
        flash.now[:success] = "La autorización Nº #{@medicament_order_number} ha sido procesada exitosamente. Abajo podrás ver el resumen."
        @medicament_request.acsel_request_id = @medicament_order_number
        @medicament_request.save
    else
        flash.now[:alert] = "Se ha presentado un error al crear la orden, por favor volver a probar"
    end  

  end

  def request_history
    @insured_id = params[:insured_id].to_i
    @document_type = params[:document_type]
    @document_number = params[:document_number]
    @insured_name = params[:insured_name]
    @policy_number = params[:policy_number]
    @medicament_requests =  MedicamentRequest.where(:session_token => @session[1], :insured_id=>@insured_id).processed
  end  

  def request_history_detail    
    @document_type = params[:document_type]
    @document_number = params[:document_number]
    @insured_name = params[:insured_name]
    @policy_number = params[:policy_number]
    @medicament_request = MedicamentRequest.includes(:medicament_request_items).find(params[:id])
    @insured_id = @medicament_request.insured_id
    plsql.pr_web_vitalicia_proveedor.obtener_asegurados(@medicament_request.insured_id,
                                                        @medicament_request.claim_id) do |cursor_c|
      @insured = cursor_c.fetch_all.first
    end      
  end



  private
  def search_params
      @area_code = params[:area_code]
      @mobile_phone = params[:mobile_phone]
      @document_type = params[:document_type]
      @document_number = params[:document_number]
      @name_prvdr  = @session[0]
  end

  def set_medicament_item
     @medicament_request_item = MedicamentRequestItem.find(params[:id])
  end


  def medicament_request_item_params
      params.require(:medicament_request_item).permit([:medicament_code, 
                                                       :ammount, 
                                                       :quantity,
                                                       :medicament_request_id])
  end

  def get_insured_info
    plsql.pr_web_vitalicia_proveedor.obtener_asegurados(@insured_id,
                                                        @claim_id) do |cursor_c|
      @insured = cursor_c.fetch_all.first
    end    
    @document_type_info = SelectComboCollections.doc_types[@insured[1]]
    @name_prvdr  = @session[0]
  end



end
