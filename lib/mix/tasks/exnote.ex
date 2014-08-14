defmodule Mix.Tasks.Exnote do
  use Mix.Task

  @shortdoc "Handles custom ExUnit setup/teardown logic"
  @recursive true
  @moduledoc """
  Handles custom setup and teardown logic for ExUnit tests. Normally run before
  and after test runs.
  """

  @doc """
  List ExNoteTest tasks with help
  """
  def run([]) do
    help
  end

  def run(["--help"]) do
    help
  end

  def help do
    Mix.shell.info """
    Handles custom setup and teardown logic for ExUnit tests. Normally run before and after test runs.

    Commands:
    mix exnote.setup    # Compile modules used for testing with ExUnit
    mix exnote.teardown # Cleanup compiled modules
    """
  end
end
