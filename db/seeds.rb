require 'open-uri'
require 'json'
require 'colorize'

def delete_previous_seed_prompt
  puts "Deleting previous seed ...".light_yellow
  delete_doses if delete?(Dose)
  delete_ingredients if delete?(Ingredient)
  delete_cocktails if delete?(Cocktail)
end

def delete_previous_seed
  puts "Deleting previous seed ...".light_yellow
  delete_doses
  delete_ingredients
  delete_cocktails
end

def delete?(model)
  puts "Database has #{model.count} #{model.name.downcase}s"
  print "Delete all #{model.name.downcase}s? [y/n] ".yellow
  answer = STDIN.gets.chomp
  answer == "y"
end

def delete_doses
  puts "- Deleting doses ...".light_yellow
  Dose.destroy_all rescue puts "No previous seed.".light_red
end

def delete_ingredients
  puts "- Deleting ingredients ...".light_yellow
  Ingredient.destroy_all rescue puts "No previous seed."
end

def delete_cocktails
  puts "- Deleting cocktails ...".light_yellow
  Cocktail.destroy_all rescue puts "No previous seed.".light_red
end

def parse_ingredients
  puts "Parsing thecocktaildb.com for ingredients".light_cyan
  url_ingredients = "http://www.thecocktaildb.com/api/json/v1/1/list.php?i=list"
  JSON.parse(open(url_ingredients).read)
end

def create_ingredients(ingredients)
  puts "Creating ingredient instance for each item".light_cyan
  ing_count_before = Ingredient.count
  missing_ing_photo = 0
  ingredients['drinks'].each do |ingredient|
    name = ingredient['strIngredient1']
    if Ingredient.exists?(name: name)
      new_ingredient = Ingredient.find_by_name(name)
    else
      new_ingredient = Ingredient.new(name: name)
    end
    if new_ingredient.photo?
    else
      photo_url = "http://www.thecocktaildb.com/images/ingredients/#{name}-Small.png"
      begin
        new_ingredient.photo_url = photo_url
      rescue
        missing_ing_photo += 1
        nil
      end
    end
    new_ingredient.save
    print "#{new_ingredient.name}" + " created              \r".green
    $stdout.flush
  end
  ing_count_created = Ingredient.count - ing_count_before
  puts ""
  puts "- #{ing_count_before} ingredients already in database".light_green
  puts "- #{ing_count_created} ingredients created".green
  puts "- #{Ingredient.count} ingredients total".light_green
  puts "- #{missing_ing_photo} ingredients don't have a photo".light_magenta
end

def parse_cocktails
  puts "Parsing thecocktaildb.com for cocktails".light_cyan
  url_cocktails = "http://www.thecocktaildb.com/api/json/v1/1/filter.php?a=Alcoholic"
  JSON.parse(open(url_cocktails).read)
end

def create_cocktails(cocktails)
  puts "Creating cocktail instance for each item".light_cyan
  cocktails_count_before = Cocktail.count
  missing_cocktails_photos = 0
  cocktails = cocktails['drinks']
  cocktails.each do |cocktail|
    votes = rand(0..220)
    name = cocktail['strDrink']
    if Cocktail.exists?(name: name)
      new_cocktail = Cocktail.find_by_name(name)
    else
      new_cocktail = Cocktail.new(name: name, origin: "thecocktaildb", votes: votes)
    end
    new_cocktail.original_id = cocktail['idDrink']
    new_cocktail.category = cocktail['strCategory']
    new_cocktail.alcoholic = cocktail['strAlcoholic']
    new_cocktail.glass = cocktail['strGlass']
    new_cocktail.instructions = cocktail['strInstructions']

    photo_url = cocktail['strDrinkThumb']
    if new_cocktail.photo?
    else
      begin
        new_cocktail.photo_url = photo_url
      rescue
        missing_cocktails_photos += 1
        nil
      end
    end
    new_cocktail.save
    print "#{new_cocktail.name}" + " created              \r".green
    $stdout.flush
  end
  cocktails_count_created = Cocktail.count - cocktails_count_before
  puts ""
  puts "#{cocktails_count_before} cocktails already in database".light_green
  puts "#{cocktails_count_created} cocktails created".green
  puts "#{Cocktail.count} cocktails total".light_green
  puts "#{missing_cocktails_photos} cocktails don't have a photo".light_magenta
end

def create_cocktail_doses
  puts "Creating doses instances for each cocktail".light_cyan
  Cocktail.all.each do |c|
    if c.doses.count > 0
    else
      url_cocktail = "http://www.thecocktaildb.com/api/json/v1/1/lookup.php?i=#{c.original_id}"
      begin
        doses = JSON.parse(open(url_cocktail).read)
        15.times do |i|
          begin
            ingredient = doses["drinks"].first["strIngredient#{i+1}"]
          rescue
          end
          if ingredient.nil? || ingredient.empty?
          else
            ingredient = Ingredient.find_by_name(ingredient)
            begin
              measure = doses["drinks"].first["strMeasure#{i+1}"]
              dose = c.doses.new(description: measure, ingredient: ingredient)
              dose.origin = "thecocktaildb"
              dose.save
            rescue
            end
          end
        end
        puts "#{c.name} - #{c.doses.count} doses created!                        \r".green
      rescue
        puts "#{c.name} has no info".light_red
      end
    end
  end
  puts "#{Dose.count} doses total".light_yellow
end

delete_previous_seed_prompt
create_ingredients(parse_ingredients)
create_cocktails(parse_cocktails)
create_cocktail_doses
puts "\nSeeding done!".green
