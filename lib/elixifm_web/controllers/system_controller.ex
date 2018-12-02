defmodule ElixifmWeb.SystemController do
  use ElixifmWeb, :controller

  import Ecto

  @auth_base_url "https://accounts.spotify.com/authorize"

  def playing(conn, %{"text" => input} = params) do
    # TODO Something here
    # conn |> IO.inspect(label: CONNECTION)
    # IO.puts('\n')
    # params |> IO.inspect(label: PARAMS)

    with trimed_input <- input |> String.trim(),
         {:ok, response} <- process_request(trimed_input, params) do

      IO.inspect response
      conn
      |> put_resp_content_type("application/json")
      |> send_resp(200, response)
    else
      ## TODO build error response
      err -> conn |> send_resp(500, "Erro!!")
    end
  end

  defp process_request("register", params) do
    with session <- generate_session(),
         :ok <- save_session(session, params),
         auth_url <- generate_authentication_url(session),
         message <- generate_registration_message(auth_url),
         response <- generate_slack_response(message) do
      {:ok, response}
    else
      err -> {:err, "Unable to generate authorization link"}
    end
  end

  defp process_request(input, params) do
    ## TODO Unknown command response
    {:ok, ""}
  end

  defp generate_session() do
    Ecto.UUID.generate()
  end

  defp save_session(session, %{"user_id" => user_id} = params) do
    case :ets.insert(:user_session, {session, user_id}) do
      true -> :ok
      false -> :err
    end
  end

  defp generate_authentication_url(session) do
    redirect_url = "example.com/" <> session
    @auth_base_url <> "?" <> URI.encode_query(%{"redirect_url" => redirect_url})
  end

  defp generate_registration_message(url) do
    "Follow the provided url to connect your account: " <> url
  end

  defp generate_slack_response(text) do
    %{"text" => text} |> Jason.encode!()
  end
end
