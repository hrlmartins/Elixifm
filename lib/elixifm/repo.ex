defmodule Elixifm.Repo do
  use Ecto.Repo,
    otp_app: :elixifm,
    adapter: Ecto.Adapters.Postgres
end
