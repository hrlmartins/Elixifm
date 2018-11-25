defmodule Elixifm.User do
  use Ecto.Schema
  import Ecto.Changeset

  schema "users" do
    field :service_token, :string
    field :slack_id, :string

    timestamps()
  end

  @doc false
  def changeset(user, attrs) do
    user
    |> cast(attrs, [:slack_id, :service_token])
    |> validate_required([:slack_id, :service_token])
    |> unique_constraint(:slack_id)
  end
end
