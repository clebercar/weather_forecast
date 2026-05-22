module ApplicationHelper
  WEATHER_DESCRIPTIONS = {
    0 => "Clear sky", 1 => "Mainly clear", 2 => "Partly cloudy", 3 => "Overcast",
    45 => "Foggy", 48 => "Icy fog",
    51 => "Light drizzle", 53 => "Drizzle", 55 => "Heavy drizzle",
    61 => "Light rain", 63 => "Rain", 65 => "Heavy rain",
    71 => "Light snow", 73 => "Snow", 75 => "Heavy snow",
    80 => "Rain showers", 81 => "Showers", 82 => "Violent showers",
    95 => "Thunderstorm", 96 => "Thunderstorm with hail", 99 => "Thunderstorm with heavy hail"
  }.freeze

  def weather_description(code)
    WEATHER_DESCRIPTIONS[code] || "Unknown"
  end

  def weather_icon_svg(code, size: "w-7 h-7")
    icon = case code
           when 0, 1 then :sunny
           when 2     then :partial
           when 3     then :cloudy
           when 45, 48 then :foggy
           when 51..67, 80..82 then :rain
           when 71..77 then :snow
           when 95..99 then :storm
           else :sunny
           end

    render partial: "weather/search/icons/#{icon}", locals: { size: size }
  end
end
