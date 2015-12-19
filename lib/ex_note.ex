defmodule ExNote do
  defmacro __using__(_options) do
    quote do
      Module.register_attribute __MODULE__, :notes, accumulate: true,
                                                    persist: false
      import unquote(__MODULE__), only: [todo: 1, fixme: 1, optimize: 1]
      @before_compile unquote(__MODULE__)
    end
  end

  defmacro __before_compile__(env) do
    compile(Module.get_attribute(env.module, :notes))
  end

  defmacro todo(note) do
    quote do
      @notes {:todo, __ENV__.line, unquote(note)}
    end
  end

  defmacro fixme(note) do
    quote do
      @notes {:fixme, __ENV__.line, unquote(note)}
    end
  end

  defmacro optimize(note) do
    quote do
      @notes {:optimize, __ENV__.line, unquote(note)}
    end
  end

  def compile(notes_list) do
    notes_map = Macro.escape(Enum.reduce notes_list, %{}, fn {type, line, note}, acc ->
      existing = Map.get(acc, type, [])
      Map.put(acc, type, [%{line: line, note: note}|existing])
    end)

    quote do
      def notes() do
        unquote(notes_map)
      end
      def todos() do
        unquote(notes_map)[:todo]
      end

      def fixmes() do
        unquote(notes_map)[:fixme]
      end

      def optimizes() do
        unquote(notes_map)[:optimize]
      end

    end
  end

  def get_notes(module_name) do
    module_name.notes()
  end
end
