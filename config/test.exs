use Mix.Config

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :elixifm, ElixifmWeb.Endpoint,
  http: [port: 4002],
  server: false

# Print only warnings and errors during test
config :logger, level: :warn

config :elixifm,
  music_service: Elixifm.PlayingMock,
  music_service_url: "http://localhost:8000/"
