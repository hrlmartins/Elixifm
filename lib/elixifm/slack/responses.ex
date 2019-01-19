defmodule Elixifm.Slack.Responses do
  def generate_private_message(message) when is_binary(message) do
    generate_message_with_type(message, "ephemeral")
  end

  def generate_channel_message(message) do
    generate_message_with_type(message, "in_channel")
  end

  def generate_channel_message(%Elixifm.Track{} = track, username, service_username) do
    generate_playing_message(track, username, service_username)
    |> generate_message_with_type("in_channel")
  end

  defp generate_playing_message(
         %Elixifm.Track{artist: artist, name: name, playing: true} = _track,
         username,
         service_username
       ) do
    user_url = user_profile_url(service_username)

    "<#{user_url}|@#{username}> is playing: *#{artist} - #{name}*"
  end

  defp generate_playing_message(
         %Elixifm.Track{artist: artist, name: name, playing: false} = _track,
         username,
         service_username
       ) do
    user_url = user_profile_url(service_username)

    "<#{user_url}|@#{username}> last played: *#{artist} - #{name}*"
  end

  defp generate_message_with_type(message, type) do
    with message_map <- generate_simple_text(message),
         message_with_type <- Map.merge(message_map, %{"response_type" => type}) do
      message_with_type |> Jason.encode!()
    end
  end

  defp generate_simple_text(message) do
    %{"text" => message}
  end

  defp user_profile_url(service_username) do
    service_username
    |> Service.Constants.user_url()
  end
end
