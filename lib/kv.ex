defmodule KV do
  use Application

  def start(_type, _args) do
    IO.puts "Starting up!"
    KV.Supervisor.start_link(name: KV.Supervisor)
  end
end
