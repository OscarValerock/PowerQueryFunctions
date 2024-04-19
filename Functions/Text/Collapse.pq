let
    // Define metadata for the function, describing its purpose and usage.
    metaDocumentation = type function (
            txt as (type text meta [
            Documentation.FieldCaption = "The text to search"
        ]),
            characters as (type text meta [
            Documentation.FieldCaption = "Character(s) to collapse"
        ]),
            optional seperator as (type text meta [
            Documentation.FieldCaption = "Seperator to use in final result"
        ])
    ) as text meta [
        Documentation.Name = "Text.Collapse",
        Documentation.Author = "Alexis Olson",
        Documentation.LongDescription = 
            // This is the description of the documentation, it only accepts a handful of HTML tags for formatting.
            "
                Collapses multiple characters into a single seperator.
                <p>See the illustrative examples listed below.</p>
                <li><b>Author: </b>Alexis Olson</li>
                <li><b>LinkedIn: </b>https://www.linkedin.com/in/alexis-olson-81726818/</li>
            ",
        Documentation.Examples = {
            [
                Description = " Simple usage is similar to an inner and outer trim. ", 
                Code = " Text.Collapse(""--a----b--c---d---"", ""-"") ", 
                Result = " a-b-c-d "
            ],
            [
                Description = " Multiple characters can be collapsed and the result combined using a different separator. ", 
                Code = " Text.Collapse(""[(a-..-b).-.-.-.((c-..-d))]"", ""[(-.)]"", "" <=> "") ", 
                Result = " a <=> b <=> c <=> d "
            ]
      }
    ],
    myFunction =
        (txt as text, characters as text, optional seperator as text) as text =>
            let
                Split = Text.SplitAny(txt, characters),
                RemoveEmpty = List.Select(Split, each _ <> null and _ <> ""),
                Seperator = seperator ?? Text.Start(characters, 1),
                Result = Text.Combine(RemoveEmpty, Seperator)
            in
                Result
in
    // Apply the function metadata to myFunction.
    Value.ReplaceType(myFunction, metaDocumentation)
