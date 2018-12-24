defmodule ElixifmWeb.SystemController do
  use ElixifmWeb, :controller

  alias Elixifm.Slack.Responses

  @music_service Confex.fetch_env!(:elixifm, :music_service)

  def playing(conn, %{"text" => input, "user_name" => username} = params) do
    with trimed_input <- input |> String.trim(),
         trimmed_username <- username |> String.trim(),
         {:ok, response} <- process_request(trimed_input, trimmed_username, params) do
      conn
      |> put_resp_content_type("application/json")
      |> send_resp(200, response)
    else
      ## TODO build error response
      _ -> conn |> send_resp(500, "Upsy doosy")
    end
  end

  defp process_request(input, username, _params) when input != "" do
    with {:ok, content} <- @music_service.playing(input) do
      {:ok, Responses.generate_channel_message(content, username)}
    else
      {:err, reason} -> IO.puts(reason)
    end
  end

  defp process_request(_input, _username, _params) do
    msg = "DANG! Someday I'll manage to guess what is your user in Last.Fm." <>
      " Until then provide me your LastFm username paleeeeease!"

    {:ok, Responses.generate_private_message(msg)}
  end
end
