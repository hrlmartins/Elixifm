defmodule Elixifm.Services.LastFm do
  @behaviour Elixifm.Playing

  require Logger

  @base_url Confex.fetch_env!(:elixifm, :music_service_url)
  @service_id Confex.fetch_env!(:elixifm, :service_access_id)

  @impl Elixifm.Playing
  def playing(username) do
    with request_url <- gen_url(username),
         {:ok, content} <- make_request(request_url),
         track <- parse_track_response(content) do
      {:ok, track}
    else
      {status, reason} -> {status, reason}
    end
  end

  defp gen_url(username) do
    @base_url <>
      "?method=user.getrecenttracks&user=#{username}&api_key=#{@service_id}&format=json&limit=1"
  end

  defp make_request(request_url) do
    Logger.debug("Invoking music service endpoint with url: #{request_url}")

    case HTTPoison.get(request_url) do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        Logger.debug(fn -> "Response from music service: #{inspect(body)}" end)
        body |> process_response()

      {:error, %HTTPoison.Error{reason: reason}} ->
        Logger.warn("Request to music service failed with reason: #{reason}")
        {:err, reason}
    end
  end

  defp process_response(response) do
    if is_error_response?(response) do
      {:app_error, extract_error(response)}
    else
      if is_track_empty?(response) do
        {:empty, "No played track"}
      else
        {:ok, response}
      end
    end
  end

  defp is_track_empty?(response) do
    response
    |> Jason.decode!()
    |> Map.get("recenttracks")
    |> Map.get("track")
    |> Enum.empty?()
  end

  defp is_error_response?(response) do
    response
    |> Jason.decode!()
    |> Map.has_key?("error")
  end

  defp extract_error(response) do
    response
    |> Jason.decode!()
    |> Map.get("message", "DefaultError")
  end

  defp parse_track_response(response) do
    response
    |> Jason.decode!()
    |> create_track()
  end

  defp create_track(response) do
    track =
      response
      |> Map.get("recenttracks")
      |> Map.get("track")
      ## First position is always the last or currently playing
      |> Enum.at(0)

    artist =
      track
      |> Map.get("artist")
      |> Map.get("#text")

    track_name =
      track
      |> Map.get("name")

    %Elixifm.Track{
      artist: artist,
      name: track_name,
      playing: is_playing?(Map.get(track, "@attr"))
    }
  end

  defp is_playing?(attribute) when is_map(attribute) do
    attribute
    |> Map.get("nowplaying")
    |> String.to_existing_atom()
  end

  defp is_playing?(_attribute), do: false
end
