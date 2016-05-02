class CreateMedicamentRequestItems < ActiveRecord::Migration
  def change
    create_table :medicament_requests do |t|
      t.string :session_token
      t.integer :acsel_request_id
      t.integer :claim_id
      t.integer :insured_id
      t.references :user, index: true, foreign_key: true

      t.timestamps null: false
    end

    add_index :medicament_requests, [:claim_id,:insured_id,:session_token], name: 'idx_medic_request_validate'
  end
end
