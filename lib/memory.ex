# Inspired by: http://www.ccs.neu.edu/home/ntuck/courses/2018/09/cs4550/notes/06-channels/game.ex
defmodule Memory do
  def new do
    %{
      cards: resetCards(),
      numClicks: 0,
    }
  end

  # returns a shuffled list of cards.
  # we define a card as a tuple of: letter, id, completed, and guessed.
  def resetCards() do
    letters = ["A", "A", "B", "B", "C", "C", "D", "D", "E", "E", "F", "F", "G", "G", "H", "H"]
    # instead of pos, we're using id as our identifier. Turns out we dont need pos to render.
    resetCardsHelp([], 0, letters)
  end

  # return a list of cards.
  def resetCardsHelp(cardsAcc, id, letters) do
    cond do
      # only return when we're out of letters.
      length(letters) == 0 -> Enum.to_list(Enum.shuffle(cardsAcc))
      true -> 
        card = %{letter: List.first(letters),
                id: id,
                completed: false,
                guessed: false}
        resetCardsHelp([card] ++ cardsAcc, id + 1, tl(letters))
    end
  end

  def client_view(game) do
    cards = game.cards
    clicks = game.numClicks
    # here we pass only what the client needs to know.
    # in this case, we'll only specify:
    # numClicks (ofc)
    # cardsFound (list of cards)
    # cardsGuessed (can only be two)
    # the board should be able to see these. The cards themselves are the only hidden thing.
    %{
      cards: cards,
      numClicks: clicks
    }
  end
end
