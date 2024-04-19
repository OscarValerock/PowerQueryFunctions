let
    // Define metadata for the function, describing its purpose and usage.
    metaDocumentation = type function (
            txt as (type text meta [
            Documentation.FieldCaption = "The text to search"
        ]),
            substrings as (type {text} meta [
            Documentation.FieldCaption = "A list of substrings to search for"
        ]),
            optional comparer as (type function meta [
            Documentation.FieldCaption = "Comparer function to pass into Text.Contains"
        ])
    ) as logical meta [
        Documentation.Name = "Text.ContainsAny",
        Documentation.Author = "Alexis Olson",
        Documentation.LongDescription = 
            // This is the description of the documentation, it only accepts a handful of HTML tags for formatting.
            "
                Checks whether the input text contains any of the substrings from the input list.
                <p>Returns true if any of the substrings are found.</p>
                <li><b>Author: </b>Alexis Olson</li>
                <li><b>LinkedIn: </b>https://www.linkedin.com/in/alexis-olson-81726818/</li>
            ",
        Documentation.Examples = {
            [
                Description = " Check if a sentence is a pangram. ", 
                Code = " Text.ContainsAll(""Hello World!"", {""and"", ""or""}) ", 
                Result = " TRUE "
            ],
            [
                Description = " By default, comparison is case-sensitive. ", 
                Code = " Text.ContainsAny(""Hello World!"", {""hello"", ""world""}) ", 
                Result = " FALSE "
            ],
            [
                Description = " Comparison can be done using a case-insenitive comparer. ", 
                Code = " Text.ContainsAny(""Hello World!"", {""hello"", ""kitty""}, Comparer.OrdinalIgnoreCase ) ", 
                Result = " TRUE "
            ]
      }
    ],
    myFunction =
        (txt as text, substrings as list, optional comparer as function) as logical =>
            let
                Matches = List.Select(substrings, (substr) => Text.Contains(txt, substr, comparer)),
                Result = not List.IsEmpty(Matches) // At least one substring is matched
            in
                Result
in
    // Apply the function metadata to myFunction.
    Value.ReplaceType(myFunction, metaDocumentation)
