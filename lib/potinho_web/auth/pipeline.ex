defmodule PotinhoWeb.Auth.Pipeline do
  use Guardian.Plug.Pipeline, otp_app: :potinho

  plug(Guardian.Plug.VerifySession, error_handler: PotinhoWeb.HttpAuthErrorHandler)

  plug(Guardian.Plug.VerifyHeader, realm: "Bearer", error_handler: PotinhoWeb.HttpAuthErrorHandler)

  plug Guardian.Plug.LoadResource, error_handler: PotinhoWeb.HttpAuthErrorHandler
end
