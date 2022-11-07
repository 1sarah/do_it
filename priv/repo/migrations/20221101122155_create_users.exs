defmodule DoIt.Repo.Migrations.CreateUsers do
  use Ecto.Migration

  def change do
    create table(:users) do
      add :username, :string
      add :age, :integer
      add :email, :string
      add :phone_number, :string
      add :gender, :string
      add :password, :string
      add :active,:boolean

      timestamps()
    end
  end
end
