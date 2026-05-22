module Weather
  class WeatherService
    ZIPCODEBASE_URL = "https://app.zipcodebase.com"
    FORECAST_URL    = "https://api.open-meteo.com"

    Result = Data.define(:city, :country, :latitude, :longitude, :current, :hourly, :daily, :cached)

    def self.run(zip_code)
      new(zip_code).call
    end

    def initialize(zip_code)
      @zip_code = zip_code
    end

    def call
      cached = Rails.cache.read(cache_key)
      return cached.with(cached: true) if cached

      coords = geocode
      return nil unless coords

      weather = fetch_forecast(coords)
      return nil unless weather

      result = build_result(coords, weather)
      Rails.cache.write(cache_key, result, expires_in: 30.minutes)
      result
    end

    private

    def cache_key
      "weather/forecast/#{@zip_code.gsub(/\W/, '').downcase}"
    end

    def geocode
      response = geocoding_client.get("/api/v1/search", { codes: @zip_code, apikey: ENV.fetch("ZIPCODEBASE_API_KEY") })
      
      raw = response.body["results"]
      results = raw.is_a?(Hash) ? (raw[@zip_code] || raw.values.first) : raw
      entry = results&.first
      return nil unless entry

      {
        city: entry["city"],
        country: entry["country_code"],
        latitude: entry["latitude"].to_f,
        longitude: entry["longitude"].to_f
      }
    rescue Faraday::Error => e
      nil
    end

    def fetch_forecast(coords)
      response = forecast_client.get("/v1/forecast", {
        latitude: coords[:latitude],
        longitude: coords[:longitude],
        current: "temperature_2m,relative_humidity_2m,wind_speed_10m,weather_code",
        hourly: "temperature_2m,weather_code",
        daily: "weather_code,temperature_2m_max,temperature_2m_min",
        wind_speed_unit: "kmh",
        temperature_unit: "fahrenheit",
        timezone: "auto",
        forecast_days: 7,
        forecast_hours: 24
      })
      response.body
    rescue Faraday::Error
      nil
    end

    def build_result(coords, weather)
      Result.new(
        city: coords[:city],
        country: coords[:country],
        latitude: coords[:latitude],
        longitude: coords[:longitude],
        current: weather["current"],
        hourly: weather["hourly"],
        daily: weather["daily"],
        cached: false
      )
    end

    def geocoding_client
      @geocoding_client ||= Faraday.new(url: ZIPCODEBASE_URL) do |f|
        f.request :url_encoded
        f.response :json
        f.response :raise_error
        f.adapter Faraday.default_adapter
      end
    end

    def forecast_client
      @forecast_client ||= Faraday.new(url: FORECAST_URL) do |f|
        f.request :url_encoded
        f.response :json
        f.response :raise_error
        f.adapter Faraday.default_adapter
      end
    end
  end
end
