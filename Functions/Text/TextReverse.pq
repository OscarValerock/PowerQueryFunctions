let
    // Define metadata for the function, describing its purpose and usage.
    metaDocumentation = type function (
        txt as (type text meta [
            Documentation.FieldCaption = "Input text",
            Formatting.IsMultiLine = false,
            Formatting.IsCode = false
        ])
    ) as text meta [
        Documentation.Name = "Text Reverse",
        Documentation.Description = "Reverses the order of characters in a text value.",
        Documentation.Examples =  {[Description =  " ", Code = " TextReverse(""Hello World!"") ", Result = " !dlroW olleH "]}
    ],
    // Define the main function
    myFunction = (txt as text) => Text.Combine(List.Reverse(Text.ToList(txt)))

in
    // Apply the function metadata to myFunction.
    Value.ReplaceType(myFunction, metaDocumentation)