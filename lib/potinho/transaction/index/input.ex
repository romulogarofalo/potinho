defmodule Potinho.Transaction.Index.Input do
  use Ecto.Schema
  import Ecto.Changeset

  embedded_schema do
    field :user_id, :string
    field :initial_date, :naive_datetime
    field :end_date, :naive_datetime
  end

  @required_attrs [:user_id, :initial_date, :end_date]

  def validate(attrs) do
    %__MODULE__{}
    |> cast(attrs, @required_attrs)
    |> validate_required(@required_attrs)
    |> apply_action(:index)
  end
end
