defmodule ElixifmWeb.SystemController do
  use ElixifmWeb, :controller

  alias Elixifm.Slack.Responses
  alias Elixifm.Services.LastFm

  def playing(conn, %{"text" => input} = params) do
    with trimed_input <- input |> String.trim(),
         {:ok, response} <- process_request(trimed_input, params) do
      conn
      |> put_resp_content_type("application/json")
      |> send_resp(200, response)
    else
      ## TODO build error response
      _ -> conn |> send_resp(500, "Erro!!")
    end
  end

  defp process_request(input, _params) when input != "" do
    with {:ok, content} <- LastFm.get_playing(input) do
      {:ok, Responses.generate_private_message(content)}
    else
      {:err, reason} -> IO.puts(reason)
    end
  end

  defp process_request(_input, _params) do
    ## TODO Unknown command response
    {:ok, ""}
  end
end
