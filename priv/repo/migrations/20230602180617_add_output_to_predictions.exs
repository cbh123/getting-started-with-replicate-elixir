defmodule Demo.Repo.Migrations.AddOutputToPredictions do
  use Ecto.Migration

  def change do
    alter table(:predictions) do
      add :output, :text
    end
  end
end
