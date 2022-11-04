defmodule DoItWeb.Graphql.Utils.Util do

    def check_rate(username) do
      case Hammer.check_rate("lock_user:#{username}", 60_000, 5) do
        {:allow, _count} ->
          :allow

        {:deny, _limit} ->
          # TODO - lock account of user if it is not locked...
          :deny
      end
  end
end
