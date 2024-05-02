let
  // Define metadata for the function, describing its purpose and usage.
  metaDocumentation = type function (
    WorkspaceNameOrID as (type text meta [
      Documentation.FieldCaption = "Workspace Name or ID",
      Documentation.SampleValues = {"MyWorkspace", "128fd147-7051-4f3f-95b7-7970f6209d5f"},
      Formatting.IsMultiLine = false,
      Formatting.IsCode = false
    ]),
    DataflowNameOrID as (type text meta [
      Documentation.FieldCaption = "Dataflow Name or ID",
      Documentation.SampleValues = {"MyDataflow", "127fd147-7051-4f3f-95b7-7970f6209d5e"},
      Formatting.IsMultiLine = false,
      Formatting.IsCode = false
    ]),
    TableName as (type text meta [
      Documentation.FieldCaption = "Table Name",
      Documentation.SampleValues = {"MyTable"},
      Formatting.IsMultiLine = false,
      Formatting.IsCode = false
    ]),
    optional RowLimit as (type number meta [
      Documentation.FieldCaption = "Row Limit",
      Documentation.LongDescription = "Enter the number of rows to return. Leave blank or select -1 to return all rows.",
      Documentation.SampleValues = {null, -1, 0, 100, 1000, 10000, 1000000, 10000000, 1000000000},
      Formatting.IsMultiLine = false,
      Formatting.IsCode = false
    ])
  ) as any meta [
    Documentation.Name = "TableFromDataflow",
    Documentation.LongDescription =
      //This is the description of the documentation, it only accepts a handful of HTML tags for formatting.
      "    
        <p><b>Table from Dataflow</b></p>
        <li><b>Creator:</b> James D. Bartlett III</li>
        <li><b>LinkedIn:</b> https://www.linkedin.com/in/jamesdbartlett3/</li>
        <li><b>Blog:</b> https://datavolume.xyz</li>
        <li><b>GitHub:</b> https://github.com/JamesDBartlett3</li>
        <li><b>LinkedIn:</b> https://linkedin.com/in/JamesDBartlett3</li>
        <li><b>Mastodon:</b> https://techhub.social/@JamesDBartlett3</li>
        <li><b>Bluesky:</b> https://bsky.app/profile/jamesdbartlett3.bsky.social</li>

        <p><b>This function will return a table from a dataflow in a Power BI workspace, limited to a specified number of rows. All connection string components have been parameterized to make switching between data sources as simple and easy as possible.</b></p>
        <p><b>Parameters:</b></p>
        <li><b>WorkspaceNameOrID:</b> The name or ID of the workspace containing the dataflow.</li>
        <li><b>DataflowNameOrID:</b> The name or ID of the dataflow containing the table.</li>
        <li><b>TableName:</b> The name of the table to return.</li>
        <li><b>RowLimit:</b> The number of rows to return. Leave blank or select -1 to return all rows.</li>

        <p><b>References</b></p>
        <li><a href='https://blog.crossjoin.co.uk/2020/05/24/limit-the-amount-of-data-you-work-with-in-power-bi-desktop-using-parameters-and-deployment-pipelines/'>Limit The Amount Of Data You Work With In Power BI Desktop Using Parameters And Deployment Pipelines (Chris Webb)</a></li>
      "
  ],
  // Define the main function
  myFunction = (
    WorkspaceNameOrID as text,
    DataflowNameOrID as text,
    TableName as text,
    optional RowLimit as number
  ) as table =>
    let
      // Set RowLimit to -1 if null
      RowLimit = if RowLimit is null then -1 else RowLimit,
      // Set the Source to Power Platform Dataflows
      Source = PowerPlatform.Dataflows(null),
      // Get the list of workspaces containing dataflows
      WorkspaceList = Source{[Id = "Workspaces"]}[Data],
      // Use try...otherwise to select the workspace by it name or ID
      SelectedWorkspace =
        try WorkspaceList{[workspaceName = WorkspaceNameOrID]}[Data]
        otherwise WorkspaceList{[workspaceId = WorkspaceNameOrID]}[Data],
      // Use try...otherwise to select the dataflow by its name or ID
      SelectedDataflow =
        try SelectedWorkspace{[dataflowName = DataflowNameOrID]}[Data]
        otherwise SelectedWorkspace{[dataflowId = DataflowNameOrID]}[Data],
      // Select the table by its name from the selected dataflow
      SelectedTable = SelectedDataflow{[entity = TableName, version = ""]}[Data],
      // Limit the number of rows returned
      FilterLogic =
        if RowLimit < 0
        then SelectedTable
        else Table.FirstN(SelectedTable, RowLimit)
    in
      FilterLogic
in 
  // Apply the function metadata to myFunction.
  Value.ReplaceType(myFunction, metaDocumentation)
