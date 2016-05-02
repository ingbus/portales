class CreateMedicamentRequests < ActiveRecord::Migration
  

  def change
    create_table :medicament_request_items do |t|
      t.references :medicament_request, index: true, foreign_key: true
      t.string :medicament_code
      t.decimal :ammount, :precision => 12, :scale => 2
      t.integer :quantity

      t.timestamps null: false
    end
  end
end
