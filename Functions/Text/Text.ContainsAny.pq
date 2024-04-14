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
                Description = " TODO ", 
                Code = " TODO ", 
                Result = " TODO "
            ]
      }
    ],
    myFunction =
        (txt as text, substrings as list, optional comparer as function) as logical =>
            let
                Matches = List.Select(substrings, (substr) => Text.Contains(txt, substr, comparer)),
                Result = not List.IsEmpty(Matches)
            in
                Result
in
    // Apply the function metadata to myFunction.
    Value.ReplaceType(myFunction, metaDocumentation)