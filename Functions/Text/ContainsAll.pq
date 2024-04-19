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
        Documentation.Name = "Text.ContainsAll",
        Documentation.Author = "Alexis Olson",
        Documentation.LongDescription = 
            // This is the description of the documentation, it only accepts a handful of HTML tags for formatting.
            "
                Checks whether the input text contains all of the substrings from the input list.
                <p>Returns true if all of the substrings are found.</p>
                <li><b>Author: </b>Alexis Olson</li>
                <li><b>LinkedIn: </b>https://www.linkedin.com/in/alexis-olson-81726818/</li>
            ",
        Documentation.Examples = {
            [
                Description = " Check if a sentence is a pangram (contains all letters of the alphabet). ", 
                Code = " Text.ContainsAll(""The quick brown fox jumps over the lazy dog."", {""a""..""z""}) ", 
                Result = " TRUE "
            ],
            [
                Description = " By default, comparison is case-sensitive and the following has an S but no s. ", 
                Code = " Text.ContainsAny(""Sphinx of black quartz, judge my vow."", {""a""..""z""}) ", 
                Result = " FALSE "
            ],
            [
                Description = " Comparison can be done using a case-insenitive comparer. ", 
                Code = " Text.ContainsAny(""Sphinx of black quartz, judge my vow."", {""a""..""z""}, Comparer.OrdinalIgnoreCase ) ", 
                Result = " TRUE "
            ]
      }
    ],
    myFunction =
        (txt as text, substrings as list, optional comparer as function) as logical =>
            let
                Matches = List.Select(substrings, (substr) => Text.Contains(txt, substr, comparer)),
                Result = (substrings = Matches) // All substrings are matched
            in
                Result
in
    // Apply the function metadata to myFunction.
    Value.ReplaceType(myFunction, metaDocumentation)
