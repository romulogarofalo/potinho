defmodule Potinho.Login do
  use Ecto.Schema

  import Ecto.Changeset

  alias Potinho.User

  schema "login" do
    field :cpf, :string
    field :password, :string
  end

  @required_attrs [:cpf, :password]

  def validate(attrs) do
    %__MODULE__{}
    |> cast(attrs, @required_attrs)
    |> validate_required(@required_attrs)
    |> validate_change(:cpf, User.validate_cpf())
    |> apply_action(:insert)
  end
end
