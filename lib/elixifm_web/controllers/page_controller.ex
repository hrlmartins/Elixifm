defmodule ElixifmWeb.PageController do
  use ElixifmWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
