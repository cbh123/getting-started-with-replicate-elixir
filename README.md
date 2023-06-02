# 🔮 Conjurer

A demo app that lets you create images using the [Replicate Elixir client](https://github.com/cbh123/replicate-elixir).

https://github.com/cbh123/getting-started-with-replicate-elixir/assets/14149230/dba6b2a0-71f1-4838-bf97-6937e3211efe


To run Conjurer:

  * Run `mix setup` to install and setup dependencies
  * Copy the `.env.example` file and make a new one called `.env`. Add your Replicate token and ngrok host.
  * Add the Replicate config to your `config.exs`: 
  ```
  config :replicate,
  replicate_api_token: System.fetch_env!("REPLICATE_API_TOKEN")
  ```
  * Make sure your env variables are saved with `source .env`
  * Start the endpoint with `mix phx.server`

Now you can visit [`localhost:4000/predictions`](http://localhost:4000/predictions) from your browser.

## Learn more

  * Replicate: https://www.replicate.com/docs
  * Replicate Hex package: https://github.com/cbh123/replicate-elixir
