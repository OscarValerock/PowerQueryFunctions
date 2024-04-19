let
    // Define metadata for the function, describing its purpose and usage.
    metaDocumentation = type function ( ) as date meta [
        Documentation.Name = "Date.Today",
        Documentation.LongDescription = 
            //This is the description of the documentation, it only accepts a handful of HTML tags for formatting.
            "    
                <p>Returns the current date value on the system.</p>
                <p>This function is a shortcut for Date.From(DateTime.FixedLocalNow())</p>
            ",
    Documentation.Examples = {
        [
            Description = "  ", 
            Code = "Date.Today()", 
            Result = Text.From(Date.From(DateTime.FixedLocalNow()))
        ]
    }],
    // Define the main function
    myFunction = () as date => Date.From(DateTime.FixedLocalNow())
in
    // Apply the function metadata to myFunction.
    Value.ReplaceType(myFunction, metaDocumentation)
