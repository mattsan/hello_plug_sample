defmodule HelloTest do
  use ExUnit.Case
  use Plug.Test

  @opts Hello.Router.init([])

  test "returns hello world" do
    conn =
      conn(:get, "/hello")
      |> Hello.Router.call(@opts)

    assert conn.state == :sent
    assert conn.status == 200
    assert conn.resp_body == "Hello world!\n"
  end

  test "returns hello Alice" do
    conn =
      conn(:get, "/hello/Alice")
      |> Hello.Router.call(@opts)

    assert conn.state == :sent
    assert conn.status == 200
    assert conn.resp_body == "Hello Alice!\n"
  end
end
