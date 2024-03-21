defmodule Klepsidra.Cldr do
  use Cldr.Unit.Additional

  use Cldr,
    locales: ["en"],
    default_locale: "en",
    providers: [Cldr.Number, Cldr.Unit, Cldr.List]

  # 5 minute increment
  unit_localization(:five_minute_increment, "en", :long,
    nominative: %{
      one: "{0} five minute increment",
      other: "{0} five minute increments"
    },
    display_name: "5 minutes"
  )
  unit_localization(:five_minute_increment, "en", :short,
    nominative: %{
      one: "{0} five mins",
      other: "{0} five mins"
    },
    display_name: "5 mins"
  )
  unit_localization(:five_minute_increment, "en", :narrow,
    nominative: %{
      one: "{0} five min",
      other: "{0} five min"
    },
    display_name: "5 min"
  )

  # 6 minute increment
  unit_localization(:six_minute_increment, "en", :long,
    nominative: %{
      one: "{0} six minute increment",
      other: "{0} six minute increments"
    },
    display_name: "6 minutes"
  )
  unit_localization(:six_minute_increment, "en", :short,
    nominative: %{
      one: "{0} six mins",
      other: "{0} six mins"
    },
    display_name: "6 mins"
  )
  unit_localization(:six_minute_increment, "en", :narrow,
    nominative: %{
      one: "{0} six min",
      other: "{0} six min"
    },
    display_name: "6 min"
  )

  # 10 minute increment
  unit_localization(:ten_minute_increment, "en", :long,
    nominative: %{
      one: "{0} ten minute increment",
      other: "{0} ten minute increments"
    },
    display_name: "10 minute increment"
  )
  unit_localization(:ten_minute_increment, "en", :short,
    nominative: %{
      one: "{0} ten mins",
      other: "{0} ten mins"
    },
    display_name: "10 mins"
  )
  unit_localization(:ten_minute_increment, "en", :narrow,
    nominative: %{
      one: "{0} ten min",
      other: "{0} ten min"
    },
    display_name: "10 min"
  )

  # 12 minute increment
  unit_localization(:twelve_minute_increment, "en", :long,
    nominative: %{
      one: "{0} twelve minute increment",
      other: "{0} twelve minute increments"
    },
    display_name: "12 minute increment"
  )
  unit_localization(:twelve_minute_increment, "en", :short,
    nominative: %{
      one: "{0} twelve mins",
      other: "{0} twelve mins"
    },
    display_name: "12 mins"
  )
  unit_localization(:twelve_minute_increment, "en", :narrow,
    nominative: %{
      one: "{0} twelve min",
      other: "{0} twelve min"
    },
    display_name: "12 min"
  )

  # 15 minute increment
  unit_localization(:fifteen_minute_increment, "en", :long,
    nominative: %{
      one: "{0} fifteen minute increment",
      other: "{0} fifteen minute increments"
    },
    display_name: "15 minute increment"
  )
  unit_localization(:fifteen_minute_increment, "en", :short,
    nominative: %{
      one: "{0} fifteen mins",
      other: "{0} fifteen mins"
    },
    display_name: "15 mins"
  )
  unit_localization(:fifteen_minute_increment, "en", :narrow,
    nominative: %{
      one: "{0} fifteen min",
      other: "{0} fifteen min"
    },
    display_name: "15 min"
  )

  # 18 minute increment
  unit_localization(:eighteen_minute_increment, "en", :long,
    nominative: %{
      one: "{0} eighteen minute increment",
      other: "{0} eighteen minute increments"
    },
    display_name: "18 minute increment"
  )
  unit_localization(:eighteen_minute_increment, "en", :short,
    nominative: %{
      one: "{0} eighteen mins",
      other: "{0} eighteen mins"
    },
    display_name: "18 mins"
  )
  unit_localization(:eighteen_minute_increment, "en", :narrow,
    nominative: %{
      one: "{0} eighteen min",
      other: "{0} eighteen min"
    },
    display_name: "18 min"
  )

  # 20 minute increment
  unit_localization(:twenty_minute_increment, "en", :long,
    nominative: %{
      one: "{0} twenty minute increment",
      other: "{0} twenty minute increments"
    },
    display_name: "20 minute increment"
  )
  unit_localization(:twenty_minute_increment, "en", :short,
    nominative: %{
      one: "{0} twenty mins",
      other: "{0} twenty mins"
    },
    display_name: "20 mins"
  )
  unit_localization(:twenty_minute_increment, "en", :narrow,
    nominative: %{
      one: "{0} twenty min",
      other: "{0} twenty min"
    },
    display_name: "20 min"
  )

  # 24 minute increment
  unit_localization(:twenty_four_minute_increment, "en", :long,
    nominative: %{
      one: "{0} twenty-four minute increment",
      other: "{0} twenty-four minute increments"
    },
    display_name: "24 minute increment"
  )
  unit_localization(:twenty_four_minute_increment, "en", :short,
    nominative: %{
      one: "{0} twenty-four mins",
      other: "{0} twenty-four mins"
    },
    display_name: "24 mins"
  )
  unit_localization(:twenty_four_minute_increment, "en", :narrow,
    nominative: %{
      one: "{0} twenty-four min",
      other: "{0} twenty-four min"
    },
    display_name: "24 min"
  )

  # 30 minute increment
  unit_localization(:thirty_minute_increment, "en", :long,
    nominative: %{
      one: "{0} thirty minute increment",
      other: "{0} thirty minute increments"
    },
    display_name: "30 minute increment"
  )
  unit_localization(:thirty_minute_increment, "en", :short,
    nominative: %{
      one: "{0} thirty mins",
      other: "{0} thirty mins"
    },
    display_name: "30 mins"
  )
  unit_localization(:thirty_minute_increment, "en", :narrow,
    nominative: %{
      one: "{0} thirty min",
      other: "{0} thirty min"
    },
    display_name: "30 min"
  )

  # 36 minute increment
  unit_localization(:thirty_six_minute_increment, "en", :long,
    nominative: %{
      one: "{0} thirty-six minute increment",
      other: "{0} thirty-six minute increments"
    },
    display_name: "36 minute increment"
  )
  unit_localization(:thirty_six_minute_increment, "en", :short,
    nominative: %{
      one: "{0} thirty-six mins",
      other: "{0} thirty-six mins"
    },
    display_name: "36 mins"
  )
  unit_localization(:thirty_six_minute_increment, "en", :narrow,
    nominative: %{
      one: "{0} thirty-six min",
      other: "{0} thirty-six min"
    },
    display_name: "36 min"
  )

  # 45 minute increment
  unit_localization(:fourty_five_minute_increment, "en", :long,
    nominative: %{
      one: "{0} fourty-five minute increment",
      other: "{0} fourty-five minute increments"
    },
    display_name: "45 minute increment"
  )
  unit_localization(:fourty_five_minute_increment, "en", :short,
    nominative: %{
      one: "{0} fourty-five mins",
      other: "{0} fourty-five mins"
    },
    display_name: "45 mins"
  )
  unit_localization(:fourty_five_minute_increment, "en", :narrow,
    nominative: %{
      one: "{0} fourty-five min",
      other: "{0} fourty-five min"
    },
    display_name: "45 min"
  )

  # 90 minute increment
  unit_localization(:ninety_minute_increment, "en", :long,
    nominative: %{
      one: "{0} ninety minute increment",
      other: "{0} ninety minute increments"
    },
    display_name: "90 minute increment"
  )
  unit_localization(:ninety_minute_increment, "en", :short,
    nominative: %{
      one: "{0} ninety mins",
      other: "{0} ninety mins"
    },
    display_name: "90 mins"
  )
  unit_localization(:ninety_minute_increment, "en", :narrow,
    nominative: %{
      one: "{0} ninety min",
      other: "{0} ninety min"
    },
    display_name: "90 min"
  )

  # 120 minute increment
  unit_localization(:one_hundred_twenty_minute_increment, "en", :long,
    nominative: %{
      one: "{0} one hundred twenty minute increment",
      other: "{0} one hundred twenty minute increments"
    },
    display_name: "2 hour increment"
  )
  unit_localization(:one_hundred_twenty_minute_increment, "en", :short,
    nominative: %{
      one: "{0} one-twenty mins",
      other: "{0} one-twenty mins"
    },
    display_name: "2 hours"
  )
  unit_localization(:one_hundred_twenty_minute_increment, "en", :narrow,
    nominative: %{
      one: "{0} one-twenty min",
      other: "{0} one-twenty min"
    },
    display_name: "2 hour increment"
  )
end
