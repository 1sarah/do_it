defmodule DoIt.Accounts.User do
  use Ecto.Schema
  import Ecto.Changeset

  schema "users" do
    field :age, :integer
    field :email, :string
    field :gender, :string
    field :phone_number, :string
    field :username, :string
    field :password, :string, redact: true
    field :active, :boolean, default: true

    timestamps()
  end

  @doc false
  def changeset(user, attrs) do
    user
    |> cast(attrs, [:username, :age, :active, :email, :phone_number, :gender, :password])
    |> validate_required([:username, :age, :email, :phone_number, :gender])
    |> DoIt.Accounts.put_password_hash()
  end
end
