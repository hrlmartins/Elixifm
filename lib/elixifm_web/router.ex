defmodule ElixifmWeb.Router do
  use ElixifmWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  # Other scopes may use custom stacks.
  scope "/api", ElixifmWeb do
    pipe_through :api

    post "/playing", SystemController, :playing
  end
end
