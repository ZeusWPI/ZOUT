defmodule ZoutWeb.Cldr do
  use Cldr,
    locales: ["nl"],
    providers: [Cldr.Number, Cldr.Calendar, Cldr.DateTime]
end
