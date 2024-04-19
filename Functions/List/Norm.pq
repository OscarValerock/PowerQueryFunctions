let
    // Define metadata for the function, describing its purpose and usage.
    metaDocumentation = type function (
        inputList as (type list meta [
            Documentation.FieldCaption = "List input"
        ]),
        optional p as (type number meta [
            Documentation.FieldCaption = "Select any p > 0 to use the Lp norm"
        ])
    ) as number meta [
        Documentation.Name = "List.Norm",
        Documentation.Author = "Alexis Olson",
        Documentation.LongDescription = 
            // This is the description of the documentation, it only accepts a handful of HTML tags for formatting.
            "
                Returns the norm of the list.
                <p>The default is the standard L² Euclidean norm but the optional argument allows any Lp norm.</p>
                <li><b>Author: </b>Alexis Olson</li>
                <li><b>LinkedIn: </b>https://www.linkedin.com/in/alexis-olson-81726818/</li>
            ",
        Documentation.Examples = {
            [
                Description = " Default L² (Euclidean) norm. ", 
                Code = "List.Norm({1, 2, 3})", 
                Result = "3.7416573867739413 = √(1² + 2² + 3²)"
            ],
            [
                Description = " L¹ (Taxicab or Manhattan) norm. ", 
                Code = "List.Norm({1, -1, 1, 0}, 1)", 
                Result = "3 = |1| + |-1| + |1| + |0|"
            ],
            [
                Description = " L∞ (infinity or maximum) norm. ", 
                Code = "List.Norm({3, -4}, Number.PositiveInfinity)", 
                Result = "4"
            ]
      }
    ],
    myFunction =
        (L as list, optional p as number) as number =>
        let
            AbsL = List.Transform(L, Number.Abs),
            PowerP = List.Transform(AbsL, each Number.Power(_, p ?? 2)),
            RootP = Number.Power(List.Sum(PowerP), 1 / (p ?? 2)),
            Result =
                if p = Number.PositiveInfinity
                then List.Max(AbsL)
                else RootP
        in
            Result
in
    // Apply the function metadata to myFunction.
    Value.ReplaceType(myFunction, metaDocumentation)
