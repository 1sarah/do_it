defmodule DoItWeb.Graphql.Queries.User do
  use Absinthe.Schema.Notation

  object :user_queries do
    field :get_all_users, :user_result do
      arg(:filter, :user_filter)
      arg(:order, type: :sort_order, default_value: :desc)
      resolve(&DoItWeb.Graphql.Resolvers.User.get_all_users/3)
    end
  end
end
