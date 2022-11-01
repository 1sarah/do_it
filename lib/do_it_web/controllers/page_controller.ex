defmodule DoItWeb.PageController do
  use DoItWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
