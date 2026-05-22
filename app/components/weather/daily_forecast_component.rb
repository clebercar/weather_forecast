module Weather
  class DailyForecastComponent < ViewComponent::Base
    def initialize(daily:)
      @daily = daily
    end

    def days
      @daily["time"].each_with_index.map do |date, i|
        {
          label: Date.parse(date).strftime("%a"),
          code: @daily["weather_code"][i],
          max: @daily["temperature_2m_max"][i],
          min: @daily["temperature_2m_min"][i]
        }
      end
    end
  end
end
