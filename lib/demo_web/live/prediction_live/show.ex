defmodule DemoWeb.PredictionLive.Show do
  use DemoWeb, :live_view

  alias Demo.Predictions

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    {:noreply,
     socket
     |> assign(:page_title, page_title(socket.assigns.live_action))
     |> assign(:prediction, Predictions.get_prediction!(id))}
  end

  defp page_title(:show), do: "Show Prediction"
  defp page_title(:edit), do: "Edit Prediction"
end
