defmodule Mix.Tasks.Exnote.Setup do
  use Mix.Task

  @shortdoc "Handles custom setup for ExUnit tests"
  @recursive true
  @moduledoc """
  Handles setup operation like compilation of modules used for ExUnit in
  test/support/lib
  """

  @doc """
  Compiles modules used for ExUnit in test/support/lib
  """
  @todo "Write code to compile all modules in the test/support/ebin dir"
  def run([]) do
      # Compile code

      # Added ebin dir to path
      Code.append_path("test/support/ebin")
  end
end
