defmodule Klepsidra.Cldr do
  use Cldr.Unit.Additional

  use Cldr,
    locales: ["en"],
    default_locale: "en",
    providers: [Cldr.Number, Cldr.Unit, Cldr.List]

  unit_localization(:five_minute_increment, "en", :long,
    nominative: %{
      one: "{0} five minute increment",
      other: "{0} five minute increments"
    },
    display_name: "Five minute increment"
  )
  unit_localization(:six_minute_increment, "en", :long,
    nominative: %{
      one: "{0} six minute increment",
      other: "{0} six minute increments"
    },
    display_name: "Six minute increment"
  )
  unit_localization(:ten_minute_increment, "en", :long,
    nominative: %{
      one: "{0} ten minute increment",
      other: "{0} ten minute increments"
    },
    display_name: "Ten minute increment"
  )
  unit_localization(:half_hour, "en", :long,
    nominative: %{
      one: "{0} half hour",
      other: "{0} half hour increments"
    },
    display_name: "Half hour"
  )
end
