defmodule KV.RegistryTest do
  @moduledoc """
  The advantage of using start_supervised! is that ExUnit will guarantee that the
  registry process will be shutdown before the next test starts. In other words, it
  helps guarantee the state of one test is not going to interfere with the next one
  in case they depend on shared resources.
  """

  use ExUnit.Case, async: true

  setup do
    # TODO: Start a supervisor per test and pass it as an argument to the registry
    # start_link function
    registry = start_supervised!(KV.Registry)
    %{registry: registry}
  end

  test "spawns buckets", %{registry: registry} do
    assert KV.Registry.lookup(registry, "shopping") == :error

    KV.Registry.create(registry, "shopping")
    assert {:ok, bucket} = KV.Registry.lookup(registry, "shopping")

    KV.Bucket.put(bucket, "milk", 1)
    assert KV.Bucket.get(bucket, "milk") == 1
  end

  test "skips recreating a duplicate bucket", %{registry: registry} do
    KV.Registry.create(registry, "shopping")

    {:ok, bucket} = KV.Registry.lookup(registry, "shopping")
    KV.Bucket.put(bucket, "milk", 1)

    KV.Registry.create(registry, "shopping")
    assert {:ok, bucket} = KV.Registry.lookup(registry, "shopping")
    assert KV.Bucket.get(bucket, "milk") == 1
  end

  test "stops the registry", %{registry: registry} do
    KV.Registry.stop(registry)

    try do
      KV.Registry.lookup(registry, "shopping")
    catch
      :exit, _ -> :ok
    else
      _ -> flunk()
    end
  end

  test "removes buckets on exit", %{registry: registry} do
    KV.Registry.create(registry, "shopping")
    {:ok, bucket} = KV.Registry.lookup(registry, "shopping")

    Agent.stop(bucket)
    assert KV.Registry.lookup(registry, "shopping") == :error
  end

  test "removes bucket on crash", %{registry: registry} do
    KV.Registry.create(registry, "shopping")
    {:ok, bucket} = KV.Registry.lookup(registry, "shopping")

    # Stop the bucket with non-normal reason
    Agent.stop(bucket, :shutdown)
    assert KV.Registry.lookup(registry, "shopping") == :error
  end
end
