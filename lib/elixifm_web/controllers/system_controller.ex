defmodule ElixifmWeb.SystemController do
  use ElixifmWeb, :controller
  require Logger

  alias Elixifm.Slack.Responses

  @music_service Confex.fetch_env!(:elixifm, :music_service)

  def playing(conn, %{"text" => input, "user_name" => username} = params) do
    with trimed_input <- input |> String.trim(),
         trimmed_username <- username |> String.trim(),
         {:ok, response} <- process_request(trimed_input, trimmed_username, params) do
      Logger.info("Processing complete, responding to service")

      conn
      |> put_resp_content_type("application/json")
      |> send_resp(200, response)
    else
      _ -> conn |> send_resp(500, "Upsy doosy")
    end
  end

  defp process_request(music_service_username, username, _params)
       when music_service_username != "" do
    Logger.info(
      "Processing - Requesting information for user #{music_service_username} on music service"
    )

    with {:ok, content} <- @music_service.playing(music_service_username) do
      {:ok, Responses.generate_channel_message(content, username, music_service_username)}
    else
      {:err, reason} ->
        Logger.warn("Processing - music service information request failed: #{reason}")
        {:err, reason}

      {:app_error, reason} ->
        application_error_response(reason)

      {:empty, _} ->
        no_tracks_played_response()
    end
  end

  defp process_request(_music_service_username, _username, _params) do
    msg =
      "DANG! Someday I'll manage to guess what is your user in Last.Fm." <>
        " Until then provide me your LastFm username paleeeeease!"

    {:ok, Responses.generate_private_message(msg)}
  end

  defp application_error_response(reason) do
    msg = "oh oh! Your request failed: #{reason}"
    {:ok, Responses.generate_private_message(msg)}
  end

  defp no_tracks_played_response do
    msg = "That user has no played tracks!"
    {:ok, Responses.generate_private_message(msg)}
  end
end
