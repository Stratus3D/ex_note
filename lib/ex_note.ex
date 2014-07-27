defmodule ExNote do
  def get_notes(project, version, options) do
  end

  def get_todos(project, version, options) do
    todo_options = options # modify options
    get_notes(project, version, todo_options)
  end

  def get_fixmes(project, version, options) do
    fixme_options = options # modify options
    get_notes(project, version, fixme_options)
  end
end
