let
    // Step 1: Define metadata for each parameter describing its purpose and usage
    metaDocumentation = type function (
        parameter1 as (type text meta [
            Documentation.FieldCaption = " parameter1 field caption ",
            Documentation.FieldDescription = " parameter1 field description ",
            Documentation.SampleValues = {" parameter1 sample value "},
            // Documentation.AllowedValues = {"Value1", "Value2", "Value3"},
            Formatting.IsMultiLine = false,
            Formatting.IsCode = false
        ]),
        parameter2 as (type number meta [
            Documentation.FieldCaption = " parameter2 field caption ",
            Documentation.FieldDescription = " parameter2 field description ",
            Documentation.SampleValues = {200},
            // Documentation.AllowedValues = {100,200,300},
            Formatting.IsMultiLine = false,
            Formatting.IsCode = false
        ]),
        optional parameter3 as (type nullable logical meta [
            Documentation.FieldCaption = " parameter3 list allowed values ",
            Documentation.FieldDescription = "parameter3 field description ",
            Documentation.SampleValues = {"True", "False"},
            Documentation.AllowedValues = {true,false},
            Formatting.IsMultiLine = false,
            Formatting.IsCode = false
        ])
    ) as list 
    // Step 2: Define global metadata in detail
    meta [

        Documentation.Name = "fn_custom_function_template",
        Documentation.Author = "Function Author's Name",
        Documentation.InspiredBy = "Name of Original Author / Inspiration",
        Documentation.LongDescription = 
        "    
                <p><b>  Template Title  </b></p>

                <li>------------------------------------------------------</li>
                
                <li><b>  Creator: </b> Name  </li>
                <li><b>  LinkedIn: </b>  https://www.linkedin.com/in/userprofile/  </li>
                <li><b>  Web: </b> https://github.com/userprofile  </li>
                <li><b>  Acknowledgements: </b> Name  </li>
                <li><b>  Source: </b> https://www.website.com  </li>

                <li>------------------------------------------------------</li>

                <li><b>  Editor: </b>  Oscar Martinez  </li>
                <li><b>  Web: </b>  https://bibb.pro  </li>
                <li><b>  LinkedIn: </b>  https://www.linkedin.com/in/oscarmartinezv/  </li>

                <li>------------------------------------------------------</li>

                <p><b>  Function Description:  </b></br>
                This paragraph provides space for a thorough description of the custom function
                
                <p><b>  Parameters Description:  </b></br>
                <ul>
                    <li><b>  • parameter1:  </b>  Parameter1 description. <code> (eg: TextValue ) </code> </li>
                    <li><b>  • parameter2:  </b>  Parameter2 description. <code> (eg: 200) </code> </li>
                    <li><b>  • parameter3:  </b>  Parameter3 description. <code> (eg: true) </code> </li>
                    
                </ul>

                <b>  Returns:  </b></br>
                A custom column.

                <p><b>  Formula Bar (fx) Output:  </b></br>
                <code>  fn_custom_function_template( TextValue, 200, true )  </code>
                
            "
    ],
    
  // Define the main function and parameters
  myFunction = (parameter1 as text, parameter2 as number, optional parameter3 as nullable logical) =>

    let invoke_custom_function =
    // paste your custom function here
    // _______________________________ \\
            let
              test_parameter3 = if (parameter3 ?? true) = true then -1 else 0, 
              variable = parameter2,
              response = parameter1 * test_parameter3
            in
              response
    // _______________________________ \\
    in invoke_custom_function,

    replaceMetaData = Value.ReplaceType(myFunction, metaDocumentation)
        
  in
    replaceMetaData
