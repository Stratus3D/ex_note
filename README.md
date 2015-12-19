ExNote
======

An experiment to see how difficult it is to create ExDoc like module attributes for things like TODOs and FIXMEs. As this is just an experiment, it isn't intended for use in production applications.

Initially I wanted something like this:

``` elixir
defmodule ExNoteExampleModule do
  @todo "Test this"
  @fixme "This is broken"
end
```

But it turns out that isn't very easy to do, since I would need to take all the AST for the module and preprocess it before compiling. By `use`ing the `ExNote` module it becomes much easier. I can simply use the `todo`, `fixme` and `optimize` macros:

``` elixir
defmodule ExNoteExampleModule do
  use ExNote

  todo "Test this"
  fixme "This is broken"
end
```

##Usage

Use it in a module:

``` elixir
defmodule ExNoteExampleModule do
  use ExNote

  todo "Test this"
  fixme "This is broken"
end
```

The module will contain a couple functions:

``` elixir
# Retrieve all the notes
iex(1)> ExNoteExampleModule.notes
%{fixme: [%{line: 5, note: "This is broken"}],
  todo: [%{line: 4, note: "Test this"}]}

# Get all `todo` notes
iex(2)> ExNoteExampleModule.todos
[%{line: 4, note: "Test this"}]


# Get all `optimize` notes
iex(3)> ExNoteExampleModule.optimizes
nil

# Get all `fixme` notes
iex(4)> ExNoteExampleModule.fixmes
[%{line: 5, note: "This is broken"}]

# Get all notes in a module
iex(5)> ExNote.get_notes(ExNoteExampleModule)
%{fixme: [%{line: 5, note: "This is broken"}],
  todo: [%{line: 4, note: "Test this"}]}
```
