defmodule Zout.Utils do
  def bang!({:ok, value}), do: value
  def bang!(:error), do: raise(RuntimeError, message: "got error")
  def bang!({:error, message}), do: raise(RuntimeError, message: message)
end
