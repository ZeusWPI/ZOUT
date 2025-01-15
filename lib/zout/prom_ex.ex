defmodule Zout.PromEx do
  use PromEx, otp_app: :zout

  @impl true
  def plugins do
    [
      Zout.PromExPlugin
    ]
  end
end
