defmodule Demo.Server do
  @moduledoc """
  GenServer
  """
  use GenServer
  alias Demo.Predictions
  import Demo.ChatSigil

  def start_link(_opts) do
    GenServer.start_link(__MODULE__, %{})
  end

  def init(state) do
    schedule_creation()
    {:ok, state}
  end

  def handle_info(:create, state) do
    if Predictions.count_predictions() < 10 do
      ~x"""
      model: gpt-3.5-turbo
      system: Write a text-to-image prompt for a photo. You love Elixir.
      """
      |> OpenAI.chat_completion()
      |> parse_chat()
      |> gen_image()

      schedule_creation()
    end

    {:noreply, state}
  end

  @doc """
  Generates an image given a prompt. Returns {:ok, url} or {:error, error}.
  """
  def gen_image({:ok, image_prompt}) when is_binary(image_prompt) do
    Logger.info("Generating image for #{image_prompt}")
    model = Replicate.Models.get!("stability-ai/sdxl")
    version = Replicate.Models.get_latest_version!(model)

    {:ok, prediction} = Replicate.Predictions.create(version, %{prompt: image_prompt})
    {:ok, prediction} = Replicate.Predictions.wait(prediction)

    Logger.info("Image generated: #{prediction.output}")

    result = List.first(prediction.output)
  end

  defp schedule_creation() do
    # Every 5 seconds
    Process.send_after(self(), :create, 5000)
  end
end
