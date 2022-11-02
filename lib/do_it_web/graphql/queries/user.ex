defmodule DoItWeb.Graphql.Queries.User do
  use Absinthe.Schema.Notation

  alias DoIt.Accounts.Accounts

  def get_all_users(_parent, args, context) do
    with {:auth, %{context: %{current_user: _user}}} <- {:auth, context},
         {:users, users} <- {:users, Accounts.list_all_users(args)} do

      {:ok, %{users: users, total: length(Accounts.list_users()), success: true}}
    else
      {:auth, _} ->
        {:error, "You must be authenticated!"}

      {:users, _} ->
        {:error, "Empty Record"}
    end
  end
end
