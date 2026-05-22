module Weather
  class SearchController < ApplicationController
    def index
      @searched = params[:zip_code].present?
      @result = Weather::WeatherService.run(params[:zip_code]) if @searched
    end
  end
end
