defmodule MemoryWeb.GamesChannel do
  use MemoryWeb, :channel

  alias Memory.GameServer


  # join and handle_in methods inspired by: http://www.ccs.neu.edu/home/ntuck/courses/2018/09/cs4550/notes/06-channels/games_channel.ex
  # as well as  http://www.ccs.neu.edu/home/ntuck/courses/2018/09/cs4550/notes/07-state/notes.html.
  def join("games:" <> game, payload, socket) do
    if authorized?(payload) do
      socket = assign(socket, :game, game)
      GameServer.add_player(game, socket.assigns[:user])
      view = GameServer.view(game, socket.assigns[:user])
      {:ok, %{"join" => game, "game" => view}, socket}
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
    view = GameServer.guess_card(socket.assigns[:game], socket.assigns[:user], payload)
    broadcast_from! socket, "new_view", view
    {:reply, {:ok, %{ "game" => view}}, socket}
  end

  def handle_in("end_guess", _, socket) do
    view = GameServer.end_guess(socket.assigns[:game], socket.assigns[:user])
    broadcast_from! socket, "new_view", view
    {:reply, {:ok, %{ "game" => view}}, socket}
  end

  def handle_in("reset_game", _, socket) do
    view = GameServer.reset_game(socket.assigns[:game], socket.assigns[:user])
    broadcast_from! socket, "new_view", view
    {:reply, {:ok, %{"game" => view}}, socket}
  end

  # Add authorization logic here as required.
  defp authorized?(_payload) do
    true
  end
end
