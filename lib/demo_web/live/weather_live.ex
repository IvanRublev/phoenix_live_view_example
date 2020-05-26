defmodule DemoWeb.WeatherLive do
  use Phoenix.LiveView

  def render(assigns) do
    ~L"""
    <div>
      <form phx-submit="set-location">
        <input name="location" placeholder="Location" value="<%= @location %>"/>
        <%= @weather %>
      </form>
      <form phx-submit="show_flashes"><button type="submit">Show flashes</button></form>
    </div>
    """
  end

  def mount(_params, _session, socket) do
    send(self(), {:put, "Austin"})
    {:ok, assign(socket, location: nil, weather: "...")}
  end

  def handle_event("show_flashes", _args, socket) do
    {
      :noreply,
      socket
      |> put_flash(:error, "Still have the error.")
      |> redirect(to: "/")
    }
  end

  def handle_event("set-location", %{"location" => location}, socket) do
    {:noreply, put_location(socket, location)}
  end

  def handle_info({:put, location}, socket) do
    {:noreply, put_location(socket, location)}
  end

  defp put_location(socket, location) do
    assign(socket, location: location, weather: weather(location))
  end

  defp weather(local) do
    {:ok, {{_, 200, _}, _, body}} =
      :httpc.request(:get, {~c"http://wttr.in/#{URI.encode(local)}?format=1", []}, [], [])
    IO.iodata_to_binary(body)
  end
end
