defmodule Potinho.Login do
  use Ecto.Schema

  import Ecto.Changeset

  alias Potinho.User

  embedded_schema do
    field :cpf, :string
    field :password, :string
  end

  @required_attrs [:cpf, :password]

  def validate(attrs) do
    %__MODULE__{}
    |> cast(attrs, @required_attrs)
    |> validate_required(@required_attrs)
    |> validate_change(:cpf, &User.validate_cpf/2)
    |> apply_action(:login)
  end
end
