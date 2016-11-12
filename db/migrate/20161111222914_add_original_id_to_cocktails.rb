class AddOriginalIdToCocktails < ActiveRecord::Migration[5.0]
  def change
    add_column :cocktails, :original_id, :integer
  end
end
