let
    // Step 1: Define metadata for each parameter describing its purpose and usage
    metaDocumentation = type function (
        string as (type text meta [
            Documentation.FieldCaption = "String",
            Documentation.SampleValues = {"ä,a;ö,o"},
            // Documentation.AllowedValues = {"Value1", "Value2", "Value3"},
            Formatting.IsMultiLine = false,
            Formatting.IsCode = false
        ])
    ) as list 
    // Step 2: Define global metadata in detail
    meta [
        Documentation.Name = "Text.ListFromString",
        Documentation.LongDescription = 
        "    
                <p><b>  Template Title  </b></p>

                <li>------------------------------------------------------</li>
                
                <li><b>  Web: </b>  https://bibb.pro  </li>
                <li><b>  LinkedIn: </b>  https://www.linkedin.com/in/oscarmartinezv/  </li>

                <li>------------------------------------------------------</li>

                <p><b>  Function Description:  </b></br>
                Converts a string separated by commas and semicolons into a list</b></br></br>

                <b>  Returns:  </b></br>
                A list.
                
            ",
        Documentation.Examples = {
            [
                Description = "Converts a string separated by commas and semicolons into a list", 
                Code = "Text.ListFromString(""ä,a;ö,o"")", 
                Result = "{{""ü"", ""u""},{""ö"", ""o""}}"
            ]
        }
    ],
    
  // Define the main function and parameters
  myFunction = (string as text) as any =>

    let
        // Your original string
        OriginalText = string,
        
        // Split the string into rows by semicolon
        SplitPairs = Text.Split(OriginalText, ";"),
        
        // Convert each pair into a list by splitting by comma
        ConvertToLists = List.Transform(SplitPairs, each Text.Split(_, ","))
    in
        ConvertToLists

  in  

    Value.ReplaceType(myFunction, metaDocumentation)