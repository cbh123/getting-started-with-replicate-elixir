defmodule Demo.PredictionsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Demo.Predictions` context.
  """

  @doc """
  Generate a prediction.
  """
  def prediction_fixture(attrs \\ %{}) do
    {:ok, prediction} =
      attrs
      |> Enum.into(%{
        prompt: "some prompt"
      })
      |> Demo.Predictions.create_prediction()

    prediction
  end
end
