defmodule Elixifm.Repo.Migrations.CreateUsers do
  use Ecto.Migration

  def change do
    create table(:users) do
      add :slack_id, :string
      add :service_token, :string

      timestamps()
    end

    create unique_index(:users, [:slack_id])
  end
end
