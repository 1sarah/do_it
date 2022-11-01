defmodule DoIt.AccountsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `DoIt.Accounts` context.
  """

  @doc """
  Generate a user.
  """
  def user_fixture(attrs \\ %{}) do
    {:ok, user} =
      attrs
      |> Enum.into(%{
        age: 42,
        email: "some email",
        gender: "some gender",
        phone_number: "some phone_number",
        username: "some username"
      })
      |> DoIt.Accounts.create_user()

    user
  end
end
