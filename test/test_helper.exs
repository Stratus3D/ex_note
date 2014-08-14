# Compile the test modules
Mix.Task.run "exnote.setup"

# Set the at_exit callback
System.at_exit(fn(_state) ->
  Mix.Task.run "exnote.teardown"
end)

# Finally run all the tests
ExUnit.start()
