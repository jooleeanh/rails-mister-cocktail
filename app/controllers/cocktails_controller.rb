class CocktailsController < ApplicationController
  def index
    @cocktails = Cocktail.all
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

  private

  def instantiate_cocktail

  end

  def cocktail_params
    params.require(:cocktail).permit(:name, :photo)
  end
end
