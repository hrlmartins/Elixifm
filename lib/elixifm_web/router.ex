defmodule ElixifmWeb.Router do
  use ElixifmWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", ElixifmWeb do
    pipe_through :browser

    get "/", PageController, :index
  end

  # Other scopes may use custom stacks.
  scope "/api", ElixifmWeb do
    pipe_through :api

    auth_callback_path = Confex.fetch_env!(:elixifm, :auth_callback_path)

    post "/playing", SystemController, :playing
    #post auth_callback_path, AuthController, :service_callback
  end
end
