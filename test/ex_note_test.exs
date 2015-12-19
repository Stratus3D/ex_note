defmodule ExNoteTestModule do
  use ExNote

  todo "Test this"
  fixme "This is broken"
  optimize "Make this faster"
end

defmodule ExNoteTest do
  use ExUnit.Case

  def is_list_of_maps(list) do
    for map <- list do
      assert Kernel.is_map(map) == true
    end
  end

  def is_map_of_lists(map) do
    Enum.each(map, fn({key, list}) ->
      assert Kernel.is_list(list) == true
    end)
  end

  test "module should have a notes function" do
    notes = ExNoteTestModule.notes
    is_map_of_lists(notes)
  end

  test "module should have a todos function" do
    todos = ExNoteTestModule.todos
    is_list_of_maps(todos)
  end

  test "module should have a fixmes function" do
    fixmes = ExNoteTestModule.fixmes
    is_list_of_maps(fixmes)
  end

  test "module should have a optimizes function" do
    optimizes = ExNoteTestModule.optimizes
    is_list_of_maps(optimizes)
  end

  test "getting todos from a module" do
    todos = ExNoteTestModule
    |> ExNote.get_notes
    |> Dict.get :todo
    todo = todos
    |> List.first
    assert todo[:note] == "Test this"
    assert todo[:line] == 4
  end
end
