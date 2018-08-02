# KV

**TODO: Add description**

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `kv` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:kv, "~> 0.1.0"}
  ]
end
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at [https://hexdocs.pm/kv](https://hexdocs.pm/kv).

## Deployment

The Dockerfile uses a multi-stage build to create a [distillery](https://hexdocs.pm/distillery/getting-started.html) release including the Erlang runtime, then copy it to a fresh alpine image for minimal runtime size.

```
# Start minikube
minikube start

# Set docker env in current shell
eval $(minikube docker-env)

# Build image
docker build -t kv .

# Run in minikube, set image-pull-policy to avoid remote fetch attempt
kubectl run kv --image=kv --image-pull-policy=Never --port 8080

# Check that it's running
kubectl get pods

# Tear down a deployment
kubectl delete deployment kv

# Delete a pod (and let the k8s deployment replace it)
kubectl delete pod <NAME_FROM_KUBETCTL_GET_PODS>
```
