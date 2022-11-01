defmodule DoIt.Accounts.User do
  use Ecto.Schema
  import Ecto.Changeset

  schema "users" do
    field :age, :integer
    field :email, :string
    field :gender, :string
    field :phone_number, :string
    field :username, :string

    timestamps()
  end

  @doc false
  def changeset(user, attrs) do
    user
    |> cast(attrs, [:username, :age, :email, :phone_number, :gender])
    |> validate_required([:username, :age, :email, :phone_number, :gender])
  end
end
