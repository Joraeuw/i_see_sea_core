%{
  configs: [
    %{
      name: "default",
      files: %{
        included: ["lib/"],
        excluded: ["test/"]
      },
      checks: [
        {Credo.Check.Refactor.Nesting, max_nesting: 4}
      ]
    }
  ]
}
