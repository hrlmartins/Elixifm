defmodule Elixifm.Playing do
  @callback playing(String.t()) ::
              {:ok, %Elixifm.Track{}}
              | {:err, String.t()}
              | {:app_error, String.t()}
              | {:empty, String.t()}
end
