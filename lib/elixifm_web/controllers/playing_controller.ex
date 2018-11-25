defmodule ElixifmWeb.PlayingController do
  use ElixifmWeb, :controller

  def playing(conn, params) do
    # TODO Something here
    conn |> IO.inspect(label: CONNECTION)
    IO.puts('\n')
    params |> IO.inspect(label: PARAMS)

    conn
    |> send_resp(200, "")
  end
end
