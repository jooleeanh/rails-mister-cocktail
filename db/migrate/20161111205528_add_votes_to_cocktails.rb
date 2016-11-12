class AddVotesToCocktails < ActiveRecord::Migration[5.0]
  def change
    add_column :cocktails, :votes, :integer
  end
end
