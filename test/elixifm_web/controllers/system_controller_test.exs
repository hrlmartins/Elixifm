defmodule ElixifmWeb.SystemControllerTest do
  use ElixifmWeb.ConnCase

  import Mox

  setup :verify_on_exit!

  describe "playing/2" do
    test "Returns user playing info when input is valid", %{conn: conn} do
      track = %Elixifm.Track{artist: "Pearl Jam", name: "Ten"}

      Elixifm.PlayingMock
      |> expect(:playing, fn _name -> {:ok, track} end)

      response =
        conn
        |> post("/api/playing", text: "micah", user_name: "micah")
        |> json_response(200)

      expected = %{
        "text" => "_micah played: *Pearl Jam - Ten*_",
        "response_type" => "in_channel"
      }

      assert response == expected
    end

    test "Returns info message when provided service username is empty", %{conn: conn} do
      response =
        conn
        |> post("/api/playing", text: "", user_name: "micah")
        |> json_response(200)

      expected = %{
        "text" => "_micah played: *Pearl Jam - Ten*_",
        "response_type" => "in_channel"
      }

      assert Map.get(response, "response_type") == "ephemeral"
      assert Map.get(response, "text") |> String.contains?("DANG!")
    end
  end
end
