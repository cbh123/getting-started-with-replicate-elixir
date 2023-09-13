defmodule DemoWeb.PredictionLive.Index do
  use DemoWeb, :live_view

  alias Demo.Predictions
  alias Demo.Predictions.Prediction

  @model "stability-ai/stable-diffusion:db21e45d3f7023abc2a46ee38a23973f6dce16bb082a930b0c49861f96d1e5bf"

  @impl true
  def mount(_params, _session, socket) do
    {:ok, stream(socket, :predictions, Predictions.list_predictions())}
  end

  @impl true
  def handle_info({DemoWeb.PredictionLive.FormComponent, {:saved, prediction}}, socket) do
    Task.async(fn ->
      gen_image(prediction.id, prediction.prompt)
    end)

    {:noreply, socket |> stream_insert(:predictions, prediction, at: 0)}
  end

  def handle_info(
        {ref, %{id: id, output: [image | _]}},
        socket
      ) do
    Process.demonitor(ref, [:flush])
    {:ok, prediction} = update_prediction(id, image)
    {:noreply, socket |> stream_insert(:predictions, prediction)}
  end

  def handle_info({ref, %{id: id, output: nil}}, socket) do
    Process.demonitor(ref, [:flush])
    {:ok, prediction} = update_prediction(id, "Failed")

    {:noreply,
     socket
     |> stream_insert(:predictions, prediction)
     |> put_flash(:error, "Prediction failed. Likely detected NSFW input. Try again")}
  end

  defp gen_image(id, prompt) do
    output = Replicate.run(@model, prompt: prompt)
    %{id: id, output: output}
  end

  defp update_prediction(id, image) do
    id
    |> Predictions.get_prediction!()
    |> Predictions.update_prediction(%{output: image})
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Predictions")
    |> assign(:prediction, %Prediction{})
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    prediction = Predictions.get_prediction!(id)
    {:ok, _} = Predictions.delete_prediction(prediction)

    {:noreply, stream_delete(socket, :predictions, prediction)}
  end
end
