defmodule MemoryWeb.PageController do
  use MemoryWeb, :controller

  def index(conn, _params) do
    render conn, "index.html"
  end

  # Join function inspired by: http://www.ccs.neu.edu/home/ntuck/courses/2018/09/cs4550/notes/09-two-players/notes.html
  def join(conn, %{"join" => %{"user" => user, "game" => game}}) do
    conn
    |> put_session(:user, user)
    |> redirect(to: "/game/#{game}")
  end

  # Inspired by http://www.ccs.neu.edu/home/ntuck/courses/2018/09/cs4550/notes/06-channels/notes.html
  # Edits inspired by: http://www.ccs.neu.edu/home/ntuck/courses/2018/09/cs4550/notes/09-two-players/notes.html
  def game(conn, params) do
    user = get_session(conn, :user)
    if user do
      render conn, "game.html", game: params["game"], user: user
    else
      conn
      |> put_flash(:error, "Must pick a username")
      |> redirect(to: "/")
    end
  end
end
