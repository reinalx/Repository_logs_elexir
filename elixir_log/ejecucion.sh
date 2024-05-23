#!/bin/bash


gnome-terminal --title="Generador" -- bash -c "mix deps.get; mix compile; MIX_ENV=repo_off iex -S mix; exec bash"

gnome-terminal --title="Server" -- bash -c "mix deps.get;iex --sname server@localhost -S mix; exec bash"

gnome-terminal --title="Cliente" -- bash -c "mix deps.get;MIX_ENV=repo_off iex --sname client@localhost -S mix; exec bash"
