defmodule DoItWeb.Graphql.Resolvers.User do
  use Absinthe.Schema.Notation
  alias DoIt.Accounts

  def login(%{user_login: %{password: password, username: username}}, _resolution) do
    with {:check_login_limit, :allow} <-
           {:check_login_limit, DoItWeb.Graphql.Utils.Util.check_rate(username)},
         {:user, {:ok, getUser}} <- {:user, username |> Accounts.get_user_by_value()},
         {:check_user_active, true} <-
           {:check_user_active, getUser.active},
         {:verify, true} <- {:verify, Argon2.verify_pass(password, getUser.password)} do
      userRet = %{
        username: getUser.username,
        id: getUser.id,
        message: "Login Successful!"
      }

      {:ok, userRet}

      {:ok, token, _} =
        DoIt.Guardian.encode_and_sign(userRet, [typ: "otp"], ttl: {10, :minutes})

      {:ok, Map.put_new(userRet, :token, token)}
    else
      {:user, _} ->
        {:error, "User not found"}

      {:check_login_limit, _} ->
        {:error, %{message: "Sorry your account is locked"}}

        {:check_user_active, _} ->
          {:error, "Account disabled, please contact system admin"}

      {:verify, _} ->
        {:error, "invalid username/password"}

      {:server, _} ->
        {:error, "Unable to start otp server. Contact system admin"}
    end
  end

  def get_all_users(_parent, args, context) do
    # with {:auth, %{context: %{current_user: _user}}} <- {:auth, context},
    with {:users, users} <- {:users, Accounts.list_all_users(args)} do
      {:ok, %{users: users, total: length(Accounts.list_users()), success: true}}
    else
      # {:auth, _} ->
      #   {:error, "You must be authenticated!"}

      {:users, _} ->
        {:error, "Empty Record"}
    end
  end

  def create_user(_parent, args, _context) do
    user_details = %{
      password: "2020@ien",
      username: args.user.username,
      email: args.user.email,
      age: 14,
      phone_number: "0754632145",
      gender: to_string(args.user.gender),

    }
    with {:createuser, {:ok, _user}} <- {:createuser, Accounts.create_user(user_details)} do
      {:ok, %{message: "User created succesfully", success: true}}
    else
      # {:auth, _} ->
      #   {:error, "You must be authenticated!"}

      {:createuser, {:error, %Ecto.Changeset{} = changeset}} ->
        {:error, changeset}
    end
  end

  def get_userInfo(_parent, _args, context) do
    with {:auth, %{context: %{current_user: user}}} <- {:auth, context} do
      {:ok, user.resource}
    else
      {:auth, _} ->
        {:error, "You need to auth to use service"}
    end
  end
end
