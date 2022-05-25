defmodule Potinho.Transaction do

  use Ecto.Schema
  import Ecto.Changeset
  alias Potinho.User

  schema "transactions" do
    field :amount, Money.Ecto.Amount.Type
    field :user_sender, :string, virtual: true
    field :user_reciever, :string, virtual: true
    belongs_to :user_sender_id, User, foreign_key: :username_sender_id
    belongs_to :user_reciever_id, User, foreign_key: :username_reciever_id

    timestamps()
  end

  @required_attrs [:user_reciever, :user_sender, :amount]

  def create_changeset(params) do
    %__MODULE__{}
    |> cast(params, @required_attrs)
    |> validate_required(@required_attrs)
  end
end
