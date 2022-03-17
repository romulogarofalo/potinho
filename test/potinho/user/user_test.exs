defmodule Potinho.UserTest do
  use ExUnit.Case

  alias Potinho.User

  describe "create_changeset/1" do
    test "with rigth params return a valid changeset" do
      full_name = "Romulo aaa aaa"
      password = "123123"
      cpf = Brcpfcnpj.cpf_generate()

      params = %{
        "full_name_user" => full_name,
        "password" => password,
        "cpf" => cpf,
        "balance" => "1000.50"
      }

      assert %Ecto.Changeset{
               changes: %{
                 full_name_user: ^full_name,
                 password: ^password,
                 password_hash: password_hash,
                 cpf: ^cpf,
                 balance: balance
               },
               valid?: true,
               errors: []
             } = User.create_changeset(params)

      assert balance == %Money{amount: 100_050, currency: :BRL}
      assert Bcrypt.verify_pass(password, password_hash)
    end

    test "when cpf is wrong format" do
      full_name = "Romulo aaa aaa"
      password = "123123"
      cpf = "batatinha"

      params = %{
        "full_name_user" => full_name,
        "password" => password,
        "cpf" => cpf
      }

      assert %Ecto.Changeset{
               changes: %{
                 full_name_user: ^full_name,
                 password: ^password,
                 cpf: ^cpf
               },
               valid?: false,
               errors: [{:cpf, {"invalid format", []}}]
             } = User.create_changeset(params)
    end
  end
end
