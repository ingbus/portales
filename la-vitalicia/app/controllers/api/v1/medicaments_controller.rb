class Api::V1::MedicamentsController < Api::V1::BaseController
  def index
  	medicaments = nil
  	if params[:q]
	  	plsql.pr_web_vitalicia_proveedor.obtener_medicamento_nombre(params[:q]) do |cursor_c|
	      		medicaments = cursor_c.fetch_all
	    end  
	    @meds = medicaments.map do |medicament|
  			{ :id => medicament[0], :description => medicament[1] }
		end
	end      	
    respond_with(  { :total_count => 3, :incomplete_results => false, :items => @meds })
  end
end