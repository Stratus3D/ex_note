defmodule ExNote.Retriever do
  @moduledoc """
  Functions to extract information associated with module attributes from
  modules.
  """

  @doc """
  Extract attributes from all modules in the specified directory
  """
  def attributes_from_dir(dir, config) do
    files = Path.wildcard Path.expand("Elixir.*.beam", dir)
    attributes_from_files(files, config)
  end

  @doc """
  Extract attributes from all modules in the specified list of files
  """
  def attributes_from_files(files, config)  when is_list(files) do
    files
    |> Enum.map(&filename_to_module(&1))
    |> attributes_from_modules(config)
  end

  @doc """
  Extract attributes from all modules in the list `modules`
  """
  def attributes_from_modules(modules, config) when is_list(modules) do
    modules
    |> Enum.map(&get_module(&1, config))
    |> Enum.filter(fn(x) -> x end)
    |> Enum.sort(&(&1.id <= &2.id))
  end

  defp filename_to_module(name) do
    name = Path.basename name, ".beam"
    String.to_atom name
  end

  defp get_module(module, config) do
    unless Code.ensure_loaded?(module), do:
    raise(Error, message: "module #{inspect module} is not defined/available")

    #type = detect_type(module)

    #module
    #|> verify_module()
    #|> generate_node(type, config)
  end

  defp verify_module(module) do
    # Replace Code.get_docs/2 with a call to :code.get_object_code/1
    #case Code.get_docs(module, :all) do
    #  [docs: _, moduledoc: {_line, false}] ->
    #    nil
    #  [docs: _, moduledoc: _] ->
    #    module
    #  nil ->
    #    nil
    #  _ ->
    #    raise(Error, message: "module #{inspect module} was not compiled with flag --docs")
    #end
  end
end
