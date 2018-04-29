# Hello

[Plug](https://hexdocs.pm/plug) を使った Web サーバのサンプル。

## 手順

### プロジェクトを作成する

Plug のプロセスを監視したいので `--sup` オプションを指定して superviser も生成しておく。

```sh
$ mix new hello --sup
$ cd hello
```

### パッケージを追加する

Cowboy と Plug を mix.exs に追加し、`mix deps.get` コマンドでパッケージを取得する。

```elixir
  defp deps do
    [
      {:cowboy, "~> 1.0"},
      {:plug, "~> 1.0"}
    ]
  end
```

```sh
$ mix deps.get
```

### ルータを追加する

`lib/hello/router.ex` ファイルを追加する。
ここでは、パラメータを受け取らない `/hello` というパスと、パラメータを受け取る `/hellow/:name` というパスを定義している。

詳細は[ドキュメント](https://hexdocs.pm/plug/readme.html#plug-router)を参照。

```elixir
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
```

### Plug を superviser の監視対象に追加する

`lib/hello/application.ex` を編集し、`start` 関数の中の `children` に Plug の定義を追加する。
詳細は[ドキュメント](https://hexdocs.pm/plug/readme.html#supervised-handlers)を参照。

```elixir
defmodule Hello.Application do
  @moduledoc false

  use Application

  def start(_type, _args) do
    children = [
      # 追加
      Plug.Adapters.Cowboy.child_spec(scheme: :http, plug: Hello.Router, options: [port: 4001])
    ]

    opts = [strategy: :one_for_one, name: Hello.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
```

### サーバを起動する

```sh
$ mix run --no-halt
```

あるいは

```sh
$ iex -S mix
```

コンソールを新たに開きリクエストを送って動作していることを確認する。

```sh
$ curl http://localhost:4001/hello
Hello world!
$ curl http://localhost:4001/hello/Alice
Hello Alice!
$ curl http://localhost:4001/hello/Bob
Hello Bob!
```

### 処理コードを他のモジュールに分離する

ここでは、リクエストを受けた時の処理を `lib/hello.ex` に分離し、`get` マクロの `:to` オプションで呼び出すモジュールを指定し、`:init_opts` オプションでモジュール内で呼び出す関数を指定している。
`:fun` は任意のキー。呼び出されたモジュールで `:fun` をキーにして関数名を取り出している。

詳細は[ドキュメント](https://hexdocs.pm/plug/Plug.Router.html#match/3)を参照。

```elixir
defmodule Hello.Router do
  use Plug.Router

  plug :match
  plug :dispatch

  get "/hello", to: Hello, init_opts: [fun: :hello]
  get "/hello/:name", to: Hello, init_opts: [fun: :hello_who]
end
```

`lib/hello.ex` を module plug として記述する。
ここでは、オプションで受け取った関数名を `apply/2` を利用してモジュールに適用している。

module plug については[ドキュメント](https://hexdocs.pm/plug/Plug.html#content)を参照。

```elixir
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
```

### テスト

`test/hello_test.exs` を次のように編集する。

詳細は[ドキュメント](https://hexdocs.pm/plug/readme.html#testing-plugs)を参照。

```elixir
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
```
