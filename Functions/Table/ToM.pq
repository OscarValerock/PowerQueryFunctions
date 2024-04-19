let
  // Set tab width
  Tab = "  ",
  // Define metadata for the function, describing its purpose and usage.
  metaDocumentation = type function (
    dataTable as (type table meta [
      Documentation.FieldCaption = "Table to convert to code",
      Formatting.IsMultiLine = false,
      Formatting.IsCode = false
    ])
  ) as text meta [
    Documentation.Name = "Table.ToM",
    Documentation.Author = "Alexis Olson",
    Documentation.LongDescription = 
      // This is the description of the documentation, it only accepts a handful of HTML tags for formatting.
      "
        <p>This function converts a table into an M code text query that recreates the table</p>
        <p><b>Parameter:</b></p>
        <ul>
            <li><b>dataTable</b>: Input table. Can reference an existing query.</li>
        </ul>
        <p><b>Returns:</b> A text string of M code</p>
        <li>------------------------------------------------------</li>
        <li><b>Creator: </b>Alexis Olson</li>
        <li><b>LinkedIn: </b>https://www.linkedin.com/in/alexis-olson-81726818/</li>
        <li><b>Origin: </b>https://community.fabric.microsoft.com/t5/Community-Blog/Sharing-Power-Query-tables/bc-p/3558472</li>
      ",
    Documentation.Examples = {
      [
        Description = "  ", 
        Code = "Table.ToM(Table.FromValue({1, ""A"", false}))", 
        Result = "let#(lf)"
          & Tab & "Source = Table.FromRows(#(lf)"
          & Tab & Tab & "{#(lf)"
          & Tab & Tab & Tab & "{1},#(lf)"
          & Tab & Tab & Tab & "{""A""},#(lf)"
          & Tab & Tab & Tab & "{false}#(lf)"
          & Tab & Tab & "},#(lf)"
          & Tab & Tab & "type table [Value = any]#(lf)"
          & Tab & ")#(lf)"
          & "in#(lf)"
          & Tab & "Source"
     ]
    }],
  myFunction =
    (TableName as table) as text =>
    let
      Source = Table.ToRows(TableName),
      DataRowIndent = Text.Repeat(Tab, 3), 
      DataRowSeparator = "},#(lf)" & DataRowIndent & "{", 
      Schema = Table.Schema(TableName), 
      ValueToText = (x) =>
        let
          xType = Value.Type(x), 
          /*Hack to convert data type to plain text*/
          xTypeText = Text.BeforeDelimiter(
            Table.Schema(
              #table(type table [Col = Value.Type(x)], {{x}})
            ){0}[TypeName], 
            "."
          ), 
          result = 
            if x = null then
              "null"
            else if xType = Text.Type or xType = Any.Type then
              """" & x & """"
            else if xType = Number.Type or xType = Logical.Type then
              Text.From(x)
            else if xType = Date.Type then
              "#date("
                & Text.From(Date.Year(x)) & ", "
                & Text.From(Date.Month(x)) & ", "
                & Text.From(Date.Day(x))
                & ")"
            else if xType = Time.Type then
              "#time("
                & Text.From(Time.Hour(x)) & ", "
                & Text.From(Time.Minute(x)) & ", "
                & Text.From(Time.Second(x))
                & ")"
            else if xType = DateTime.Type then
              "#datetime("
                & Text.From(Date.Year(x)) & ", "
                & Text.From(Date.Month(x)) & ", "
                & Text.From(Date.Day(x)) & ", "
                & Text.From(Time.Hour(x)) & ", "
                & Text.From(Time.Minute(x)) & ", "
                & Text.From(Time.Second(x))
                & ")"
            else if xType = DateTimeZone.Type then
              "#datetimezone("
                & Text.From(Date.Year(x)) & ", "
                & Text.From(Date.Month(x)) & ", "
                & Text.From(Date.Day(x)) & ", "
                & Text.From(Time.Hour(x)) & ", "
                & Text.From(Time.Minute(x)) & ", "
                & Text.From(Time.Second(x)) & ", "
                & Text.From(DateTimeZone.ZoneHours(x)) & ", "
                & Text.From(DateTimeZone.ZoneMinutes(x))
                & ")"
            else if xType = Duration.Type then
              "#duration("
                & Text.From(Duration.Days(x)) & ", "
                & Text.From(Duration.Hours(x)) & ", "
                & Text.From(Duration.Minutes(x)) & ", "
                & Text.From(Duration.Seconds(x))
                & ")"
            else
              xTypeText & ".FromText(""" & Text.From(x) & """)"
        in
          result, 
      DataRows_Text = Text.Combine(
        List.Transform(
          Source,
          each Text.Combine(List.Transform(_, ValueToText), ", ")
        ), 
        DataRowSeparator
      ), 
      ColTypes_Text = Text.Combine(
        List.Transform(
          Table.ToRecords(Schema),
          each [Name] & " = " & [Kind]
        ), 
        ", "
      ), 
      Query =
        "let#(lf)"
          & Tab & "Source = Table.FromRows(#(lf)"
          & Tab & Tab & "{#(lf)"
          & Tab & Tab & Tab & "{" & DataRows_Text & "}#(lf)"
          & Tab & Tab & "},#(lf)"
          & Tab & Tab & "type table [" & ColTypes_Text & "]#(lf)"
          & Tab & ")#(lf)"
          & "in#(lf)"
          & Tab & "Source"
      ,
      StandardDataTypes = {
        "binary", 
        "date", 
        "datetime", 
        "datetimezone", 
        "duration", 
        "logical", 
        "number", 
        "text", 
        "time",
        "any"
      }, 
      UnhandledTypes = List.RemoveItems(Schema[Kind], StandardDataTypes), 
      Output =
        if not List.IsEmpty(UnhandledTypes) then
          "Unsupported Column Types"
        else
          Query
    in
      Output
in
  // Apply the function metadata to myFunction.
  Value.ReplaceType(myFunction, metaDocumentation)
  
