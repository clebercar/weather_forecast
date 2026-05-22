module Weather
  class SearchController < ApplicationController
    def index
    end

    def create
      city = params[:city]
      @result = WeatherService.fetch(city)
    end
  end
end