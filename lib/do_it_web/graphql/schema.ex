defmodule DoItWeb.Graphql.Schema do
  use Absinthe.Schema

  import_types(DoItWeb.Graphql.Types.User)

  import_types(DoItWeb.Graphql.Queries.User)

  import_types(DoItWeb.Graphql.Mutations.User)

  query do
    import_fields(:user_queries)
  end

  mutation do
    import_fields(:user_mutations)
  end

end
