class AddDefaultValueToVotesInCocktails < ActiveRecord::Migration[5.0]
  def change
    change_column :cocktails, :votes, :integer, :default => 0
  end
end
