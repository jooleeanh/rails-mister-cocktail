require 'open-uri'
require 'json'

puts "Deleting previous seed ..."
puts "- Deleting doses ..."
Dose.destroy_all rescue puts "No previous seed."
puts "- Deleting ingredients ..."
Ingredient.destroy_all rescue puts "No previous seed."
puts "- Deleting cocktails ..."
Cocktail.destroy_all rescue puts "No previous seed."


puts "Parsing thecocktaildb.com for ingredients..."
url_ingredients = "http://www.thecocktaildb.com/api/json/v1/1/list.php?i=list"
json = JSON.parse(open(url_ingredients).read)

puts "Creating ingredient instance for each item ..."
json['drinks'].each do |ingredient|
  Ingredient.create(name: ingredient['strIngredient1'])
end

puts "Parsing thecocktaildb.com for cocktails"
url_cocktails = "http://www.thecocktaildb.com/api/json/v1/1/filter.php?a=Alcoholic"
json = JSON.parse(open(url_cocktails).read)

puts "Creating cocktail instance for each item ..."
json['drinks'].sample(5).each do |cocktail|
  Cocktail.create(name: cocktail['strDrink'])
end

puts "Seeding done!"
