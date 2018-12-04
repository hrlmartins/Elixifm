defmodule ElixifmWeb.SystemController do
  use ElixifmWeb, :controller

  alias Elixifm.Slack.Responses

  @auth_base_url "https://accounts.spotify.com/authorize"
  @elixifm_base_url Confex.fetch_env!(:elixifm, :base_url)
  @elixifm_auth_callback Confex.fetch_env!(:elixifm, :auth_callback_path)
  @service_id Confex.fetch_env!(:elixifm, :service_access_id)

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

  defp process_request("register", params) do
    with session <- generate_session(),
         :ok <- save_session(session, params),
         auth_url <- generate_authentication_url(session),
         message <- generate_registration_message(auth_url) do
      {:ok, message}
    else
     _ -> {:err, "Unable to generate authorization link"}
    end
  end

  defp process_request(_input, _params) do
    ## TODO Unknown command response
    {:ok, ""}
  end

  defp generate_session() do
    Ecto.UUID.generate()
  end

  defp save_session(session, %{"user_id" => user_id} = _params) do
    case :ets.insert(:user_session, {session, user_id}) do
      true -> :ok
      false -> :err
    end
  end

  defp generate_authentication_url(session) do
    with params_map <- build_request_param(session) do
      @auth_base_url <> "?" <> URI.encode_query(params_map)
    end
  end

  defp build_request_param(session) do
    %{
      "client_id"     => @service_id,
      "response_type" => "code",
      "redirect_url"  => @elixifm_base_url <> @elixifm_auth_callback,
      "state"         => session
    }
  end

  defp generate_registration_message(url) do
    with message <- "Follow the provided url to connect your account: " <> url do
      Responses.generate_private_message(message)
    end
  end
end
