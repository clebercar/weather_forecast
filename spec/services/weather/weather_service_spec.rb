require "rails_helper"

RSpec.describe Weather::WeatherService do
  before { Rails.cache.clear }

  STUB_COORDS = {
    city: "São Paulo", country: "BR",
    latitude: -23.5, longitude: -46.6
  }.freeze

  STUB_WEATHER = {
    "current" => { "temperature_2m" => 25.0, "relative_humidity_2m" => 70,
                   "wind_speed_10m" => 10.0, "weather_code" => 1 },
    "hourly"  => { "time" => Array.new(24) { |i| "2026-05-22T#{i.to_s.rjust(2, "0")}:00" },
                   "temperature_2m" => Array.new(24, 25.0),
                   "weather_code"   => Array.new(24, 1) },
    "daily"   => { "time" => Array.new(7) { |i| (Date.new(2026, 5, 22) + i).iso8601 },
                   "weather_code"        => Array.new(7, 1),
                   "temperature_2m_max"  => Array.new(7, 28.0),
                   "temperature_2m_min"  => Array.new(7, 18.0) }
  }.freeze

  def stub_service(zip_code)
    service = described_class.new(zip_code)

    geocoding_response = double("geocoding_response", body: {
      "results" => [{ "city" => STUB_COORDS[:city], "country_code" => STUB_COORDS[:country],
                      "latitude" => STUB_COORDS[:latitude].to_s,
                      "longitude" => STUB_COORDS[:longitude].to_s }]
    })
    forecast_response = double("forecast_response", body: STUB_WEATHER)

    geocoding_client = double("geocoding_client")
    allow(geocoding_client).to receive(:get).and_return(geocoding_response)

    forecast_client = double("forecast_client")
    allow(forecast_client).to receive(:get).and_return(forecast_response)

    service.instance_variable_set(:@geocoding_client, geocoding_client)
    service.instance_variable_set(:@forecast_client, forecast_client)
    service
  end

  describe "#call" do
    context "when geocoding raises a network error" do
      it "returns nil" do
        service = described_class.new("01310100")
        geocoding_client = double("geocoding_client")
        allow(geocoding_client).to receive(:get).and_raise(Faraday::Error)
        service.instance_variable_set(:@geocoding_client, geocoding_client)

        expect(service.call).to be_nil
      end
    end

    context "when forecast fetch raises a network error" do
      it "returns nil" do
        service = stub_service("01310100")
        forecast_client = double("failing_forecast_client")
        allow(forecast_client).to receive(:get).and_raise(Faraday::Error)
        service.instance_variable_set(:@forecast_client, forecast_client)

        expect(service.call).to be_nil
      end
    end


    it "cache miss: fetches APIs and returns cached: false" do
      service = stub_service("01310100")
      result = service.call
      expect(result.cached).to eq(false)
      expect(result.city).to eq("São Paulo")
    end

    it "cache hit: returns cached: true without calling APIs" do
      stub_service("01310100").call

      result = described_class.run("01310100")
      expect(result.cached).to eq(true)
      expect(result.city).to eq("São Paulo")
    end

    it "cache key normalizes zip codes: dashes and plain hit same entry" do
      stub_service("01310-100").call
      result = described_class.run("01310100")
      expect(result.cached).to eq(true)
    end
  end
end
