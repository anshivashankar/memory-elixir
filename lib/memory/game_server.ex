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

  ## Implementation

  def init(state) do
    {:ok, state}
  end

  def handle_call({:view, game, user}, _from, state) do
    newGame = Map.get(state, game, Memory.new)
    {:reply, Memory.client_view(game, user), Map.put(state, game, newGame)}
  end

  def handle_call({:guess_card, game, user, payload}, _from, state) do
    newGame = Map.get(State, game, Memory.new)
    |>  Memory.guess_card(user, payload)
    newView = Memory.client_view(newGame, user)
    {:reply, newView, Map.put(state, game, newGame)}
  end

  def handle_call({:end_guess, game, user}, _from, state) do
    newGame = Map.get(state, game, Memory.new)
    |> Memory.end_guess(user)
    newView = Memory.client_view(newGame, user)
    {:reply, newView, Map.put(state, game, newGame)}
  end

  def handle_call({:reset_game, game, user}, _from, state) do
    newGame = Memory.reset_game()
    newView = Memory.client_view(newGame, user)
    {:reply, newView, Map.put(state, game, newGame)}
  end
end
