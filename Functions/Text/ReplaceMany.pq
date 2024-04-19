let
    // Define metadata for the function, describing its purpose and usage.
    metaDocumentation = type function (
            txt as (type text meta [
            Documentation.FieldCaption = "Text to modify"
        ]),
            replacements as (type {text} meta [
            Documentation.FieldCaption = "List of {old, new} text pairs"
        ])
    ) as text meta [
        Documentation.Name = "Text.ReplaceMany",
        Documentation.Author = "Alexis Olson",
        Documentation.LongDescription = 
            // This is the description of the documentation, it only accepts a handful of HTML tags for formatting.
            "
                Performs the given replacements given by the list parameter in that order.
                <p>The replacement list must contain text pairs where each pair is an old value and new value.</p>
                <li><b>Author: </b>Alexis Olson</li>
                <li><b>LinkedIn: </b>https://www.linkedin.com/in/alexis-olson-81726818/</li>
            ",
        Documentation.Examples = {
            [
                Description = " Make three substitutions: š -> sh, Č -> Ch, and ž -> zh ", 
                Code = "Text.ReplaceMany(""Boštjan Černež"", {{""š"", ""sh""}, {""Č"", ""Ch""}, {""ž"", ""zh""}})", 
                Result = "Boshtjan Chernezh"
            ]
      }
    ],
    myFunction =
        (txt as text, replacements as list) as text =>
            List.Accumulate(replacements, txt, (s, c) => Text.Replace(s, c{0}, c{1}))
in
    // Apply the function metadata to myFunction.
    Value.ReplaceType(myFunction, metaDocumentation)
