# SimpleCluster

OTP clustering fun. Uses libcluster with [Cluster.Strategy.Epmd](https://hexdocs.pm/libcluster/Cluster.Strategy.Epmd.html)

## Starting nodes

Terminal 1

```bash
iex --name n1@127.0.0.1 -S mix
```

Terminal 2

```bash
iex --name n2@127.0.0.1 -S mix
```

Ping nodes in cluster

```bash
SimpleCluster.Ping.ping()
```

## Livebook Docs

```bash
mix escript.install hex livebook
asdf reshim elixir
```

```bash
livebook server
```
