defmodule ReplicateWebhooksController do
  use DemoWeb, :controller

  def new(conn, params) do
    handle_webhook(conn, params)

    conn
    |> put_resp_content_type("text/plain")
    |> send_resp(200, "OK")
  end

  def handle_webhook(
        conn,
        %{"status" => status, "prediction_id" => prediction_id, "output" => output} = params
      ) do
    case status do
      "succeeded" ->
        prediction = Demo.Predictions.get_prediction!(prediction_id)

        {:ok, prediction} =
          Demo.Predictions.update_prediction(prediction, %{output: output |> List.first()})

        Phoenix.PubSub.broadcast(Demo.PubSub, "predictions", %{
          event: "succeeded",
          prediction: prediction
        })
    end
  end
end
