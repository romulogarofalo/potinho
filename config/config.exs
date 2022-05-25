# This file is responsible for configuring your application
# and its dependencies with the aid of the Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
import Config

config :potinho,
  ecto_repos: [Potinho.Repo]

# Configures the endpoint
config :potinho, PotinhoWeb.Endpoint,
  url: [host: "localhost"],
  render_errors: [view: PotinhoWeb.ErrorView, accepts: ~w(json), layout: false],
  pubsub_server: Potinho.PubSub,
  live_view: [signing_salt: "yrH1DZF7"]


config :ex_audit,
  ecto_repos: [Potinho.Repo],
  version_schema: Potinho.Version,
  tracked_schemas: [
    Potinho.User,
    Potinho.Transaction
  ]

# Configures the mailer
#
# By default it uses the "Local" adapter which stores the emails
# locally. You can see the emails in your browser, at "/dev/mailbox".
#
# For production it's recommended to configure a different adapter
# at the `config/runtime.exs`.
config :potinho, Potinho.Mailer, adapter: Swoosh.Adapters.Local

# Swoosh API client is needed for adapters other than SMTP.
config :swoosh, :api_client, false

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{config_env()}.exs"

config :money,
  # this allows you to do Money.new(100)
  default_currency: :BRL,
  # change the default thousands separator for Money.to_string
  separator: ",",
  # change the default decimal delimeter for Money.to_string
  delimiter: ".",
  # don’t display the currency symbol in Money.to_string
  symbol: false,
  # display units after the delimeterr
  fractional_unit: true

config :potinho, Potinho.Guardian,
  issuer: "potinho",
  secret_key: "2W5jhBgVuRxsa/tWDzdov9dudbtOLXS/cwB6XLynGWbAuKkuI47WmI1fHDsjsy1n"

config :potinho, PotinhoWeb.Auth.Pipeline,
  module: Potinho.Guardian
