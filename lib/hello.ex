defmodule Hello do
  import Plug.Conn

  def init(opts) do
    opts
  end

  def call(conn, opts) do
    apply(__MODULE__, Keyword.get(opts, :fun), [conn, opts])
  end

  def hello(conn, _opts) do
    conn
    |> put_resp_content_type("text/plain")
    |> send_resp(200, "Hello world!\n")
  end

  def hello_who(%{params: %{"name" => name}} = conn, _opts) do
    conn
    |> put_resp_content_type("text/plain")
    |> send_resp(200, "Hello #{name}!\n")
  end
end
