class AddOriginToCocktail < ActiveRecord::Migration[5.0]
  def change
    add_column :cocktails, :origin, :string
  end
end
