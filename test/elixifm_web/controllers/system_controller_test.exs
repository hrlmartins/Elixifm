defmodule ElixifmWeb.SystemControllerTest do
  use ElixifmWeb.ConnCase

  import Mox

  setup_all do
    track = %Elixifm.Track{artist: "Pearl Jam", name: "Ten"}

    Elixifm.PlayingMock
    |> expect(:playing, fn _name -> {:ok, track} end)

    :ok
  end
  setup :verify_on_exit!

  describe "playing/2" do
    test "Returns user playing info when input is valid", %{conn: conn} do
      track = %Elixifm.Track{artist: "Pearl Jam", name: "Ten"}

      # elixifm.playingmock
      # |> expect(:playing, fn _name -> {:ok, track} end)

      response =
        conn
        |> post("/api/playing", text: "micah")
        |> json_response(200)

      expected = %{
        "text" => "_Playing: *Pearl Jam - Ten*_",
        "response_type" => "ephemeral"
      }

      assert response == expected

    end
  end
end
