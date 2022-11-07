defmodule DoIt.Accounts do
  @moduledoc """
  The Accounts context.
  """

  import Ecto.Query, warn: false
  import Ecto.Changeset
  alias DoIt.Repo

  alias DoIt.Accounts.User

  @doc """
  Returns the list of users.

  ## Examples

      iex> list_users()
      [%User{}, ...]

  """
  def list_users do
    Repo.all(User)
  end

  def list_all_users(args) do
    args
    |> Enum.reduce(User, fn
      {:order, order}, query ->
        query |> order_by({^order, :inserted_at})

      {:filter, filter}, query ->
        query |> filter_with(filter)
    end)
    |> Repo.all()
  end

  def with_value(query \\ base(), value) do
    query
    |> where([u], u.username == ^value)
  end


  def get_user_by_value(value) do
    case with_value(value)
         |> Repo.one() do
      nil -> {:error, "User not found"}
      val -> {:ok, val}
         end
        end

  @doc """
  Gets a single user.

  Raises `Ecto.NoResultsError` if the User does not exist.

  ## Examples

      iex> get_user!(123)
      %User{}

      iex> get_user!(456)
      ** (Ecto.NoResultsError)

  """
  def get_user!(id), do: Repo.get!(User, id)

  @doc """
  Creates a user.

  ## Examples

      iex> create_user(%{field: value})
      {:ok, %User{}}

      iex> create_user(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_user(attrs \\ %{}) do
    %User{}
    |> User.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a user.

  ## Examples

      iex> update_user(user, %{field: new_value})
      {:ok, %User{}}

      iex> update_user(user, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_user(%User{} = user, attrs) do
    user
    |> User.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a user.

  ## Examples

      iex> delete_user(user)
      {:ok, %User{}}

      iex> delete_user(user)
      {:error, %Ecto.Changeset{}}

  """
  def delete_user(%User{} = user) do
    Repo.delete(user)
  end


  defp filter_with(query, filter) do
    Enum.reduce(filter, query, fn
      {:name, name}, query ->
        from(q in query, where: ilike(q.name, ^"%#{name}%"))

      {:username, username}, query ->
        from(q in query, where: ilike(q.username, ^"%#{username}%"))

      {:id, id}, query ->
        from(q in query, where: q.id == ^id)

      {:email, email}, query ->
        from(q in query, where: ilike(q.email, ^"%#{email}%"))

      {:offset, offset}, query ->
        query |> offset(^"#{offset}")

      {:limit, limit}, query ->
        query |> limit(^"#{limit}")
    end)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking user changes.

  ## Examples

      iex> change_user(user)
      %Ecto.Changeset{data: %User{}}

  """
  def change_user(%User{} = user, attrs \\ %{}) do
    User.changeset(user, attrs)
  end


  def put_password_hash(%Ecto.Changeset{valid?: true, changes: %{password: password}} = changeset) do
    change(changeset, password: Argon2.hash_pwd_salt(password))
  end

  def put_password_hash(changeset), do: changeset

  @doc """
  User repo
  """
  def base do
    from(_ in DoIt.Accounts.User, as: :users)
  end


end
