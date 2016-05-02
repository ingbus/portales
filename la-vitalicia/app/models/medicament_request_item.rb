class MedicamentRequestItem < ActiveRecord::Base
  belongs_to :medicament_request
  before_validation :ammount

  validates :medicament_code, :quantity, :ammount, presence: true

  validate :ammount_value

  def ammount=(num)   
    write_attribute(:ammount, num.to_s.gsub(',', '.').to_f)    
  end     

   
  def ammount_value

  	plsql.pr_web_vitalicia_proveedor.obtener_montos(medicament_code.to_i) do |cursor_c|
      @amounts = cursor_c.fetch_all
    end
    	
    if ammount.to_f < @amounts[0][0] or ammount.to_f > @amounts[0][1]
      
     errors.add(:ammount, "El precio está fuera del rango permitido, el valor máximo es #{@amounts[0][1]} Bs.")
      
    end
  end	
end
