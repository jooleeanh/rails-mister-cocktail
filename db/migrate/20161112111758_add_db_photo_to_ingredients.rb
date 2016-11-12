class AddDbPhotoToIngredients < ActiveRecord::Migration[5.0]
  def change
    add_column :ingredients, :db_photo, :string
  end
end
