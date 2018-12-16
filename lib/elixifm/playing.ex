defmodule Elixifm.Playing do
  @callback playing(String.t) :: {:ok, %Elixifm.Track{}} | {:err, String.t}
end
