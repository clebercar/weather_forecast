# Weather Forecast

A Rails 8 app that shows a 7-day weather forecast for any zip code. Enter a zip and get current conditions, hourly temperatures, and a daily breakdown — all cached so repeat lookups are instant.

## Features

- Zip code search with results persisted in the URL (shareable, refresh-safe)
- Current conditions: temperature (F/C toggle), humidity, wind speed
- Hourly temperature chart with a smooth SVG wave
- 7-day forecast with weather icons
- 30-minute forecast cache with a "Cached result" indicator in the UI

## Tech stack

- **Rails 8.1** — Propshaft, Solid Cache, Import Maps
- **Tailwind CSS v4** via `tailwindcss-rails`
- **ViewComponent** — each UI section is an isolated component
- **Stimulus** — temperature unit toggle and search form loading state
- **Faraday** — HTTP client for both external APIs

## External APIs

| API | Purpose |
|-----|---------|
| [Zipcodebase](https://zipcodebase.com) | Geocoding — zip code → coordinates |
| [Open-Meteo](https://open-meteo.com) | Forecast — coordinates → weather data |

## Setup

```bash
bundle install
cp .env.example .env   # add your ZIPCODEBASE_API_KEY
bin/rails tailwindcss:build
bin/rails server
```

Visit `http://localhost:3000/weather/search`.

## Environment variables

| Variable | Description |
|----------|-------------|
| `ZIPCODEBASE_API_KEY` | API key from zipcodebase.com |

## Cache strategy

Forecast results are cached per zip code for **30 minutes** using `Rails.cache`. The cache key normalises the zip code (strips non-alphanumeric characters) so `01310-100` and `01310100` share the same entry. When a result is served from cache, a subtle clock badge appears in the UI.

| Environment | Backend | Notes |
|-------------|---------|-------|
| Development | `memory_store` | In-process, cleared on server restart |
| Test | `memory_store` | Cleared before each spec |
| Production | `solid_cache` | Rails 8 default — persists in the database, shared across Puma workers |

### Production considerations

`solid_cache` works well for single-server deployments but stores cache data in the primary database. For high-traffic or multi-server setups, replace it with a dedicated cache store:

```ruby
# config/environments/production.rb
config.cache_store = :redis_cache_store, { url: ENV["REDIS_URL"] }
```

Redis provides lower latency, is shared across all app servers, and does not consume database capacity. Memcached is another option if persistence across restarts is not needed. No changes to the service layer are required — the cache interface is the same regardless of backend.

## Running tests

```bash
bundle exec rspec                        # full suite
bundle exec rspec spec/services          # service specs only
bundle exec rspec spec/components        # component specs only
bundle exec rspec spec/requests          # request specs only
```

## Project structure

```
app/
  components/weather/   # ViewComponents (one per UI section)
  services/weather/     # WeatherService — geocoding, forecast, caching
  javascript/
    controllers/        # Stimulus controllers (temperature toggle, search form)
spec/
  components/weather/   # Component unit specs
  requests/weather/     # Controller integration specs
  services/weather/     # Service unit specs (cache behaviour)
```
