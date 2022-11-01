defmodule DoIt.Context do

  import Plug.Conn

  def init(opts), do: opts

  def call(conn, _) do
    case build_context(conn) do
      {:ok, context} ->
        # put_private(conn, :absinthe, %{context: context})
        Absinthe.Plug.put_options(conn, context: context)
      {:error, _reason} ->
        conn
      _ ->
        conn
    end
  end

  def build_context(conn) do
    with ["Bearer " <> token] <- get_req_header(conn, "authorization"),
    {:ok, current_user} <- authorize(token) do
      {:ok, %{current_user: current_user}}
    end
  end

  def authorize(token) do
    case DoIt.Guardian.decode_and_verify(token) do
      {:ok, claims} -> return_user(claims)
      {:error, reason} -> {:error, reason}
    end
  end

  defp return_user(claims) do
    case DoIt.Guardian.resource_from_claims(claims) do
      {:ok, resource} -> {:ok, resource}
      {:error, reason} -> {:error, reason}
    end
  end
end
