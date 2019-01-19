defmodule ElixifmWeb.SystemControllerTest do
  use ElixifmWeb.ConnCase

  import Mox

  setup :verify_on_exit!

  describe "playing/2" do
    test "Returns user playing info when input is valid", %{conn: conn} do
      track = %Elixifm.Track{artist: "Pearl Jam", name: "Ten", playing: false}

      Elixifm.PlayingMock
      |> expect(:playing, fn _name -> {:ok, track} end)

      response =
        conn
        |> post("/api/playing", text: "micah", user_name: "micah")
        |> json_response(200)

      user_url =
        "micah"
        |> Service.Constants.user_url()

      expected = %{
        "text" => "<#{user_url}|@micah> last played: *Pearl Jam - Ten*",
        "response_type" => "in_channel"
      }

      assert response == expected
    end

    test "Returns user playing info when input is valid and music is playing", %{conn: conn} do
      track = %Elixifm.Track{artist: "Pearl Jam", name: "Ten", playing: true}

      Elixifm.PlayingMock
      |> expect(:playing, fn _name -> {:ok, track} end)

      response =
        conn
        |> post("/api/playing", text: "micah", user_name: "micah")
        |> json_response(200)

      user_url =
        "micah"
        |> Service.Constants.user_url()

      expected = %{
        "text" => "<#{user_url}|@micah> is playing: *Pearl Jam - Ten*",
        "response_type" => "in_channel"
      }

      assert response == expected
    end

    test "Returns info message when provided service username is empty", %{conn: conn} do
      response =
        conn
        |> post("/api/playing", text: "", user_name: "micah")
        |> json_response(200)

      assert Map.get(response, "response_type") == "ephemeral"
      assert Map.get(response, "text") |> String.contains?("DANG!")
    end

    test "Returns an info message when an application error happens", %{conn: conn} do
      Elixifm.PlayingMock
      |> expect(:playing, fn _name -> {:app_error, "User not found"} end)

      expected = %{
        "text" => "oh oh! Your request failed: User not found",
        "response_type" => "ephemeral"
      }

      response =
        conn
        |> post("/api/playing", text: "johndoe", user_name: "micah")
        |> json_response(200)

      assert response == expected
    end

    test "Returns 'no tracks played' when the service returns an empty list of tracks", %{
      conn: conn
    } do
      Elixifm.PlayingMock
      |> expect(:playing, fn _name -> {:empty, "No tracks"} end)

      expected = %{
        "text" => "That user has no played tracks!",
        "response_type" => "ephemeral"
      }

      response =
        conn
        |> post("/api/playing", text: "userwithnotracks", user_name: "micah")
        |> json_response(200)

      assert response == expected
    end
  end
end
