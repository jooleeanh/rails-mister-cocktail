require 'open-uri'
require 'json'

def delete_previous_seed
  puts "Deleting previous seed ..."
  puts "- Deleting doses ..."
  Dose.destroy_all rescue puts "No previous seed."
  puts "- Deleting ingredients ..."
  Ingredient.destroy_all rescue puts "No previous seed."
  puts "- Deleting cocktails ..."
  Cocktail.destroy_all rescue puts "No previous seed."
end

def parse_ingredients
  puts "Parsing thecocktaildb.com for ingredients"
  url_ingredients = "http://www.thecocktaildb.com/api/json/v1/1/list.php?i=list"
  JSON.parse(open(url_ingredients).read)
end

def create_ingredients(ingredients)
  puts "Creating ingredient instance for each item"
  ingredients['drinks'].each do |ingredient|
    Ingredient.create(name: ingredient['strIngredient1'])
    print "."
  end
end

def parse_cocktails
  puts "\nParsing thecocktaildb.com for cocktails"
  url_cocktails = "http://www.thecocktaildb.com/api/json/v1/1/filter.php?a=Alcoholic"
  JSON.parse(open(url_cocktails).read)
end

def create_cocktails(cocktails)
  puts "Creating cocktail instance for each item"
  cocktails = cocktails['drinks'].sample(30)
  cocktails.each do |cocktail|
    url = cocktail['strDrinkThumb']
    if url
      cocktail = Cocktail.new(name: cocktail['strDrink'], origin: "thecocktaildb")
      cocktail.save!
      cocktail.photo_url = url
      print "."
    end
  end
end

delete_previous_seed
create_ingredients(parse_ingredients)
create_cocktails(parse_cocktails)
puts "\nSeeding done!"
