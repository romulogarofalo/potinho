defmodule Potinho.Transaction.Input do
  alias Potinho.User

  use Ecto.Schema
  import Ecto.Changeset

  embedded_schema do
    field :id_sender, :string
    field :cpf_reciever, :string
    field :amount, Money.Ecto.Amount.Type
  end

  @required_attrs [:id_sender, :cpf_reciever, :amount]

  def validate(attrs) do
    %__MODULE__{}
    |> cast(attrs, @required_attrs)
    |> validate_required(@required_attrs)
    |> validate_change(:cpf_reciever, &User.validate_cpf/2)
    |> IO.inspect()
    |> apply_action(:transaction)
  end
end
