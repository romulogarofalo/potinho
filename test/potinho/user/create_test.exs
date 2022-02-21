defmodule Potinho.User.CreateTest do
  use ExUnit.Case
  use Potinho.DataCase

  alias Potinho.User.Create

  describe "run/1" do
    test "with ok params" do
      full_name = "Romulo aaa aaa"
      password = "123123"
      cpf = Brcpfcnpj.cpf_generate()

      params = %{
        "full_name_user" => full_name,
        "password" => password,
        "cpf" => cpf
      }

      assert {:ok, %{
        full_name_user: ^full_name,
        password: ^password,
        password_hash: password_hash,
        cpf: ^cpf
      }} = Create.run(params)

      assert Bcrypt.verify_pass(password, password_hash)
    end

    test "when insert repeated user" do
      full_name = "Romulo aaa aaa"
      password = "123123"
      cpf = Brcpfcnpj.cpf_generate()

      params = %{
        "full_name_user" => full_name,
        "password" => password,
        "cpf" => cpf
      }

      Create.run(params)

      assert {:error, %{
        errors: [
          cpf: {msg, _}
        ]
      }} = Create.run(params)

      assert msg == "has already been taken"
    end

    test "when insert with empty values" do
      params = %{
        "full_name_user" => "",
        "password" => "",
        "cpf" => ""
      }

      Create.run(params)

      assert {:error, %{
        errors: errors
      }} = Create.run(params)

      assert errors == [
        {:full_name_user, {"can't be blank", [validation: :required]}},
        {:password, {"can't be blank", [validation: :required]}},
        {:cpf, {"can't be blank", [validation: :required]}}
      ]
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

      Create.run(params)

      assert {:error, %{
        errors: [
          cpf: {msg, _}
        ]
      }} = Create.run(params)

      assert msg == "invalid format"
    end
  end
end
