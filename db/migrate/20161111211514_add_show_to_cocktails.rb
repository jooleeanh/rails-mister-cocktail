class AddShowToCocktails < ActiveRecord::Migration[5.0]
  def change
    add_column :cocktails, :show, :boolean, default: false
  end
end
