defmodule DoItWeb.Graphql.Resolvers.User do
  use Absinthe.Schema.Notation
  alias DoIt.Accounts.Accounts

  def login(%{user_login: %{password: password, username: username}}, _resolution) do
    # with {:check_login_limit, :allow} <-
    #        {:check_login_limit, TppcExWeb.Utils.check_rate(username)},
    #      {:user, {:ok, getUser}} <- {:user, username |> Users.get_user_by_username()},
    #      {:check_user_active, true} <-
    #        {:check_user_active, getUser.active},
    #      {:change_password_first_login, false} <-
    #        {:change_password_first_login, getUser.changePasswordOnNextLogon},
    #      {:verify, true} <- {:verify, Argon2.verify_pass(password, getUser.password)},
    #      {:check_password_expiry, false} <-
    #        {:check_password_expiry, password_expired?(getUser)},
    #      {:otp, otp} <- {:otp, :pot.totp(Base.encode32(getUser.username), [{:token_length, 6}])},
    #      otp = assign_otp(getUser.username, otp),
    #      {:server, {:ok, _pid}} <-
    #        {:server,
    #         OtpServer.start_server(
    #           getUser.username,
    #           otp
    #         )} do
    #   userRet = %{
    #     username: getUser.username,
    #     id: getUser.id,
    #     message: "Login Successful. Kindly verify the otp sent to you"
    #   }

    #   Task.async(fn ->
    #     send_otp(
    #       otp,
    #       getUser.email,
    #       userRet.username,
    #       getUser.first_name,
    #       getUser.last_name,
    #       "TPPC Backoffice, OTP"
    #     )
    #     |> Mailer.deliver_later()
    #   end)

    #   {:ok, userRet}

    #   {:ok, token, _} =
    #     TppcEx.Guardian.encode_and_sign(userRet, [typ: "otp"], ttl: {10, :minutes})

    #   {:ok, Map.put_new(userRet, :token, token)}
    # else
    #   {:user, _} ->
    #     {:error, "User not found"}

    #   {:check_login_limit, _} ->
    #     {:error, %{message: "Sorry your account is locked"}}

    #   # if returned tuple are :eq/:gt todays date the user should reset password
    #   {:check_password_expiry, true} ->
    #     {:ok, reset_token, _} = get_reset_password_token(Users.get_user_by_username(username))

    #     {:ok,
    #      %{
    #        message: "Ooops! Password expired. Reset your password",
    #        username: username,
    #        token: reset_token
    #      }}

    #   {:check_user_active, _} ->
    #     {:error, "Account disabled, please contact system admin"}

    #   {:change_password_first_login, true} ->
    #     {:ok, change_password_token, _} =
    #       get_reset_password_token(Users.get_user_by_username(username))

    #     {:ok,
    #      %{
    #        message: "Yikes ...change your password",
    #        username: username,
    #        token: change_password_token
    #      }}

    #   {:verify, _} ->
    #     {:error, "invalid username/password"}

    #   {:otp, _} ->
    #     {:error, "Unable to generate otp. Contact system admin"}

    #   {:server, {:error, {:already_started, _}}} ->
    #     Logger.warn("OTP  already started")
    #     {:ok, user} = username |> Users.get_user_by_username()

    #     user_claim = %{
    #       username: user.username,
    #       id: user.id,
    #       message: "Login Successful. OTP already sent"
    #     }

    #     {:ok, user_claim}

    #     {:ok, token, _} =
    #       TppcEx.Guardian.encode_and_sign(user_claim, [typ: "otp"], ttl: {5, :minutes})

    #     {:ok, Map.put_new(user_claim, :token, token)}

    #   {:server, _} ->
    #     {:error, "Unable to start otp server. Contact system admin"}
    # end
  end

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

  def create_user(_parent, args, context) do
    with {:auth, %{context: %{current_user: _user}}} <- {:auth, context},
         {:createuser, {:ok, _user}} <- {:createuser, Accounts.create_user(args.user)} do
      {:ok, %{message: "User created succesfully", success: true}}
    else
      {:auth, _} ->
        {:error, "You must be authenticated!"}

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
