defmodule DemoWeb.HomeLive.Index do
  use DemoWeb, :live_view

  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  def render(assigns) do
    ~H"""
    hi
    """
  end
end
