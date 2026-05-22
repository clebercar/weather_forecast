module Weather
  class WeatherHeaderComponent < ViewComponent::Base
    def initialize(result:)
      @result = result
    end

    private

    def condition
      helpers.weather_description(@result.current["weather_code"])
    end

    def datetime
      Time.now.strftime("%A %l%p").strip
    end
  end
end
