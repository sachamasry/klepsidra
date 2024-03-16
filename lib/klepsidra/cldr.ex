defmodule Klepsidra.Cldr do
  use Cldr,
    locales: ["en"],
    default_locale: "en",
    providers: [Cldr.Number, Cldr.Unit, Cldr.List]
end
