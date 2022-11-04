defmodule DoItWeb.Graphql.Mutations.User do
  use Absinthe.Schema.Notation
  @desc "Create User"
  object :user_mutations do
    @desc "User Login"
    field :login, type: :login_resp do
      arg(:user_login, non_null(:user_login_inputs))
      resolve(&DoItWeb.Graphql.Resolvers.User.login/2)
    end

    @desc "Verify OTP"
    field :verify_otp, type: :login_resp do
      arg(:otp, non_null(:string))
      # resolve(&UserResolver.verify_otp/3)
    end

    field :create_user, type: :success_message do
      arg(:user, non_null(:user_create))
      resolve(&DoItWeb.Graphql.Resolvers.User.create_user/3)
    end
  end
end
