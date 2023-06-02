defmodule Demo.Predictions.Prediction do
  use Ecto.Schema
  import Ecto.Changeset

  schema "predictions" do
    field :prompt, :string
    field :output, :string

    timestamps()
  end

  @doc false
  def changeset(prediction, attrs) do
    prediction
    |> cast(attrs, [:prompt, :output])
    |> validate_required([:prompt])
  end
end
