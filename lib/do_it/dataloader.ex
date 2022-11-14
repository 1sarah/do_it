defmodule DoIt.Loaddata do
  use Absinthe.Schema.Notation


  alias DoIt.Accounts.User

  import Ecto.Query

  def data() do
    Dataloader.Ecto.new(DoIt.Repo, query: &query/2)
  end

  def query(User, %{scope: :user}) do
    User |> where([o], is_nil(o.deleted_at))
  end
end
