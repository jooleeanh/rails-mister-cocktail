class CocktailsController < ApplicationController
  def index
    @cocktails = Cocktail.shown.user_first_alphabet
  end

  def show
    @cocktail = Cocktail.find(params[:id])
    @dose = @cocktail.doses.new
    @ingredient = Ingredient.new
  end

  def new
    @cocktail = Cocktail.new
  end

  def create
    @cocktail = Cocktail.new(cocktail_params)
    @cocktail.origin = "user"
    if @cocktail.save
      redirect_to cocktail_path(@cocktail.id)
    else
      render 'new'
    end
  end

  def edit
    @cocktail = Cocktail.find(params[:id])
  end

  def update
    @cocktail = Cocktail.find(params[:id])
    if @cocktail.update(cocktail_params)
      redirect_to @cocktail
    else
      render 'edit'
    end
  end

  def sample
    Cocktail.all.update_all(show: false)
    cocktails = Cocktail.all.sample(30)
    cocktails.each do |cocktail|
      cocktail.show = true
      cocktail.save
    end
    redirect_to cocktails_path
  end

  private

  def instantiate_cocktail

  end

  def cocktail_params
    params.require(:cocktail).permit(:name, :photo)
  end
end
