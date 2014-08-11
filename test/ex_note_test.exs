defmodule ExNoteTestModule, do: @todo "Test this"

defmodule ExNoteTest do
  use ExUnit.Case

  test "getting todos from a module" do
    todos = ExNoteTestModule
    |> ExNote.get_notes
    |> Dict.get :todo
    assert todos == ["Test this"]
  end
end
