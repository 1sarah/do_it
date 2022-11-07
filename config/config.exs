# This file is responsible for configuring your application
# and its dependencies with the aid of the Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
import Config

config :do_it,
  ecto_repos: [DoIt.Repo]

config :hammer,
  backend: {Hammer.Backend.ETS,
            [expiry_ms: 60_000 * 60 * 4,
             cleanup_interval_ms: 60_000 * 10]}

# Configures the endpoint
config :do_it, DoItWeb.Endpoint,
  url: [host: "localhost"],
  render_errors: [view: DoItWeb.ErrorView, accepts: ~w(html json), layout: false],
  pubsub_server: DoIt.PubSub,
  live_view: [signing_salt: "zlfeVp37"]

# Configures the mailer
#
# By default it uses the "Local" adapter which stores the emails
# locally. You can see the emails in your browser, at "/dev/mailbox".
#
# For production it's recommended to configure a different adapter
# at the `config/runtime.exs`.
config :do_it, DoIt.Mailer, adapter: Swoosh.Adapters.Local

config :petal_components, :error_translator_function, {DoItWeb.ErrorHelpers, :translate_error}

# Swoosh API client is needed for adapters other than SMTP.
config :swoosh, :api_client, false


config :tailwind, version: "3.2.1", default: [
  args: ~w(
    --config=tailwind.config.js
    --input=css/app.css
    --output=../priv/static/assets/app.css
  ),
  cd: Path.expand("../assets", __DIR__)
]

# Configure esbuild (the version is required)
config :esbuild,
  version: "0.14.29",
  default: [
    args:
      ~w(js/app.js --bundle --target=es2017 --outdir=../priv/static/assets --external:/fonts/* --external:/images/*),
    cd: Path.expand("../assets", __DIR__),
    env: %{"NODE_PATH" => Path.expand("../deps", __DIR__)}
  ]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

config :do_it, DoIt.Guardian,
  issuer: "do_it",
  secret_key: "LXUtiFJuwZ4str8KsUktMQo1Vp3SK1ouzQc3YeY4f0cttkK7em9yv6zAu8MvjSFH"

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{config_env()}.exs"
