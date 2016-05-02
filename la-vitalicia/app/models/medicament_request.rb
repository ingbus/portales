class MedicamentRequest < ActiveRecord::Base
  belongs_to :user
  has_many :medicament_request_items

  scope :processed, -> { where.not(:acsel_request_id => nil).order("updated_at desc") } 
end
