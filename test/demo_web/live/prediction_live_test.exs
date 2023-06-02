defmodule DemoWeb.PredictionLiveTest do
  use DemoWeb.ConnCase

  import Phoenix.LiveViewTest
  import Demo.PredictionsFixtures

  @create_attrs %{prompt: "some prompt"}
  @update_attrs %{prompt: "some updated prompt"}
  @invalid_attrs %{prompt: nil}

  defp create_prediction(_) do
    prediction = prediction_fixture()
    %{prediction: prediction}
  end

  describe "Index" do
    setup [:create_prediction]

    test "lists all predictions", %{conn: conn, prediction: prediction} do
      {:ok, _index_live, html} = live(conn, ~p"/predictions")

      assert html =~ "Listing Predictions"
      assert html =~ prediction.prompt
    end

    test "saves new prediction", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, ~p"/predictions")

      assert index_live |> element("a", "New Prediction") |> render_click() =~
               "New Prediction"

      assert_patch(index_live, ~p"/predictions/new")

      assert index_live
             |> form("#prediction-form", prediction: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert index_live
             |> form("#prediction-form", prediction: @create_attrs)
             |> render_submit()

      assert_patch(index_live, ~p"/predictions")

      html = render(index_live)
      assert html =~ "Prediction created successfully"
      assert html =~ "some prompt"
    end

    test "updates prediction in listing", %{conn: conn, prediction: prediction} do
      {:ok, index_live, _html} = live(conn, ~p"/predictions")

      assert index_live |> element("#predictions-#{prediction.id} a", "Edit") |> render_click() =~
               "Edit Prediction"

      assert_patch(index_live, ~p"/predictions/#{prediction}/edit")

      assert index_live
             |> form("#prediction-form", prediction: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert index_live
             |> form("#prediction-form", prediction: @update_attrs)
             |> render_submit()

      assert_patch(index_live, ~p"/predictions")

      html = render(index_live)
      assert html =~ "Prediction updated successfully"
      assert html =~ "some updated prompt"
    end

    test "deletes prediction in listing", %{conn: conn, prediction: prediction} do
      {:ok, index_live, _html} = live(conn, ~p"/predictions")

      assert index_live |> element("#predictions-#{prediction.id} a", "Delete") |> render_click()
      refute has_element?(index_live, "#predictions-#{prediction.id}")
    end
  end

  describe "Show" do
    setup [:create_prediction]

    test "displays prediction", %{conn: conn, prediction: prediction} do
      {:ok, _show_live, html} = live(conn, ~p"/predictions/#{prediction}")

      assert html =~ "Show Prediction"
      assert html =~ prediction.prompt
    end

    test "updates prediction within modal", %{conn: conn, prediction: prediction} do
      {:ok, show_live, _html} = live(conn, ~p"/predictions/#{prediction}")

      assert show_live |> element("a", "Edit") |> render_click() =~
               "Edit Prediction"

      assert_patch(show_live, ~p"/predictions/#{prediction}/show/edit")

      assert show_live
             |> form("#prediction-form", prediction: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert show_live
             |> form("#prediction-form", prediction: @update_attrs)
             |> render_submit()

      assert_patch(show_live, ~p"/predictions/#{prediction}")

      html = render(show_live)
      assert html =~ "Prediction updated successfully"
      assert html =~ "some updated prompt"
    end
  end
end
