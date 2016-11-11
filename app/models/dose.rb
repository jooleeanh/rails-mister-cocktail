class Dose < ApplicationRecord
  belongs_to :ingredient
  belongs_to :cocktail
  validates :description, :origin, presence: true
  validates :cocktail, uniqueness: { scope: :ingredient_id }
end
