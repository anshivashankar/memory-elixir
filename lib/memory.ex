# functions new, client_view, and guess_card Inspired by: http://www.ccs.neu.edu/home/ntuck/courses/2018/09/cs4550/notes/06-channels/game.ex
defmodule Memory do
  def new do
    %{
      cards: resetCards(),
      numClicks: 0,
      players, %{},
      pickTurn, "",
    }
  end

  def new(players) do
    players = Enum.map players, fn {name, info} ->
      {name, %{ default_player() | score: info.score || 0}}
    end
    Map.put(new(), :players, Enum.into(players, %{}))
  end

  def default_player() do
    %{
      score: 0,
    }
  end



  # returns a shuffled list of cards.
  # we define a card as a dictionary of: letter, id, completed, and guessed.
  def resetCards() do
    letters = ["A", "A", "B", "B", "C", "C", "D", "D", "E", "E", "F", "F", "G", "G", "H", "H"]
    letters = Enum.shuffle(letters)
    # instead of pos, we're using id as our identifier. Turns out we dont need pos to render.
    resetCardsHelp([], 15, letters)
  end

  # return a list of cards, where each card is a dictionary.
  def resetCardsHelp(cardsAcc, id, letters) do
    cond do
      # only return when we're out of letters.
      length(letters) == 0 -> Enum.to_list(cardsAcc)
      true -> 
        card = %{letter: List.first(letters),
                id: id,
                completed: false,
                guessed: false}
        resetCardsHelp([card] ++ cardsAcc, id - 1, tl(letters))
    end
  end

  def client_view(game, user) do
    cards = game.cards
    clicks = game.numClicks
    players = game.players # just send the player list to the client. We can display it later.
    %{
      cards: cards_viewable(cards),
      numClicks: clicks,
      players: players,
    }
  end

  defp cards_viewable(cards) do
    Enum.map cards, fn (card) ->
      if card.completed || card.guessed do
        card
      else 
        %{letter: "??",
        id: card.id,
        completed: false,
        guessed: false,}
      end
    end
  end

  # handles the guessing of a card. Takes in only the ID and game so that the client cant cheat.
  # If two cards have the same letter, update them to be completed.
  def guess_card(game, id) do
    if num_guessed(game.cards, 0) >= 2 do
      # dont do anything if they try to guess more than 2 cards.
      game
    else
      update_guess(game, id)
      |> check_completed(id)
    end
  end

  # returns the number of guessed cards. 
  defp num_guessed(cards, numGuessed) do
    cond do
      Enum.count(cards) == 0 -> numGuessed
      hd(cards).guessed -> num_guessed(tl(cards), numGuessed + 1)
      true -> num_guessed(tl(cards), numGuessed)
    end
  end

  # returns the number of completed cards. 
  defp num_completed(cards, numCompleted) do
    cond do
      Enum.count(cards) == 0 -> numCompleted
      hd(cards).completed -> num_completed(tl(cards), numCompleted + 1)
      true -> num_completed(tl(cards), numCompleted)
    end
  end

  # set all guessed to false. 
  def end_guess(game) do
    cards = Enum.map game.cards, fn(card) ->
      %{letter: card.letter,
      id: card.id,
      completed: card.completed,
      guessed: false,}
    end
    Map.put(game, :cards, cards)
  end

  # reset the game.
  def reset_game() do
    %{
      cards: resetCards(),
      numClicks: 0
    }
  end

  defp update_guess(game, id) do
      numClicks = game.numClicks + 1
      gs = MapSet.new(game.cards)
      |> MapSet.to_list
      newCards = find_guessed_card(id, gs)
      |> Enum.sort(&(&1.id < &2.id))
      newGame = Map.put(game, :cards, newCards)
      # Update the number of clicks with numClicks.
      Map.put(newGame, :numClicks, numClicks)
  end

  # returns the updated game if the two are a match.
  defp check_completed(game, id) do
    thisCard = Enum.at(game.cards, id)
    newGame = game
    #IO.inspect(game)
    # if the match is found, update it.
    newCards = Enum.map game.cards, fn(card) ->
      cond do
        card.id != id and card.guessed and card.letter == thisCard.letter ->
          %{letter: card.letter,
          id: card.id,
          completed: true,
          guessed: card.guessed}
        true -> card
      end
    end
    cond do
      rem(num_completed(newCards, 0), 2) == 1 -> 
        Map.put(newGame, :cards, List.replace_at(newCards, id,
          %{letter: thisCard.letter,
            id: thisCard.id,
            completed: true,
            guessed: thisCard.guessed}))
      true -> game
    end
  end

  # returns the list of cards with the card set to guessed.
  defp find_guessed_card(id, cards) do
    if hd(cards).id == id do
      [set_guessed(hd(cards))] ++ tl(cards)
    else
      newCards = find_guessed_card(id, tl(cards))
      [hd(cards)] ++ newCards
    end
  end

  defp set_guessed(card) do
    %{letter: card.letter,
    id: card.id,
    completed: card.completed,
    guessed: true}
  end
end
