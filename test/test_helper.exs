ExUnit.start()
Mox.defmock(Elixifm.PlayingMock, for: Elixifm.Playing)
Application.ensure_all_started(:bypass)
