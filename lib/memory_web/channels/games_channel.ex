defmodule MemoryWeb.GamesChannel do
  use MemoryWeb, :channel

  def join("games:" <> name, payload, socket) do
    if authorized?(payload) do
      game = Memory.new()
      socket = socket
      |> assign(:game, game)
      |> assign(:name, name)
      {:ok, %{"join"=> name, "game" => Memory.client_view(game)}, socket}
    else
      {:error, %{reason: "unauthorized"}}
    end
  end

  # Channels can be used in a request/response fashion
  # by sending replies to requests from the client
  def handle_in("ping", payload, socket) do
    {:reply, {:ok, payload}, socket}
  end

  # It is also common to receive messages from the client and
  # broadcast to everyone in the current topic (games:lobby).
  # payload should always be a number, the id of the card picked by the client.
  def handle_in("guess_card", payload, socket) do
    game = Memory.guess_card(socket.assigns[:game], payload)
    socket = assign(socket, :game, game)
    {:reply, {:ok, %{ "game" => Memory.client_view(game)}}, socket}
    #broadcast socket, "shout", payload
    #{:noreply, socket}
  end

  def handle_in("end_guess", payload, socket) do
    game = Memory.end_guess(socket.assigns[:game])
    socket = assign(socket, :game, game)
    {:reply, {:ok, %{ "game" => Memory.client_view(game)}}, socket}
  end

  # Add authorization logic here as required.
  defp authorized?(_payload) do
    true
  end
end
