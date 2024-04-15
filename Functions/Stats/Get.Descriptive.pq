//Function documentation template by Oscar Martinez https://bibb.pro
let
    // Define metadata for the function, describing its purpose and usage.
    metaDocumentation = type function (
        argument1 as (type table meta [
            Documentation.FieldCaption = "Table",
            Formatting.IsMultiLine = false,
            Formatting.IsCode = false
        ])
    ) as any meta [
        Documentation.Name = "Get Descriptive Statistics",
        Documentation.LongDescription = 
            //This is the description of the documentation, it only accepts a handful of HTML tags for formatting.
            "    
                <p><b>Get Descriptive Statistics</b></p>
                <li><b>Creator: </b>Oscar Martinez</li>
                <li><b>LinkedIn:</b> https://www.linkedin.com/in/oscarmartinezv/</li>
                <li><b>Web: </b>https://bibb.pro</li>

                <p>This function is designed to describe all columns in a given table in Power Query, providing statistics like count, count non-null, count unique, minimum, maximum, average, median, standard deviation, and mode for numeric columns, and count, count non-null, and count unique for non-numeric columns.</p>
                <p>The fucntion takes two paramenters:</p>
                <ul>
                    <li><b>Table: </b>A table for getting descriptive statistics.</li>
                </ul>
            "
    ],
    // Define the main function
    myFunction =  (Source as table) as table =>
    let
        // Function to describe a single column
        DescribeColumn = (Source as table, ColumnName as text) as table =>
        let
            ColumnData = Table.SelectColumns(Source, {ColumnName}),
            FirstNonNull = List.First(List.RemoveNulls(Table.Column(ColumnData, ColumnName)), null),
            IsNumeric = FirstNonNull <> null and Type.Is(Value.Type(FirstNonNull), type number),
            GroupedData = Table.Group(ColumnData, ColumnName, {{"Count", each Table.RowCount(_), type number}}),
            SortedGroups = Table.Sort(GroupedData, {{"Count", Order.Descending}}),
            Mode = if Table.RowCount(SortedGroups) > 0 and SortedGroups{0}[Count] > 1 then Record.Field(SortedGroups{0}, ColumnName) else null,
            Stats = if IsNumeric then
                [
                    Column = ColumnName,
                    Count = Table.RowCount(Source),
                    CountNonNull = Table.RowCount(Table.SelectRows(Source, each Record.Field(_, ColumnName) <> null)),
                    Min = List.Min(Table.Column(Source, ColumnName)),
                    Max = List.Max(Table.Column(Source, ColumnName)),
                    Average = List.Average(Table.Column(Source, ColumnName)),
                    Median = List.Median(Table.Column(Source, ColumnName)),
                    StandardDeviation = List.StandardDeviation(Table.Column(Source, ColumnName)),
                    CountUnique = List.Count(List.Distinct(Table.Column(Source, ColumnName))),
                    Mode = Mode
                ]
            else
                [
                    Column = ColumnName,
                    Count = Table.RowCount(Source),
                    CountNonNull = Table.RowCount(Table.SelectRows(Source, each Record.Field(_, ColumnName) <> null)),
                    CountUnique = List.Count(List.Distinct(Table.Column(Source, ColumnName))),
                    GroupedData = Table.Group(ColumnData, ColumnName, {{"Count", each Table.RowCount(_), type number}}),
                    SortedGroups = Table.Sort(GroupedData, {{"Count", Order.Descending}}),
                    Mode = Mode
                ],
            SummaryRecord = Record.FromList(Record.FieldValues(Stats), Record.FieldNames(Stats)),
            SummaryTable = Table.FromRecords({SummaryRecord})
        in
            SummaryTable,

        // Get all column names
        ColumnNames = Table.ColumnNames(Source),

        // Apply DescribeColumn to each column
        DescriptiveStatsList = List.Transform(ColumnNames, each DescribeColumn(Source, _)),

        // Combine all individual column statistics into one table
        CombinedStats = Table.Combine(DescriptiveStatsList)
    in
        CombinedStats
    in
    // Apply the function metadata to myFunction.
    Value.ReplaceType(myFunction, metaDocumentation)