require "rails_helper"

RSpec.describe Weather::WavyChartComponent, type: :component do
  let(:temperatures) { [20.0, 22.0, 25.0, 23.0, 21.0, 24.0, 26.0] }
  let(:component) { described_class.new(temperatures: temperatures, width: 700, height: 64, padding: 10) }

  describe "#line_path" do
    it "starts at the first point" do
      expect(component.line_path).to start_with("M 0.0,")
    end

    it "contains cubic bezier segments for each subsequent point" do
      expect(component.line_path.scan("C ").count).to eq(temperatures.length - 1)
    end
  end

  describe "#fill_path" do
    it "closes the path back to the bottom-left corner" do
      expect(component.fill_path).to end_with("L 0,#{64} Z")
    end

    it "includes the line path as its leading segment" do
      expect(component.fill_path).to start_with(component.line_path)
    end
  end

  describe "coordinate mapping" do
    it "places the first point at x=0" do
      expect(component.line_path).to start_with("M 0.0,")
    end

    it "places the last point at x=width" do
      expect(component.fill_path).to include("700.0,")
    end

    it "places the hottest temperature nearest the top (lowest y)" do
      hot_component  = described_class.new(temperatures: [30.0, 20.0], width: 100, height: 64, padding: 10)
      cold_component = described_class.new(temperatures: [20.0, 30.0], width: 100, height: 64, padding: 10)

      hot_y  = hot_component.line_path.match(/M 0\.0,(\S+)/)[1].to_f
      cold_y = cold_component.line_path.match(/M 0\.0,(\S+)/)[1].to_f

      expect(hot_y).to be < cold_y
    end
  end

  describe "edge case: all temperatures identical" do
    it "does not raise" do
      flat = described_class.new(temperatures: [20.0, 20.0, 20.0])
      expect { flat.line_path }.not_to raise_error
    end
  end
end
