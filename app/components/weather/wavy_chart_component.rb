module Weather
  class WavyChartComponent < ViewComponent::Base
    def initialize(temperatures:, width: 700, height: 64, padding: 10)
      @temperatures = temperatures
      @width = width
      @height = height
      @padding = padding
    end

    def fill_path
      "#{build_smooth_curve_path} L #{points.last[:x]},#{@height} L 0,#{@height} Z"
    end

    def line_path
      build_smooth_curve_path
    end

    private

    def points
      @points ||= begin
        min = @temperatures.min.to_f
        max = @temperatures.max.to_f
        range = (max - min).nonzero? || 1.0
        last_index = @temperatures.length - 1

        @temperatures.each_with_index.map do |temperature, index|
          temperature_to_svg_point(temperature, index, last_index: last_index, min: min, range: range)
        end
      end
    end

    def temperature_to_svg_point(temperature, index, last_index:, min:, range:)
      x = (index.to_f / last_index * @width).round(2)
      
      normalized_y = (temperature - min) / range

      y = (@padding + (1 - normalized_y) * (@height - 2 * @padding)).round(2)
      
      { x: x, y: y }
    end

    def build_smooth_curve_path
      path_points = points
      path = "M #{path_points[0][:x]},#{path_points[0][:y]}"

      path_points.each_with_index do |current, index|
        next if index.zero?

        previous   = path_points[index - 1]
        two_before = path_points[index - 2] || previous
        following  = path_points[index + 1] || current

        cp1x = (previous[:x] + (current[:x] - two_before[:x]) / 6.0).round(2)
        cp1y = (previous[:y] + (current[:y] - two_before[:y]) / 6.0).round(2)
        cp2x = (current[:x]  - (following[:x] - previous[:x]) / 6.0).round(2)
        cp2y = (current[:y]  - (following[:y] - previous[:y]) / 6.0).round(2)

        path += " C #{cp1x},#{cp1y} #{cp2x},#{cp2y} #{current[:x]},#{current[:y]}"
      end

      path
    end
  end
end
