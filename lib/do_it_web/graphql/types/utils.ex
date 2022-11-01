defmodule DoItWeb.Graphql.Types.Utils do
  use Absinthe.Schema.Notation


interface :result do
  field :total, non_null(:integer)
  field :success, non_null(:boolean)
end

interface :pagination do
 field :from_date, :naive_datetime
 field :to_date, :naive_datetime
 field :offset, :integer, default_value: 0
 field :limit, :integer, default_value: 10
end

interface :location do
  field :longitude, :integer
  field :latitude,:integer
end

 enum :sort_order do
    value(:asc)
    value(:desc)
  end
end
