defmodule Klepsidra.Cldr do
  use Cldr.Unit.Additional

  use Cldr,
    locales: ["en"],
    default_locale: "en",
    providers: [Cldr.Number, Cldr.Unit, Cldr.List]

  unit_localization(:six_minute_block, "en", :long,
    nominative: %{
      one: "{0} six minute block",
      other: "{0} six minute blocks"
    },
    display_name: "six minute block"
  )
  unit_localization(:quarter_hour, "en", :long,
    nominative: %{
      one: "{0} quarter hour",
      other: "{0} quarter hours"
    },
    display_name: "quarter hour"
  )
  unit_localization(:half_hour, "en", :long,
    nominative: %{
      one: "{0} half hour",
      other: "{0} half hour blocks"
    },
    display_name: "half hour"
  )
end
