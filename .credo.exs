%{
  configs: [
    %{
      name: "default",
      files: %{
        included: ["lib/"],
        excluded: []
      },
      checks: [
        {Credo.Check.Design.TagTODO, false},
        {Credo.Check.Readability.MaxLineLength, priority: :low, max_length: 120},
        # Enable a bunch of normally disabled tasks
        {Credo.Check.Consistency.MultiAliasImportRequireUse},
        {Credo.Check.Readability.Specs},
        {Credo.Check.Design.DuplicatedCode},
        {Credo.Check.Refactor.ABCSize},
        {Credo.Check.Refactor.AppendSingleItem},
        {Credo.Check.Refactor.DoubleBooleanNegation},
        {Credo.Check.Refactor.VariableRebinding},
        {Credo.Check.Warning.MapGetUnsafePass},
        {Credo.Check.Warning.UnsafeToAtom}
      ]
    }
  ]
}
