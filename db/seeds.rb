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
  puts "\n#{Ingredient.count} ingredients created!"
end

def parse_cocktails
  puts "Parsing thecocktaildb.com for cocktails"
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
  puts "\n#{Cocktail.count} cocktails created!"
end

def parse_doses

end

def create_cocktail_doses
  puts "Creating doses instances for each cocktail"
  Cocktail.all.each do |c|
    puts "\nParsing thecocktaildb.com for #{c.name}'s doses"
    url_cocktail = "http://www.thecocktaildb.com/api/json/v1/1/search.php?s=#{c.name}"
    doses = JSON.parse(open(url_cocktail).read)
    15.times do |i|
      ingredient = doses["drinks"]&.first["strIngredient#{i}"]
      if ingredient.nil? || ingredient.empty?
      else
        ingredient = Ingredient.find_by_name(ingredient)
        measure = doses["drinks"].first["strMeasure#{i}"]
        dose = c.doses.new(description: measure, ingredient: ingredient)
        dose.origin = "thecocktaildb"
        dose.save
      end
    end
    puts "#{c.doses.count} doses created!"
  end
end

delete_previous_seed
create_ingredients(parse_ingredients)
create_cocktails(parse_cocktails)
create_cocktail_doses
puts "\nSeeding done!"
