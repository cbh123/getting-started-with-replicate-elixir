defmodule Demo.Repo.Migrations.AddUuid do
  use Ecto.Migration

  def change do
    alter table(:predictions) do
      add :uuid, :string
    end
  end
end
