defmodule DoIt.Security.Guardian do
  alias DoIt.Accounts.User
  use Guardian, otp_app: :my_app
  def subject_for_token(%{id: id},_claims) do
    # You can use any value for the subject of your token but
    # it should be useful in retrieving the resource later, see
    # how it being used on `resource_from_claims/1` function.
    # A unique `id` is a good subject, a non-unique email address
    # is a poor subject.
    sub = to_string(id)
    {:ok, sub}
  end
  def subject_for_token(_, _) do
    {:error, "Could not find value id in jwt token."}
  end

  def resource_from_claims(%{"sub" => id, "typ" => scope}) do


    resource = Repo.get(User,id)
    Logger.debug(resource)


    {:ok,  %{resource: resource, scope: scope}}
  end

  def resource_from_claims(_claims) do
    {:error, :reason_for_error}
  end
end
