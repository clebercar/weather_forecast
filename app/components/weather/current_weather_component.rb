module Weather
  class CurrentWeatherComponent < ViewComponent::Base
    def initialize(current:)
      @current = current
    end
  end
end
