require "rails_helper"

RSpec.describe Weather::HourlyForecastComponent, type: :component do
  let(:hourly) do
    {
      "time"          => Array.new(24) { |i| "2026-05-22T#{i.to_s.rjust(2, "0")}:00" },
      "temperature_2m" => Array.new(24) { |i| 20.0 + i }
    }
  end

  subject(:component) { described_class.new(hourly: hourly) }

  describe "#hours" do
    it "returns 7 slots by default" do
      expect(component.hours.length).to eq(7)
    end

    it "returns the requested number of slots" do
      expect(described_class.new(hourly: hourly, slots: 3).hours.length).to eq(3)
    end

    it "formats the time label as abbreviated hour with am/pm" do
      full = described_class.new(hourly: hourly, slots: 24)
      expect(full.hours.first[:label]).to eq("12am")
      expect(full.hours[9][:label]).to eq("9am")
    end

    it "maps temperatures in order" do
      expect(component.hours.map { |h| h[:temp] }).to eq([20.0, 21.0, 22.0, 23.0, 24.0, 25.0, 26.0])
    end
  end
end
