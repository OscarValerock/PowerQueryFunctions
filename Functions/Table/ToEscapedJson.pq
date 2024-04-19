//Function documentation template by Oscar Martinez https://bibb.pro
let
    // Define metadata for the function, describing its purpose and usage.
    metaDocumentation = type function (
        LoadedData as (type table meta [
            Documentation.FieldCaption = "Data table",
            Formatting.IsMultiLine = false,
            Formatting.IsCode = false
        ]),
        chunkSize as (type number meta [
            Documentation.FieldCaption = "Size of chunks",
            Documentation.SampleValues = {0,10},
            Formatting.IsMultiLine = false,
            Formatting.IsCode = false
        ])
    ) as any meta [
        Documentation.Name = "TableToEscapedJson",
        Documentation.LongDescription = 
            //This is the description of the documentation, it only accepts a handful of HTML tags for formatting.
            "    
                <p><b>Table to escaped JSON</b></p>
                <li><b>Creator: </b>Oscar Martinez</li>
                <li><b>LinkedIn:</b> https://www.linkedin.com/in/oscarmartinezv/</li>
                <li><b>Web: </b>https://bibb.pro</li>

                <p>The Power Query function myFunction is designed to prepare a large dataset for Language Model (LLM) analysis by chunking the data into smaller, manageable pieces.</p>
                <p>The function takes two paramenters:</p>
                <ul>
                    <li><b>Data table: </b>The table to chunk, and set into escaped JSON format</li>
                    <li><b>Size of chunks: </b>How many recods on each chunk</li>
                </ul>
            "
    ],
    // Define the main function
    myFunction = (LoadedData as table, chunkSize as number) as any =>
        let 
            // Function to convert a table to a JSON string with escaped characters
            ConvertTableToJsonString = (dataTable as table) =>
                let
                    // Convert the table to a list of records
                    RecordsFromTable = Table.ToRecords(dataTable),
                    
                    // Convert the list of records to JSON text
                    JsonTextFromRecords = Lines.FromBinary(Json.FromValue(RecordsFromTable), null, null, 1252),
                    
                    // Convert the JSON text lines to a table
                    TableFromJsonText = Table.FromList(JsonTextFromRecords, Splitter.SplitByNothing(), null, null, ExtraValues.Error),
                    
                    // Escape double quotes in the JSON strings
                    EscapedJsonStrings = Table.TransformColumns(TableFromJsonText, {"Column1", each Text.Replace(_, """", "\""")})
                in
                    EscapedJsonStrings,
                

            // Add an Index column for chunking data in API requests
            DataWithIndex = Table.AddIndexColumn(LoadedData, "Index", 0, 1, Int64.Type),

            // Calculate group numbers for chunking data
            DataWithGroupNumbers = Table.TransformColumns(DataWithIndex, {"Index", each Number.IntegerDivide(_, chunkSize), Int64.Type}),

            // Group rows by group number
            GroupedData = Table.Group(DataWithGroupNumbers, {"Index"}, {{"Grouped Data", each _, type table}}),

            // Convert grouped data into JSON for analysis
            JsonStringsFromGroupedData = Table.TransformColumns(GroupedData, {"Grouped Data", each ConvertTableToJsonString(_)}),

            // Expand JSON strings into columns for analysis
            ExpandedJsonForAnalysis = Table.ExpandTableColumn(JsonStringsFromGroupedData, "Grouped Data", {"Column1"}, {"Escaped JSON"})

        in
            ExpandedJsonForAnalysis
    in
    // Apply the function metadata to myFunction.
    Value.ReplaceType(myFunction, metaDocumentation)