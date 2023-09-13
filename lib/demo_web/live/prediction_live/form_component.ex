defmodule DemoWeb.PredictionLive.FormComponent do
  use DemoWeb, :live_component

  alias Demo.Predictions
  alias Demo.Predictions.Prediction

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.simple_form
        for={@form}
        id="prediction-form"
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
      >
        <.input field={@form[:prompt]} type="text" label="Prompt" />
        <:actions>
          <.button phx-disable-with="Saving...">Generate</.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  @impl true
  def update(%{prediction: prediction} = assigns, socket) do
    changeset = Predictions.change_prediction(prediction)

    {:ok,
     socket
     |> assign(assigns)
     |> assign_form(changeset)}
  end

  @impl true
  def handle_event("validate", %{"prediction" => prediction_params}, socket) do
    changeset =
      socket.assigns.prediction
      |> Predictions.change_prediction(prediction_params)
      |> Map.put(:action, :validate)

    {:noreply, assign_form(socket, changeset)}
  end

  def handle_event("save", %{"prediction" => prediction_params}, socket) do
    save_prediction(socket, socket.assigns.action, prediction_params)
  end

  defp save_prediction(socket, _, %{"prompt" => _prompt} = prediction_params) do
    case Predictions.create_prediction(prediction_params) do
      {:ok, prediction} ->
        notify_parent({:saved, prediction})

        {:noreply,
         socket
         |> assign_form(Predictions.change_prediction(%Prediction{}))
         |> put_flash(:info, "Prediction created successfully")}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  defp assign_form(socket, %Ecto.Changeset{} = changeset) do
    assign(socket, :form, to_form(changeset))
  end

  defp(notify_parent(msg), do: send(self(), {__MODULE__, msg}))
end
