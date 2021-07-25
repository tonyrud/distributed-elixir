defmodule GlobalBackgroundJob.DatabaseCleaner.Runner do
  @moduledoc """
  Runner module, only in charge of executing a mocked db cleaner.
  """
  require Logger

  def execute do
    random = :rand.uniform(1_000)

    Process.sleep(random)

    Logger.info("#{__MODULE__} #{random} records deleted")
  end
end
