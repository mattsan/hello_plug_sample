defmodule Hello.Router do
  use Plug.Router

  plug :match
  plug :dispatch

  get "/hello", to: Hello, init_opts: [fun: :hello]
  get "/hello/:name", to: Hello, init_opts: [fun: :hello_who]
end
