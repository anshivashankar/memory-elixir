import React from 'react';
import ReactDOM from 'react-dom';
import _ from 'lodash';

export default function game_init(root, channel) {
  ReactDOM.render(<Memory channel={channel} />, root);
}


class Memory extends React.Component {

  constructor(props) {
    super(props);

    this.channel = props.channel;
    this.state = { cards: this.resetCards(), numClicks: 0, players: [] };
    this.channel.join()
      .receive("ok", this.gotView.bind(this))
      .receive("error", resp => {console.log("Unable to join", resp)});
  }

  // gotView and sendGuess inspired by: http://www.ccs.neu.edu/home/ntuck/courses/2018/09/cs4550/notes/06-channels/hangman.jsx
  gotView(view) {
    this.setState(view.game);
  }

  sendGuess(id) {
    this.channel.push("guess_card", id)
      .receive("ok", this.gotView.bind(this));
  }

  resetCards() {
    let cards = [];
    let x, y;
    let count = 0;
    for(x = 0; x != 4; x++) {
      for(y = 0; y != 4; y++) {
        cards[count] = { letter: "??", // we don't know the card
                      id: count, // our identifier
                      completed: false,
                      guessed: false};
        count++;
      }
    }
    return cards;
  }

  resetState() {
    this.channel.push("reset_game")
      .receive("ok", this.gotView.bind(this));
  }

  onClickCard(id, index) {
    // do nothing on click if the cards are completed.
    if(this.state.cards[id].completed ||
       this.getNumberOfGuesses() == 2 ||
       this.state.cards[id].guessed) {
      return;
    }
    this.sendGuess(id);
    this.cardMatch(id);
  }

  check_game_over() {
    var gameOver = true
    for (int i = 0; i < 15; i++) {
      var card = this.state.card[id]
      var completed = card.completed;
      gameOver = gameOver && completed
    }

    return gameOver
  }

  getWinner() {
    if (check_game_over) {
      if this.state.scores[0] > this.state.scores[1] {
        return this.state.players[0]
      }
      else if this.state.scores[1] > this.state.scores[0] {
        return this.state.players[1]
      }
      else {
        return "TIE"
      }
    }
    else {
      return "NONE"
    }
  }

  renderWinner() {
    winnerName = this.getWinner()
    if winnerName == "TIE" {
      return
      <h1>
        It's a Tie! You both Win!
      </h1>
    }
    else if winnerName != "NONE" {
      return
      <h1>
        {winnerName} is the winner!
      </h1>
    }
  }


  // sends the "I am done looking" channel push.
  cardMatch(id) {
    let card = this.state.cards[id];
    let matchIndex = this.findGuessed(card);
    if(matchIndex == -1) {
      return; // no other guessed cards, no match.
    }
    let matchCard = this.state.cards[matchIndex];
    setTimeout(
      () => {
        this.channel.push("end_guess")
          .receive("ok", this.gotView.bind(this));
      },1000);
  }

  // if there's a card that's guessed, return its index.
  // if there is no other card that's guessed, return -1.
  findGuessed(card) {
    let i;
    for(i = 0; i != 16; i++) {
      if (this.state.cards[i].guessed == true &&
          !(_.isEqual(this.state.cards[i].id, card.id))) {
        return i;
      }
    }
    return -1;
  }

  getNumberOfGuesses() {
    let guessedCount = 0;
    let i;
    for(i = 0; i != 16; i++) {
      if(this.state.cards[i].guessed == true) {
        guessedCount++;
      }
    }
    return guessedCount;
  }


  renderCard(i) {
    let card = this.state.cards[i];
    return <DisplayCard number={i}
                        card = {card}
                        clickCard={this.onClickCard.bind(this)} />;
  }

  renderPlayer(index) {
    if index < this.state.players.length {
      return
      <span>
        {this.state.players[index]}
      </span>
    }
  }


  render() {
    return (
    <div>
      <div className="column">
        {renderWinner()}
      </div>
      <div>
        Active Players:
        {this.renderPlayer(0)}
        {this.renderPlayer(1)}
      </div>
      <div className="column">
        <button onClick={this.resetState.bind(this)}>Reset</button>
      </div>
      <div className="row">
        <h2>Memory Game</h2>
      </div>
      <div className="row">
        <p>Number of guesses: {this.state.numClicks}</p>
      </div>
      <div className="row">
        {this.renderCard(0)}
        {this.renderCard(1)}
        {this.renderCard(2)}
        {this.renderCard(3)}
      </div>
      <div className="row">
        {this.renderCard(4)}
        {this.renderCard(5)}
        {this.renderCard(6)}
        {this.renderCard(7)}
      </div>
      <div className="row">
        {this.renderCard(8)}
        {this.renderCard(9)}
        {this.renderCard(10)}
        {this.renderCard(11)}
      </div>
      <div className="row">
        {this.renderCard(12)}
        {this.renderCard(13)}
        {this.renderCard(14)}
        {this.renderCard(15)}
      </div>
    </div>
    );
  }
}


// When we display a card, we should use each
function DisplayCard(params) {
  let letter = params.card.letter;
  let flipped = params.card.guessed || params.card.completed;
  let id = params.card.id;
  if(flipped == true) {
  return <button className="buttonAnswer" onClick={() => params.clickCard(id, id)}> [{letter}]  </button>;
  }
  return <button className="buttonGuess" onClick={() => params.clickCard(id, params.number)}> [??] </button>;
}
