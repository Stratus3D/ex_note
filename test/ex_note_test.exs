defmodule ExNoteTestModule do
  use ExNote

  todo "Test this"
  fixme "This is broken"
end

defmodule ExNoteTest do
  use ExUnit.Case

  test "getting todos from a module" do
    todos = ExNoteTestModule
    |> ExNote.get_notes
    |> Dict.get :todo
    assert todos == ["Test this"]
  end
end
