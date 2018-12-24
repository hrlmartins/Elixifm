defmodule Elixifm.Services.LastFmTest do
  use ExUnit.Case, async: true

  setup do
    bypass = Bypass.open(port: 8000)
    {:ok, bypass: bypass}
  end

  test "Returns a Track with a correct server response", %{bypass: bypass} do
    Bypass.expect_once(bypass, "GET", "/", fn conn ->
      Plug.Conn.resp(conn, 200, ~s<{
        "recenttracks": {
          "track": [{
              "artist": {
                "#text": "Pearl Jam"
              },
              "name": "Ten"
            }
          ]
        }
    }>)
    end)

    assert {:ok, %Elixifm.Track{artist: "Pearl Jam", name: "Ten"}} ==
             Elixifm.Services.LastFm.playing("someone")
  end
end
