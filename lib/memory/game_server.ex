# Inspired by: http://www.ccs.neu.edu/home/ntuck/courses/2018/09/cs4550/notes/09-two-players/game_server.ex
defmodule Memory.GameServer do
  use GenServer

  ## Client Interface

  def start_link(_args) do
    GenServer.start_link(__MODULE__, %{}, name: __MODULE__)
  end

  def view(game, user) do
    GenServer.call(__MODULE__, {:view, game, user})
  end

  def guess_card(game, user, payload) do
    GenServer.call(__MODULE__, {:guess_card, game, user, payload})
  end


  def end_guess(game, user) do
    GenServer.call(__MODULE__, {:end_guess, game, user})
  end

  def reset_game(game, user) do
    GenServer.call(__MODULE__, {:reset_game, game, user})
  end

  def add_player(game, user) do
    GenServer.cast(__MODULE__, {:add_player, game, user})
  end

  ## Implementation

  def init(state) do
    {:ok, state}
  end

  def handle_call({:view, gameName, user}, _from, state) do
    newGame = Map.get(state, gameName, Memory.new)
    {:reply, Memory.client_view(newGame, user), Map.put(state, gameName, newGame)}
  end

  def handle_call({:guess_card, gameName, user, payload}, _from, state) do
    newGame = Map.get(state, gameName, Memory.new)
    newGame = Memory.guess_card(newGame, user, payload)
    newView = Memory.client_view(newGame, user)
    {:reply, newView, Map.put(state, gameName, newGame)}
  end

  def handle_call({:end_guess, gameName, user}, _from, state) do
    newGame = Map.get(state, gameName, Memory.new)
    |> Memory.end_guess(user)
    newView = Memory.client_view(newGame, user)
    {:reply, newView, Map.put(state, gameName, newGame)}
  end

  def handle_call({:reset_game, gameName, user}, _from, state) do
    newGame = Map.get(state, gameName, Memory.new).players
    |> Memory.reset_game
    newView = Memory.client_view(newGame, user)
    {:reply, newView, Map.put(state, gameName, newGame)}
  end

  def handle_cast({:add_player, gameName, user}, state) do
    newGame = Map.get(state, gameName, Memory.new)
    players = newGame.players
    if length(players) >= 2 or user in players do
      # we already have two players, dont add.
      {:noreply, state}
    else
      newGame = Map.put(newGame, :players, players ++ [user])
      {:noreply, Map.put(state, gameName, newGame)}
    end
  end
end
