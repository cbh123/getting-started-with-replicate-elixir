defmodule DemoWeb.PredictionLive.FormComponent do
  use DemoWeb, :live_component

  alias Demo.Predictions

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.header>
        <%= @title %>
        <:subtitle>Use this form to manage prediction records in your database.</:subtitle>
      </.header>

      <.simple_form
        for={@form}
        id="prediction-form"
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
      >
        <.input field={@form[:prompt]} type="text" label="Prompt" />
        <:actions>
          <.button phx-disable-with="Saving...">Save Prediction</.button>
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

  defp save_prediction(socket, :edit, prediction_params) do
    case Predictions.update_prediction(socket.assigns.prediction, prediction_params) do
      {:ok, prediction} ->
        notify_parent({:saved, prediction})

        {:noreply,
         socket
         |> put_flash(:info, "Prediction updated successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  defp save_prediction(socket, :new, %{"prompt" => prompt} = prediction_params) do
    case Predictions.create_prediction(prediction_params)
         |> IO.inspect(label: "creation result") do
      {:ok, prediction} ->
        {:ok, _prediction} =
          Replicate.Predictions.create(
            "stability-ai/stable-diffusion:db21e45d3f7023abc2a46ee38a23973f6dce16bb082a930b0c49861f96d1e5bf",
            %{prompt: "a 19th century portrait of a wombat gentleman"},
            "https://a889-2600-4041-5bf9-9900-a9c4-ae5f-c851-7d45.ngrok-free.app/replicate/webhooks?prediction_id=#{prediction.id}"
          )

        notify_parent({:saved, prediction})

        {:noreply,
         socket
         |> put_flash(:info, "Prediction created successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  defp assign_form(socket, %Ecto.Changeset{} = changeset) do
    assign(socket, :form, to_form(changeset))
  end

  defp notify_parent(msg), do: send(self(), {__MODULE__, msg})
end
