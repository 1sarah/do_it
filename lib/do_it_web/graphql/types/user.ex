defmodule DoItWeb.Graphql.Types.User do
  use Absinthe.Schema.Notation
    import_types(Absinthe.Type.Custom)

    @desc "user object"
    object :user do
      field(:id, :string)
      field(:username, :string)
      field(:gender, :gender)
      field(:email, :string)
    end

    @desc "user login inputs"
    input_object :user_login_inputs do
      field(:username, non_null(:string))
      field(:password, non_null(:string))
    end



    @desc "user filter object"
    input_object :user_filter do
      field(:name, :string)
      field(:username, :string)
      field(:id, :string)
      import_fields(:pagination)
    end

    @desc "user login response"
    object :login_resp do
      field(:username, non_null(:string))
      field(:token, non_null(:string))
      field(:message, :string)
    end

    @desc "user login password expiry response"
    object :password_expiry_login_resp do
      field(:message, non_null(:string))
      field(:token, non_null(:string))
    end

    @desc "The selected gender types"

    enum :gender do
      value(:female, name: "FEMALE")
      value(:male, name: "MALE")
      value(:other, name: "OTHER")
    end

    @desc "User Creation inputs"
    input_object :user_create do
      field(:username, non_null(:string))
      field(:email, non_null(:string))
      field(:age, non_null(:integer))
      field(:gender, non_null(:gender))
    end

    @desc "Forgot password inputs"
    input_object :forgot_password do
      field(:email, non_null(:string))
    end


    @desc "User Update inputs"
    input_object :update_user do
      field(:id, non_null(:id))
      field(:password, :string)
      field(:username, :string)
    end

    @desc "User Password Update inputs"
    input_object :change_password do
      field(:old_password, :string)
      field(:new_password, :string)
      field(:confirm_password, :string)
    end


    @desc "User Result"
    object :user_result do
      import_fields(:result)
      field(:users, non_null(list_of(non_null(:user))))
    end
  end
