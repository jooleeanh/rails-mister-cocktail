class AddDbPhotoToCocktails < ActiveRecord::Migration[5.0]
  def change
    add_column :cocktails, :db_photo, :string
  end
end
