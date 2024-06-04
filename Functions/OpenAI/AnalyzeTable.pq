let
    // Step 1: Define metadata for each parameter describing its purpose and usage
    metaDocumentation = type function (
      dataTable as (type table meta [
        Documentation.FieldCaption = "Data Table"
      ]),
      responseStructureFields as (type text meta [
        Documentation.FieldCaption = "Response Structure Fields",
        Documentation.SampleValues = {"Field1,Field2,Field3"}
      ]),
      gptModel as (type text meta [
        Documentation.FieldCaption = "GPT Model",
        Documentation.SampleValues = {"gpt-3.5-turbo"}
      ]),
      openAIkey as (type text meta [
        Documentation.FieldCaption = "OpenAI Key",
        Documentation.SampleValues = {"sk-"}
      ]),
      assistantBehaviour as (type text meta [
        Documentation.FieldCaption = "Assistant Behaviour",
        Documentation.SampleValues = {"You are an international and trade customs expert"}
      ]),
      instruction as (type text meta [
        Documentation.FieldCaption = "Instruction",
        Documentation.SampleValues = {"When you return the data in the required structure..."}
      ]),
      rowsPerGroup as (type number meta [
        Documentation.FieldCaption = "Rows per Group",
        Documentation.SampleValues = {3}
      ]),
      optional testGroups as (type number meta [
        Documentation.FieldCaption = "Test Groups",
        Documentation.SampleValues = {1}
      ])
    ) as list 
    // Step 2: Define global metadata in detail
    meta [

        Documentation.Name = "OpenAI.AnalyzeTable",
        Documentation.LongDescription = 
        "    
                <p><b>  OpenAI.AnalyzeTable </b></p>

                <li>------------------------------------------------------</li>
                
                <li><b>  Creator: </b> Oscar Martinez  </li>
                <li><b>  LinkedIn: </b>  https://www.linkedin.com/in/oscarmartinezv/  </li>
                <li><b>  Web: </b> https://bibb.pro  </li>

                <li>------------------------------------------------------</li>

                <p><b>  Function Description:  </b></br>
                This function performs analysis on a given data table using the OpenAI GPT model. 
                It groups the data table into chunks based on the specified number of rows per group, 
                converts each chunk to an escaped JSON string, and then performs GPT analysis on the filtered rows. 
                
                The function returns the analyzed data in the required response structure.

                <p><b>  Parameters Description:  </b></br>
                <ul>
                  <li><b>  • Data Table:  </b>  The input data table to be analyzed. </li>
                  <li><b>  • Response Structure Fields:  </b>  A comma-separated list of fields that define the response structure. </li>
                  <li><b>  • GPT Model:  </b>  The GPT model to be used for analysis. </li>
                  <li><b>  • OpenAI Key:  </b>  The API key for accessing the OpenAI service. </li>
                  <li><b>  • Assistant Behaviour:  </b>  The behavior of the GPT assistant. </li>
                  <li><b>  • Instruction:  </b>  The instruction for the GPT assistant. </li>
                  <li><b>  • Test Groups:  </b>  The number of groups (of rows) to be used for testing. </li>
                  <li><b>  • Rows per Group:  </b>  The number of rows per group for data chunking. </li>
                </ul>
                
            "
    ],
    
  // Define the main function and parameters
  myFunction = (
    dataTable as table,
    responseStructureFields as text,
    gptModel as text,
    openAIkey as text,
    assistantBehaviour as text,
    instruction as text,
    rowsPerGroup as number,
    optional testGroups as number
) as any =>

let
    /*
    // Initialize testing parameters
    dataTable = Companies,
    responseStructureFields = "Company,Country,HSCode",
    gptModel = "gpt-3.5-turbo",
    openAIkey = "sk-",
    assistantBehaviour = "You are an international and trade customs expert",
    instruction = "When you return the data in the required structure you will asses what is the most popular product of each ""Company"" and get its harmonized system code (""HSCode"") and add this code in the ""HSCode"" field",
    testGroups = 10,
    rowsPerGroup = 10,
    */
 
    // Define function to group data table by specified rows per group

    groupDataTable = (dataTable as table) =>

        let

            // Add an index column to facilitate data chunking
            dataWithIndex = Table.AddIndexColumn(dataTable, "Group Index", 0, 1, Int64.Type),
 
            // Calculate group numbers for data chunking
            dataWithGroupNumbers = Table.TransformColumns(dataWithIndex, {"Group Index", each Number.IntegerDivide(_, rowsPerGroup), Int64.Type}),
 
            // Group rows by newly created group numbers
            groupedData = Table.Group(dataWithGroupNumbers, {"Group Index"}, {{"Grouped Data", each _, type table}})

        in

            groupedData,
 
    // Define function to convert a table to an escaped JSON string
    tableToEscapedJsonString = (dataTable as table) =>

        let

            // Convert the table to a list of records
            recordsFromTable = Table.ToRecords(dataTable),
 
            // Serialize records list to JSON text
            jsonTextFromRecords = Lines.FromBinary(Json.FromValue(recordsFromTable), null, null, 1252),
 
            // Generate a table from the JSON text lines
            tableFromJsonText = Table.FromList(jsonTextFromRecords, Splitter.SplitByNothing(), null, null, ExtraValues.Error),
 
            // Escape all double quotes in the JSON strings
            escapedJsonStrings = Table.TransformColumns(tableFromJsonText, {"Column1", each Text.Replace(_, """", "\""")})

        in

            escapedJsonStrings,
 
    // Define function to construct a dynamic JSON response structure
    jsonResponseStructure = 

        let

            // Convert comma-separated fields into a list
            keyList = Text.Split(responseStructureFields, ","),
 
            // Prefix each key in the list with a hash symbol
            prefixedKeyValues = List.Transform(keyList, each "#" & _),
 
            // Create a record from original keys and prefixed values
            dynamicRecord = Record.FromList(prefixedKeyValues, keyList),
 
            // Serialize the record to JSON string
            jsonRecord = Json.FromValue(dynamicRecord),
 
            // Format JSON string by replacing double quotes and wrapping in brackets
            formattedJsonString = "[" & Text.Replace(Lines.FromBinary(jsonRecord, null, null, 1252){0}, """", "\""") & "]"
        in
            formattedJsonString,
 
    // Define function to generate GPT model analysis body
    generateGptBody = (jsonInformation as text) => 
        let
            // Perform API call to OpenAI using provided parameters
            apiCallResult = Json.Document(Web.Contents("https://api.openai.com/v1/chat/completions", [
                Headers = [
                    #"Content-Type" = "application/json",
                    #"Authorization" = "Bearer " & openAIkey
                ],
                Content = Json.FromValue([
                    model = gptModel,
                    messages = {
                        [ role = "system", content = assistantBehaviour ],
                        [ role = "system", content = "Examine this data: " & jsonInformation],
                        [ role = "system", content = "Respond in this example JSON structure, add records as required:" & jsonResponseStructure],
                        [ role = "user", content = instruction]
                    }
                ], TextEncoding.Utf8)
            ]))[choices]{0}[message][content]

        in
            apiCallResult,
 
    // Apply the grouping function to the data table
    groupTableStep = groupDataTable(dataTable),
 
    // Escape JSON strings in the table
    escapeTableStep = Table.TransformColumns(groupTableStep, {{"Grouped Data", each tableToEscapedJsonString(_)}}),
 
    // Expand the grouped data table to individual rows
    expandedGroupedData = Table.ExpandTableColumn(escapeTableStep, "Grouped Data", {"Column1"}, {"Escaped JSON"}),
 
    // Filter rows based on test settings
    filterRowsStep = 
        if testGroups > 0 and testGroups <> null then
            Table.FirstN(expandedGroupedData, testGroups)
        else 
            expandedGroupedData,

    // Perform GPT analysis on filtered rows
    performGptAnalysis = Table.TransformColumns(filterRowsStep, {{"Escaped JSON", each generateGptBody(_)}}),
    #"Parsed JSON" = Table.TransformColumns(performGptAnalysis,{{"Escaped JSON", Json.Document}}),
    #"Expanded Escaped JSON" = Table.ExpandListColumn(#"Parsed JSON", "Escaped JSON")

in

    #"Expanded Escaped JSON"
    // _______________________________ \\
  in  

    Value.ReplaceType(myFunction, metaDocumentation)