%{
  configs: [
    %{
      name: "default",
      files: %{
        included: ["lib/", "src/", "web/", "apps/"],
        excluded: ["priv/"]
      },
      plugins: [],
      requires: [],
      strict: false,
      parse_timeout: 5000,
      color: true
      # checks: %{
      #   enabled: [
      #     {Credo.Check.Design.AliasUsage, priority: :low},
      #     # ... other checks omitted for readability ...
      #   ]
      # }
    }
  ]
}
