let
    // Define metadata for the function, describing its purpose and usage.
    metaDocumentation = type function (
            inputList as (type list meta [
            Documentation.FieldCaption = "List to flatten"
        ])
    ) as list meta [
        Documentation.Name = "List.Flatten",
        Documentation.Author = "Alexis Olson",
        Documentation.LongDescription = 
            // This is the description of the documentation, it only accepts a handful of HTML tags for formatting.
            "
                Returns an flattened version of a list with all nesting removed.
                <p></p>
                <li><b>Author: </b>Alexis Olson</li>
                <li><b>LinkedIn: </b>https://www.linkedin.com/in/alexis-olson-81726818/</li>
            ",
        Documentation.Examples = {
            [
                Description = " Flatten a nested list with mixed levels into a simple list. ", 
                Code = "List.Flatten({1, {2, 3}, {1, {2, 3}}})", 
                Result = "{1, 2, 3, 1, 2, 3}"
            ]
      }
    ],
    myFunction =
        (L as list) as list =>
        let
            IsListType = (x) as logical => Value.Type(x) = List.Type,
            FlattenOneLevel = (L as list) as list =>
                List.Combine(
                    List.Transform(L, each if IsListType(_) then _ else {_})
                ),
            FlattenAll = (L as list) as list =>
                if List.MatchesAny(L, IsListType) // Check if L is nested
                then @FlattenAll(FlattenOneLevel(L))
                else L
        in
            FlattenAll(L)
in
    // Apply the function metadata to myFunction.
    Value.ReplaceType(myFunction, metaDocumentation)
