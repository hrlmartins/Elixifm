defmodule Elixifm.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    :ets.new(:user_session, [:set, :public, :named_table, write_concurrency: true])
    # List all child processes to be supervised
    children = [
      # Start the Ecto repository
      Elixifm.Repo,
      # Start the endpoint when the application starts
      ElixifmWeb.Endpoint
      # Starts a worker by calling: Elixifm.Worker.start_link(arg)
      # {Elixifm.Worker, arg},
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Elixifm.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    ElixifmWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
