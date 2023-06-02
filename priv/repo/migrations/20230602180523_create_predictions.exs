defmodule Demo.Repo.Migrations.CreatePredictions do
  use Ecto.Migration

  def change do
    create table(:predictions) do
      add :prompt, :string

      timestamps()
    end
  end
end
