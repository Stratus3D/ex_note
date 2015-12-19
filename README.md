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

But it turns out that isn't very easy to do, since I would need to take all the AST for the module and preprocess it before compiling. By importing the `ExNote` module it becomes much easier. I can simply use the `todo`, `fixme` and `optimize` macros:

``` elixir
defmodule ExNoteExampleModule do
  import ExNote

  todo "Test this"
  fixme "This is broken"
end
```
