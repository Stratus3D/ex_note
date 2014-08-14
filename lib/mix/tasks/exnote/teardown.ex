defmodule Mix.Tasks.Exnote.Teardown do
  use Mix.Task

  @shortdoc "Handles custom teardown for ExUnit tests"
  @recursive true
  @moduledoc """
  Handles teardown operations like removal of modules used for ExUnit in
  test/support/ebin
  """

  @doc """
  Removes compiled modules used for ExUnit tests from test/support/ebin
  """
  def run([]) do
    File.rm_rf("test/support/ebin/")
    File.mkdir("test/support/ebin/")
  end
end
