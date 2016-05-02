class CreateSystems < ActiveRecord::Migration
  def change
    create_table :systems do |t|
      t.string :reports_oracle_server
      t.string :reports_oracle_config

      t.timestamps null: false
    end
  end
end
