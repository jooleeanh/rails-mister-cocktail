class Cocktail < ApplicationRecord
  has_many :doses, dependent: :destroy
  has_many :ingredients, through: :doses
  validates :origin, presence: true
  validates :name, presence: true, uniqueness: true
  has_attachment :photo

  scope :shown, -> { where(show: true) }
  scope :user_first_alphabet, -> { order("origin DESC", "name ASC") }
  scope :user_first_votes, -> { order() }
end
