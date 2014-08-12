defmodule ExNote do
<<<<<<< HEAD
  @todo "Improve documentation"
  @moduledoc """
  Module for retrieving module attributes and the associated blocks of code
  """

  @doc "get projects notes"
  def get_notes(project, version, options, tag) do
    # modify options
    get_notes(project, version, options)
  end

  def get_notes(project, version, options) do
    %{}
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
