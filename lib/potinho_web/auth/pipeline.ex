defmodule   PotinhoWeb.Auth.Pipeline do
  use Guardian.Plug.Pipeline, otp_app: :potinho

  plug(Guardian.Plug.VerifySession)
  plug(Guardian.Plug.VerifyHeader, realm: "Bearer", error_handler: PotinhoWeb.HttpAuthErrorHandler)
  plug Guardian.Plug.LoadResource
end
