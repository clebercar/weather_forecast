require "rails_helper"

RSpec.describe Weather::WeatherHeaderComponent, type: :component do
  let(:base_result) do
    Weather::WeatherService::Result.new(
      city: "São Paulo", country: "BR",
      latitude: -23.5, longitude: -46.6,
      cached: false,
      current: { "weather_code" => 1 },
      hourly: {}, daily: {}
    )
  end

  it "renders city and country" do
    rendered = render_inline(described_class.new(result: base_result))
    expect(rendered.text).to include("São Paulo")
    expect(rendered.text).to include("BR")
  end

  it "does not show the cached badge when cached: false" do
    rendered = render_inline(described_class.new(result: base_result))
    expect(rendered.text).not_to include("Cached result")
  end

  it "shows the cached badge when cached: true" do
    cached_result = base_result.with(cached: true)
    rendered = render_inline(described_class.new(result: cached_result))
    expect(rendered.text).to include("Cached result")
  end
end
