require 'net/http'
require 'json'

puts "Deleting previous seed ..."
Ingredient.destroy_all

puts "Parsing thecocktaildb.com list ..."
url = "http://www.thecocktaildb.com/api/json/v1/1/list.php?i=list"
json = JSON.parse(Net::HTTP.get(URI(url)))

puts "Creating ingredient instance for each item ..."
json['drinks'].each do |ingredient|
  Ingredient.create(name: ingredient['strIngredient1'])
end

puts "Seeding done!"
