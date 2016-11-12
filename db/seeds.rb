require 'open-uri'
require 'json'
require 'colorize'

def prompt_actions?(actions)
  answers = {}
  actions.each do |k, action|
    print "\nWould you like to ".light_cyan + action.upcase.light_red + "? [y/n] ".light_cyan
    answer = STDIN.gets.chomp
    answers[k] = (answer == "y")
  end
  answers
end

def execute_actions(answers)
  url_ingredients = "http://www.thecocktaildb.com/api/json/v1/1/list.php?i=list"
  url_cocktails = "http://www.thecocktaildb.com/api/json/v1/1/filter.php?a=Alcoholic"
  delete_previous_seed_prompt if answers[:delete]
  create_new_seed_prompt({url_i: url_ingredients, url_c: url_cocktails}) if answers[:create]
  resize_images_prompt if answers[:resize]
end

def prompt_action?(action, models)
  answers = {}
  puts "\n#{action}".red
  models.each do |k, v|
    puts "Database has #{v.count} #{v.name.downcase}s"
    print "#{action} #{v.name.downcase}s from thecocktaildb? [y/n] ".yellow
    answer = STDIN.gets.chomp
    answers[k] = (answer == "y")
  end
  answers
end

def delete_instances(model)
  puts "- Deleting #{model.name} ...".light_yellow
  model.destroy_all rescue puts "No previous seed.".light_red
end

def delete_previous_seed(answers = {d: true, i: true, c: true})
  puts "Deleting previous seed ...".light_yellow
  delete_instances(Dose) if answers[:d]
  delete_instances(Ingredient) if answers[:i]
  delete_instances(Cocktail) if answers[:c]
end

def delete_previous_seed_prompt
  answers = prompt_action?("Delete all", {d: Dose, i: Ingredient, c: Cocktail})
  delete_previous_seed(answers)
end

def create_new_seed(url_models, answers = {d: true, i: true, c: true})
  puts "Creating new seed ...".light_yellow
  if answers[:i]
    json_ingredients = parse_thecocktaildb(url_models[:url_i], "ingredients")
    create_ingredients(json_ingredients)
  end
  if answers[:c]
    json_cocktails = parse_thecocktaildb(url_models[:url_c], "cocktails")
    create_cocktails(json_cocktails)
  end
  create_cocktail_doses if answers[:d]
end

def create_new_seed_prompt(url_models)
  answers = prompt_action?("Fetch", {d: Dose, i: Ingredient, c: Cocktail})
  create_new_seed(url_models, answers)
end

def parse_thecocktaildb(url, model_name)
  puts "Parsing thecocktaildb.com for #{model_name}".light_cyan
  JSON.parse(open(normalize_uri(url)).read)
end

def create_ingredients(ingredients)
  puts "Creating ingredient instance for each item".light_cyan
  count_before = Ingredient.count
  missing_photos = 0
  ingredients['drinks'].each_with_index do |ingredient, index|
    name = ingredient['strIngredient1']
    new_ingredient = get_instance(Ingredient, name)
    photo_url = reformat_url("http://www.thecocktaildb.com/images/ingredients/#{name}-Small.png")
    set_picture(new_ingredient, "ingredients", photo_url, missing_photos)
    new_ingredient.save
    print_progress(index, name)
  end
  print_stats(count_before, Ingredient, missing_photos)
end

def create_cocktails(cocktails)
  puts "Creating cocktail instance for each item".light_cyan
  count_before = Cocktail.count
  missing_photos = 0
  cocktails = cocktails['drinks']
  cocktails.each_with_index do |cocktail, index|
    name = cocktail['strDrink']
    new_cocktail = get_instance(Cocktail, name)

    new_cocktail.origin = "thecocktaildb"
    new_cocktail.votes = rand(0..220)
    new_cocktail.original_id = cocktail['idDrink']
    new_cocktail.category = cocktail['strCategory']
    new_cocktail.alcoholic = cocktail['strAlcoholic']
    new_cocktail.glass = cocktail['strGlass']
    new_cocktail.instructions = cocktail['strInstructions']

    photo_url = cocktail['strDrinkThumb']
    set_picture(new_cocktail, "cocktails", photo_url, missing_photos)
    new_cocktail.save
    print_progress(index, name)
  end
  resize_all(Cocktail)
  print_stats(count_before, Cocktail, missing_photos)
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

def curl_png(filepath, photo_url)
  open(photo_url) {|f|
    File.open(filepath,"wb") do |file|
      IO.copy_stream(f, file)
    end
  }
end

def get_picture(filepath, photo_url, missing_photos)
  begin
    curl_png(filepath, photo_url)
  rescue
    missing_photos += 1
    nil
  end
end

def set_picture(instance, folder, photo_url, missing_photos)
  filepath = "app/assets/images/#{folder}/#{instance.name}.png"
  if instance.db_photo?
    instance.db_photo = filepath
  else
    get_picture(filepath, photo_url, missing_photos)
    instance.db_photo = filepath
  end
end

def print_progress(index, instance_name)
  print "#{index} - #{instance_name}" + " created              \r".green
  $stdout.flush
end

def get_instance(model, name)
  if model.exists?(name: name)
    new_ingredient = model.find_by_name(name)
  else
    new_ingredient = model.new(name: name)
  end
  new_ingredient
end

def print_stats(count_before, model, missing_photos)
  count_created = model.count - count_before
  puts ""
  puts "- #{count_before} #{model.name} already in database".light_green
  puts "- #{count_created} #{model.name} created".green
  puts "- #{model.count} #{model.name} total".light_green
  puts "- #{missing_photos} #{model.name} don't have a photo".light_magenta
end

def reformat_url(url)
  url.gsub(/\s/, "%20")
end

def normalize_uri(uri)
  return uri if uri.is_a? URI

  uri = uri.to_s
  uri, *tail = uri.rpartition "#" if uri["#"]

  URI(URI.encode(uri) << Array(tail).join)
end

def resize(file, name, size)
  `convert "#{file}#{name}.png" -resize #{size} "#{file}#{name}.png"`
end

def resize_all(model_class)
  model_name = model_class.name.downcase
  model_class.all.each do |instance|
    if instance.db_photo?
      name = instance.name
      file_path = "app/assets/images/#{model_name}s/"
      begin
        model_name == "ingredient" ? size = "30x30" : size = "300x300"
        resize(file_path, name, size)
      rescue
      end
    end
  end
end

def resize_images_prompt
  answers = prompt_action?("Resize images of", {i: Ingredient, c: Cocktail})
  resize_all(Ingredient) if answers[:i]
  resize_all(Cocktail) if answers[:c]
end

actions = {delete: "delete instances", create: "create instances", resize: "resize images"}

execute_actions(prompt_actions?(actions))
puts "\nSeeding done!".green
