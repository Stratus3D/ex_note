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

    type = detect_type(module)

    module
    |> verify_module()
    |> generate_node(type, config)
  end

  defp verify_module(module) do
    case get_module_binary(module) do
      code when is_binary(code) ->
        module
      _ ->
        raise(Error, message: "unable to inspect code from #{inspect module}")
    end
  end

  defp generate_node(nil, _, _), do: nil

  defp generate_node(module, type, config) do
    source_url  = config.source_url_pattern
    source_path = source_path(module, config)

    specs = Enum.into(Kernel.Typespec.beam_specs(module) || [], %{})
    callbacks = callbacks_implemented_by(module)

    if type == :behaviour do
      callbacks = Enum.into(Kernel.Typespec.beam_callbacks(module) || [], %{})
    end

    { line, moduledoc } = Code.get_docs(module, :moduledoc)

    %ExDoc.ModuleNode{
      id: inspect(module),
      module: module,
      type: type,
      moduledoc: moduledoc,
      typespecs: get_types(module),
      source: source_link(source_path, source_url, line),
      }
  end

  # Returns a dict of { name, arity } -> [ behaviour_module ].
  defp callbacks_implemented_by(module) do
    behaviours_implemented_by(module)
    |> Enum.map(fn behaviour -> Enum.map(callbacks_of(behaviour), &{ &1, behaviour }) end)
    |> Enum.reduce(%{}, &Enum.into/2)
  end

  defp callbacks_of(module) do
    module.module_info(:attributes)
    |> Enum.filter_map(&match?({ :callback, _ }, &1), fn {_, [{t,_}|_]} -> t end)
  end

  defp behaviours_implemented_by(module) do
    module.module_info(:attributes)
    |> Stream.filter(&match?({ :behaviour, _ }, &1))
    |> Stream.map(fn {_, l} -> l end)
    |> Enum.concat()
  end

  defp get_types(module) do
    all  = Kernel.Typespec.beam_types(module) || []
    docs = Enum.into(Kernel.Typespec.beam_typedocs(module) || [], %{})

    for { type, { name, _, args } = tuple } <- all, type != :typep do
      spec  = process_type_ast(Kernel.Typespec.type_to_ast(tuple), type)
      arity = length(args)
      doc   = docs[{ name, arity }]
      %ExDoc.TypeNode{
        id: "#{name}/#{arity}",
        name: name,
        arity: arity,
        type: type,
        spec: spec,
        doc: doc
        }
    end
  end

  defp source_link(_source_path, nil, _line), do: nil

  defp source_link(source_path, source_url, line) do
    source_url = Regex.replace(~r/%{path}/, source_url, source_path)
    Regex.replace(~r/%{line}/, source_url, to_string(line))
  end

  defp source_path(module, config) do
    source = module.__info__(:compile)[:source]

    if root = config.source_root do
      Path.relative_to(source, root)
    else
      source
    end
  end

  # Detect if a module is an exception, struct, protocol, implementation or
  # simply a module (copied from ExDoc.Retriever)
  defp detect_type(module) do
    cond do
      function_exported?(module, :__struct__, 0) ->
        case module.__struct__ do
          %{__exception__: true} -> :exception
          _ -> nil
        end
        function_exported?(module, :__protocol__, 1) -> :protocol
        function_exported?(module, :__impl__, 1) -> :impl
        function_exported?(module, :__behaviour__, 1) -> :behaviour
        true -> nil
    end
  end

  # Copied from Code module
  @doc """
  Returns the docs for the given module.

  When given a module name, it finds its BEAM code and reads the docs from it.

  When given a path to a .beam file, it will load the docs directly from that
  file.

  The return value depends on the `kind` value:

  * `:docs` - list of all docstrings attached to functions and macros
  using the `@doc` attribute

  * `:moduledoc` - tuple `{<line>, <doc>}` where `line` is the line on
  which module definition starts and `doc` is the string
  attached to the module using the `@moduledoc` attribute

  * `:all` - a keyword list with both `:docs` and `:moduledoc`

  """
  def get_docs(module, kind) when is_atom(module) do
    case :code.get_object_code(module) do
      {_module, bin, _beam_path} ->
        do_get_docs(bin, kind)

        :error -> nil
    end
  end

  def get_docs(binpath, kind) when is_binary(binpath) do
    do_get_docs(String.to_char_list(binpath), kind)
  end

  @docs_chunk 'ExDc'

  defp do_get_docs(bin_or_path, kind) do
    case :beam_lib.chunks(bin_or_path, [@docs_chunk]) do
      {:ok, {_module, [{@docs_chunk, bin}]}} ->
        lookup_docs(:erlang.binary_to_term(bin), kind)

        {:error, :beam_lib, {:missing_chunk, _, @docs_chunk}} -> nil
    end
  end

  defp lookup_docs({:elixir_docs_v1, docs}, kind),
  do: do_lookup_docs(docs, kind)

  # unsupported chunk version
  defp lookup_docs(_, _), do: nil

  defp do_lookup_docs(docs, :all), do: docs
  defp do_lookup_docs(docs, kind) when kind in [:docs, :moduledoc],
  do: Keyword.get(docs, kind)

  ## Helpers

  # Finds the file given the relative_to path.
  #
  # If the file is found, returns its path in binary, fails otherwise.
  defp find_file(file, relative_to) do
    file = if relative_to do
      Path.expand(file, relative_to)
    else
      Path.expand(file)
    end

    if File.regular?(file) do
      file
    else
      raise Code.LoadError, file: file
    end
  end

  defp source_path(module, config) do
    source = module.__info__(:compile)[:source]

    if root = config.source_root do
      Path.relative_to(source, root)
    else
      source
    end
  end

  # Cut off the body of an opaque type while leaving it on a normal type.
  defp process_type_ast({:::, _, [d|_]}, :opaque), do: d
  defp process_type_ast(ast, _), do: ast

  # Retriever private functions
  defp get_module_binary(module) do
    case :code.get_object_code(module) do
      {_name, bin, _path} ->
        bin
      error ->
        error
    end
  end
end
