# Script for populating the database with pings. You can run it as:
#
#     mix run priv/repo/seeds.exs
alias Zout.Repo

months_ago = Timex.now() |> Timex.shift(months: -3)

interval = Timex.Interval.new(from: months_ago, until: Timex.now(), step: [minutes: 10])

options = [:working, :failing, :offline]

Enum.each(interval, fn stamp ->
  st = DateTime.from_naive!(stamp, "Etc/UTC") |> DateTime.truncate(:second)
  %Zout.Data.Ping{
    stamp: st,
    project_id: 4,
    status: Enum.random(options)
  } |> Repo.insert!()
  %Zout.Data.Ping{
    stamp: st,
    project_id: 5,
    status: Enum.random(options)
  } |> Repo.insert!()
  %Zout.Data.Ping{
    stamp: st,
    project_id: 13,
    status: Enum.random(options)
  } |> Repo.insert!()
end)
