class MoviesController < ApplicationController

  def movie_params
    params.require(:movie).permit(:title, :rating, :description, :release_date)
  end

  def show
    id = params[:id] # retrieve movie ID from URI route
    @movie = Movie.find(id) # look up movie by unique ID
    # will render app/views/movies/show.<extension> by default
  end

  def index
    @all_ratings = Movie.all_ratings
    @selected_ratings = @all_ratings if @selected_ratings.nil?
    if params[:sort_by].nil? && params[:ratings].nil?
      @movies = Movie.all
    else
      @sort_by = params[:sort_by]
      @ratings = params[:ratings]

      if params[:ratings].nil?
        ratings = Movie.all_ratings
      else
        ratings = @ratings.keys
      end
      @selected_ratings = ratings
      if @sort_by.nil?
        @movies = Movie.where(rating: ratings)
      else
        begin
          @movies = Movie.order("#{@sort_by} ASC").where(rating: ratings)
        rescue ActiveRecord::StatementInvalid
          flash[:warning] = "Movies can not be sorted in this order"
          @movies = Movie.find_all_by_rating(ratings)
        end
      end
    end
  end

  def new
    # default: render 'new' template
  end

  def create
    @movie = Movie.create!(movie_params)
    flash[:notice] = "#{@movie.title} was successfully created."
    redirect_to movies_path
  end

  def edit
    @movie = Movie.find params[:id]
  end

  def update
    @movie = Movie.find params[:id]
    @movie.update_attributes!(movie_params)
    flash[:notice] = "#{@movie.title} was successfully updated."
    redirect_to movie_path(@movie)
  end

  def destroy
    @movie = Movie.find(params[:id])
    @movie.destroy
    flash[:notice] = "Movie '#{@movie.title}' deleted."
    redirect_to movies_path
  end

end
