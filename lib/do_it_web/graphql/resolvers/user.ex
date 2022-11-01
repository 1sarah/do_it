defmodule DoItWeb.Graphql.Resolvers.User do
  use Absinthe.Schema.Notation


  def login(%{user_login: %{password: password, username: username}}, _resolution) do
    with {:check_login_limit, :allow} <-
           {:check_login_limit, TppcExWeb.Utils.check_rate(username)},
         {:user, {:ok, getUser}} <- {:user, username |> Users.get_user_by_username()},
         {:check_user_active, true} <-
           {:check_user_active, getUser.active},
         {:change_password_first_login, false} <-
           {:change_password_first_login, getUser.changePasswordOnNextLogon},
         {:verify, true} <- {:verify, Argon2.verify_pass(password, getUser.password)},
         {:check_password_expiry, false} <-
           {:check_password_expiry, password_expired?(getUser)},
         {:otp, otp} <- {:otp, :pot.totp(Base.encode32(getUser.username), [{:token_length, 6}])},
         otp = assign_otp(getUser.username, otp),
         {:server, {:ok, _pid}} <-
           {:server,
            OtpServer.start_server(
              getUser.username,
              otp
            )} do
      userRet = %{
        username: getUser.username,
        id: getUser.id,
        message: "Login Successful. Kindly verify the otp sent to you"
      }

      Task.async(fn ->
        send_otp(
          otp,
          getUser.email,
          userRet.username,
          getUser.first_name,
          getUser.last_name,
          "TPPC Backoffice, OTP"
        )
        |> Mailer.deliver_later()
      end)

      {:ok, userRet}

      {:ok, token, _} =
        TppcEx.Guardian.encode_and_sign(userRet, [typ: "otp"], ttl: {10, :minutes})

      {:ok, Map.put_new(userRet, :token, token)}
    else
      {:user, _} ->
        {:error, "User not found"}

      {:check_login_limit, _} ->
        {:error, %{message: "Sorry your account is locked"}}

      # if returned tuple are :eq/:gt todays date the user should reset password
      {:check_password_expiry, true} ->
        {:ok, reset_token, _} = get_reset_password_token(Users.get_user_by_username(username))

        {:ok,
         %{
           message: "Ooops! Password expired. Reset your password",
           username: username,
           token: reset_token
         }}

      {:check_user_active, _} ->
        {:error, "Account disabled, please contact system admin"}

      {:change_password_first_login, true} ->
        {:ok, change_password_token, _} =
          get_reset_password_token(Users.get_user_by_username(username))

        {:ok,
         %{
           message: "Yikes ...change your password",
           username: username,
           token: change_password_token
         }}

      {:verify, _} ->
        {:error, "invalid username/password"}

      {:otp, _} ->
        {:error, "Unable to generate otp. Contact system admin"}

      {:server, {:error, {:already_started, _}}} ->
        Logger.warn("OTP  already started")
        {:ok, user} = username |> Users.get_user_by_username()

        user_claim = %{
          username: user.username,
          id: user.id,
          message: "Login Successful. OTP already sent"
        }

        {:ok, user_claim}

        {:ok, token, _} =
          TppcEx.Guardian.encode_and_sign(user_claim, [typ: "otp"], ttl: {5, :minutes})

        {:ok, Map.put_new(user_claim, :token, token)}

      {:server, _} ->
        {:error, "Unable to start otp server. Contact system admin"}
    end
  end

  # defp assign_otp(username, otp) do
  #   if username == "admin" do
  #     "777777"
  #   else
  #     otp
  #   end
  # end

  # def verify_otp(_parent, args, context) do
  #   with {:auth, %{context: %{current_user: user}}} <- {:auth, context},
  #        {:verify, :valid_otp} <-
  #          {:verify, OtpServer.verify_otp(user.resource.username, args.otp)} do
  #     userRet = %{username: user.resource.username, id: user.resource.id}

  #     {:ok, token, _} = TppcEx.Guardian.encode_and_sign(userRet, typ: "access")
  #     {:ok, Map.put_new(userRet, :token, token)}
  #   else
  #     {:auth, _} ->
  #       {:error, "User must be authenticated"}

  #     {:verify, :otp_server_not_found} ->
  #       {:error, "OTP server not found"}

  #     {:verify, :invalid_otp} ->
  #       {:error, "invalid OTP"}

  #     {:verify, :retries_depleted} ->
  #       {:error, "Retries depleted"}
  #   end
  # end

  def create_user(_parent, args, context) do
    permission = "basic.user.create"

    # Generate a random password
    # alphabet =
    #   Enum.to_list(?a..?z) ++ Enum.to_list(?!..?+) ++ Enum.to_list(?0..?9) ++ Enum.to_list(?A..?Z)

    # length = 10

    # generated_password = Enum.take_random(alphabet, length)

    user_details = %{
      # convert the generated password to a string using kernel
      # password: Kernel.inspect(generated_password),
      email: args.user.email,
      gender: to_string(args.user.gender),
      first_name: args.user.first_name,
      last_name: args.user.last_name,
      user_type: args.user.user_type,
      department: args.user.department,
      middle_name: args.user.middle_name,
      operation_address: args.user.operation_address,
      password: DefaultPassword.generate_password(),
      username: args.user.username,
      active: true
    }

    action = "Approve #{user_details.username}, user creation"

    work_groups_returned =
      Enum.map(WorkGroups.get_all_workgroups_with_id(args.user.workgroup), fn workgroup ->
        %{
          id: workgroup.id,
          name: workgroup.name
        }
      end)

    with {:auth, %{context: %{current_user: user}}} <- {:auth, context},
         {:authorization, true} <-
           {:authorization, PermissionManager.check_permission(permission, "access", user)},
         {:changeset, %Ecto.Changeset{valid?: true}} <-
           {:changeset,
            Ecto.Changeset.unsafe_validate_unique(
              TppcEx.Users.User.changeset(%TppcEx.Users.User{}, user_details),
              :username,
              TppcEx.Repo
            )} do
      # copy data to inbox and return success
      payload = %{
        workgroups: work_groups_returned,
        attrs: user_details
      }

      state_change = %{
        applied: false,
        created_by: user.resource.username,
        item_context: to_string(Users),
        item_id: Ecto.UUID.generate(),
        target_function: "create_user_after_approval",
        json_data: Jason.encode!(payload),
        required_permission: permission,
        action: "creation",
        narrative: action,
        version: "1"
        # updated_by: user.username
      }

      {:ok, _queue} = Queues.create_queue(state_change)

      {:ok, %{message: "User created succesfully", success: true}}
    else
      {:auth, _} ->
        {:error, "You must be authenticated!"}

      {:changeset, %Ecto.Changeset{} = changeset} ->
        {:error, changeset}

      {:authorization, false} ->
        {:error, "User not authorized for action"}

      {:authorization, :licence} ->
        {:error, "Feature not licenced for!"}

      {:authorization, :scope} ->
        {:error, "Invalid token scope, please complete login!"}

      {:createuser, {:error, %Ecto.Changeset{} = changeset}} ->
        {:error, changeset}

      {:storedpassword, {:error, %Ecto.Changeset{} = changeset}} ->
        {{:error, changeset}}
    end
  end
end
