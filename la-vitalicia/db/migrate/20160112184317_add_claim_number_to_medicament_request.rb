class AddClaimNumberToMedicamentRequest < ActiveRecord::Migration
  def change
    add_column :medicament_requests, :claim_number, :integer
  end
end
