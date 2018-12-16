# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

config :elixifm,
  base_url: {:system, "ELIXIFM_BASE_URL", "localhost"},
  service_access_id: {:system, "ELIXIFM_SERVICE_ACCESS_ID", "123"},
  music_service: Elixifm.Services.LastFm

# Configures the endpoint
config :elixifm, ElixifmWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "vjFT4hoHYAbgHE0B3DqHOWt2EMxV/P2BQHDX9a+5btUfk2Vt8jd1G/fJG1BNMG8i",
  render_errors: [view: ElixifmWeb.ErrorView, accepts: ~w(html json)],
  pubsub: [name: Elixifm.PubSub, adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
