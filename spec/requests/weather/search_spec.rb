require "rails_helper"

RSpec.describe "Weather::Search", type: :request do
  let(:stub_result) do
    Weather::WeatherService::Result.new(
      city: "São Paulo", country: "BR",
      latitude: -23.5, longitude: -46.6,
      cached: false,
      current: { "temperature_2m" => 25.0, "relative_humidity_2m" => 70,
                 "wind_speed_10m" => 10.0, "weather_code" => 1 },
      hourly: { "time" => Array.new(24) { |i| "2026-05-22T#{i.to_s.rjust(2, "0")}:00" },
                "temperature_2m" => Array.new(24, 25.0),
                "weather_code"   => Array.new(24, 1) },
      daily: { "time" => Array.new(7) { |i| (Date.new(2026, 5, 22) + i).iso8601 },
               "weather_code"       => Array.new(7, 1),
               "temperature_2m_max" => Array.new(7, 28.0),
               "temperature_2m_min" => Array.new(7, 18.0) }
    )
  end

  describe "GET /weather/search" do
    context "without a zip code" do
      it "returns 200 and renders the empty state" do
        get weather_search_index_path
        expect(response).to have_http_status(:ok)
        expect(response.body).not_to include("Location not found")
        expect(response.body).not_to include("São Paulo")
      end
    end

    context "with a valid zip code" do
      before { allow(Weather::WeatherService).to receive(:run).with("01310100").and_return(stub_result) }

      it "returns 200 and renders the weather card" do
        get weather_search_index_path, params: { zip_code: "01310100" }
        expect(response).to have_http_status(:ok)
        expect(response.body).to include("São Paulo")
      end

      it "passes the zip code to WeatherService" do
        expect(Weather::WeatherService).to receive(:run).with("01310100").and_return(stub_result)
        get weather_search_index_path, params: { zip_code: "01310100" }
      end
    end

    context "when zip code is not found" do
      before { allow(Weather::WeatherService).to receive(:run).and_return(nil) }

      it "returns 200 and shows the not found message" do
        get weather_search_index_path, params: { zip_code: "00000000" }
        expect(response).to have_http_status(:ok)
        expect(response.body).to include("Location not found")
      end
    end
  end
end
