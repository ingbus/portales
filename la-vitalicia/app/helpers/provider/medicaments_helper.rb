module Provider::MedicamentsHelper

	def get_medicament_description(medicament_id)		
		medicament_description = ""	
		plsql.pr_web_vitalicia_proveedor.obtener_medicamento(medicament_id) do |cursor_c|
      		medicament_description = cursor_c.fetch_all.first[1]
    	end    	
    	return medicament_description
	end
end
