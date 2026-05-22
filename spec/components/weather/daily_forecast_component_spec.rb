require "rails_helper"

RSpec.describe Weather::DailyForecastComponent, type: :component do
  let(:daily) do
    {
      "time"               => Array.new(7) { |i| (Date.new(2026, 5, 22) + i).iso8601 },
      "weather_code"       => Array.new(7) { |i| i },
      "temperature_2m_max" => Array.new(7) { |i| 28.0 + i },
      "temperature_2m_min" => Array.new(7) { |i| 18.0 + i }
    }
  end

  subject(:component) { described_class.new(daily: daily) }

  describe "#days" do
    it "returns 7 entries" do
      expect(component.days.length).to eq(7)
    end

    it "formats the label as abbreviated day name" do
      expect(component.days.first[:label]).to eq("Fri")
      expect(component.days[1][:label]).to eq("Sat")
    end

    it "maps weather code, max and min temperatures in order" do
      first = component.days.first
      expect(first[:code]).to eq(0)
      expect(first[:max]).to eq(28.0)
      expect(first[:min]).to eq(18.0)
    end

    it "includes each day's values correctly" do
      expect(component.days.map { |d| d[:max] }).to eq([28.0, 29.0, 30.0, 31.0, 32.0, 33.0, 34.0])
    end
  end
end
