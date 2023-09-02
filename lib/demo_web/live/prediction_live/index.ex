defmodule DemoWeb.PredictionLive.Index do
  use DemoWeb, :live_view

  alias Demo.Predictions
  alias Demo.Predictions.Prediction
  alias DemoWeb.Endpoint
  alias Replicate.Models

  @model "stability-ai/stable-diffusion:db21e45d3f7023abc2a46ee38a23973f6dce16bb082a930b0c49861f96d1e5bf"

  @impl true
  def mount(_params, _session, socket) do
    if connected?(socket), do: Phoenix.PubSub.subscribe(Demo.PubSub, "predictions")
    {:ok, stream(socket, :predictions, Predictions.list_predictions()) |> assign(running: false)}
  end

  def handle_info({DemoWeb.PredictionLive.FormComponent, {:saved, prediction}}, socket) do
    Task.async(fn ->
      run_prediction(prediction)
    end)

    {:noreply, socket |> stream_insert(:predictions, prediction, at: 0)}
  end

  def handle_info({ref, {:ok, %{output: [image | _]} = prediction}}, socket) do
    Process.demonitor(ref, [:flush])

    {:ok, prediction} =
      prediction.input["id"]
      |> Predictions.get_prediction!()
      |> Predictions.update_prediction(%{output: image})

    {:noreply, socket |> stream_insert(:predictions, prediction, at: 0)}
  end

  def handle_info(%{event: "succeeded", prediction: prediction}, socket) do
    {:noreply, stream_insert(socket, :predictions, prediction, at: 0)}
  end

  defp run_prediction(%{id: id, prompt: prompt}) do
    model = Models.get!("stability-ai/stable-diffusion")
    version = Models.get_latest_version!(model)
    {:ok, prediction} = Replicate.Predictions.create(version, %{prompt: prompt, id: id})

    Replicate.Predictions.wait(prediction)
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Prediction")
    |> assign(:prediction, Predictions.get_prediction!(id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Prediction")
    |> assign(:prediction, %Prediction{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Predictions")
    |> assign(:prediction, nil)
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    prediction = Predictions.get_prediction!(id)
    {:ok, _} = Predictions.delete_prediction(prediction)

    {:noreply, stream_delete(socket, :predictions, prediction)}
  end
end
