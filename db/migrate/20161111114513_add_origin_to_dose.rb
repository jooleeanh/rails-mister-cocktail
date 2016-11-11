class AddOriginToDose < ActiveRecord::Migration[5.0]
  def change
    add_column :doses, :origin, :string
  end
end
