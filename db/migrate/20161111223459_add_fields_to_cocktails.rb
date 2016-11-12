class AddFieldsToCocktails < ActiveRecord::Migration[5.0]
  def change
    add_column :cocktails, :category, :string
    add_column :cocktails, :alcoholic, :string
    add_column :cocktails, :glass, :string
    add_column :cocktails, :instructions, :string
  end
end
