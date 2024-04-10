//Function documentation template by Oscar Martinez https://bibb.pro
let
    // Define metadata for the function, describing its purpose and usage.
    metaDocumentation = type function (
        argument1 as (type text meta [
            Documentation.FieldCaption = "Argument1 field caption",
            Documentation.SampleValues = {"Argument1 sample value"},
            Formatting.IsMultiLine = false,
            Formatting.IsCode = false
        ]),
        argument2 as (type number meta [
            Documentation.FieldCaption = "Argument2 field caption",
            Documentation.SampleValues = {0},
            Formatting.IsMultiLine = false,
            Formatting.IsCode = false
        ])
    ) as any meta [
        Documentation.Name = "Function Name",
        Documentation.LongDescription = 
            //This is the description of the documentation, it only accepts a handful of HTML tags for formatting.
            "    
                <p><b>Function Name</b></p>
                <li><b>Creator: </b>Creator Name.</li>
                <li><b>LinkedIn:</b> https://www.linkedin.com/in/.</li>
                <li><b>Web: </b>hattps://app.powerbi.com</li>

                <p>This is a paragraph</p>
                <p>The fucntion takes two paramenters:</p>
                <ul>
                    <li><b>parameter1: </b>This is a description of paramenter1.</li>
                    <li><b>parameter2: </b>This is a description of paramenter1.</li>
                </ul>
                <p><code>his is a paragraph with some code</code></p>
                <p>This is another paragraph</p>
            "
    ],
    // Define the main function
    myFunction = (argument1 as text, argument2 as number) as any=> 
        let
            variable = argument2,
            Response = argument1
        in
            Response 
    in
    // Apply the function metadata to myFunction.
    Value.ReplaceType(myFunction, metaDocumentation)