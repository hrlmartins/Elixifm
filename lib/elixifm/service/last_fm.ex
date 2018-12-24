defmodule Elixifm.Services.LastFm do
  @behaviour Elixifm.Playing

  @base_url Confex.fetch_env!(:elixifm, :music_service_url)
  @service_id Confex.fetch_env!(:elixifm, :service_access_id)

  @impl Elixifm.Playing
  def playing(username) do
    with request_url <- gen_url(username),
         {:ok, content} <- make_request(request_url),
         track <- parse_response(content) do
      {:ok, track}
    else
      _ -> {:err, "Unable to fetch data"}
    end
  end

  defp gen_url(username) do
    @base_url <>
      "?method=user.getrecenttracks&user=#{username}&api_key=#{@service_id}&format=json&limit=1"
  end

  defp make_request(request_url) do
    case HTTPoison.get(request_url) do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        {:ok, body}

      {:error, %HTTPoison.Error{reason: reason}} ->
        IO.puts(reason)
        {:err, "not the expected response"}
    end
  end

  defp parse_response(response) do
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

    %Elixifm.Track{artist: artist, name: track_name}
  end
end
