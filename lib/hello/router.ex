defmodule Hello.Router do
  use Plug.Router

  plug :match
  plug :dispatch

  get "/hello" do
    conn
    |> put_resp_content_type("text/plain")
    |> send_resp(200, "Hello world\n")
  end

  get "/hello/:name" do
    conn
    |> put_resp_content_type("text/plain")
    |> send_resp(200, "Hello #{name}\n")
  end
end
