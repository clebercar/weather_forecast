module Weather
  class HourlyForecastComponent < ViewComponent::Base
    def initialize(hourly:, slots: 7)
      @times = hourly["time"].first(slots)
      @temps = hourly["temperature_2m"].first(slots)
    end

    def hours
      @times.each_with_index.map do |time, i|
        { label: Time.parse(time).strftime("%-I%p").downcase, temp: @temps[i] }
      end
    end
  end
end
