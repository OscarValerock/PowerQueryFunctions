let
    // Define metadata for parameters
    metaDocumentation = type function (
        inputTable as (type table meta [
            Documentation.FieldCaption = "Input Table",
            Documentation.FieldDescription = "A table containing time interval columns.",
            Documentation.SampleValues = {"#table({...})"},
            Formatting.IsMultiLine = true,
            Formatting.IsCode = true
        ]),
        startColumnName as (type text meta [
            Documentation.FieldCaption = "Start Column Name",
            Documentation.FieldDescription = "Name of the column with the interval start time.",
            Documentation.SampleValues = {"StartTime"},
            Formatting.IsMultiLine = false,
            Formatting.IsCode = false
        ]),
        endColumnName as (type text meta [
            Documentation.FieldCaption = "End Column Name",
            Documentation.FieldDescription = "Name of the column with the interval end time.",
            Documentation.SampleValues = {"EndTime"},
            Formatting.IsMultiLine = false,
            Formatting.IsCode = false
        ])
    ) as table meta [

        Documentation.Name = "ToHourlyRows",
        Documentation.Author = "Oscar Martínez",
        Documentation.LongDescription = 
        "
            <p><b>Function: Add Hourly Rows Based on Time Intervals</b></p>

            <li>------------------------------------------------------</li>
            
            <li><b>Creator: </b>Oscar Martinez</li>
            <li><b>LinkedIn:</b> https://www.linkedin.com/in/oscarmartinezv/</li>
            <li><b>Web: </b>https://bibb.pro</li>

            <li>------------------------------------------------------</li>

            <p><b>Description:</b></p>
            <p>This function takes a table and column names for 'Start' and 'End' time intervals. It creates a new column [HourlyRows] for each row, showing hourly buckets with their overlap (in hours).</p>

            <p><b>Parameters:</b></p>
            <ul>
                <li><b>• inputTable:</b> Table that contains the time intervals</li>
                <li><b>• startColumnName:</b> Name of the column with start DateTime</li>
                <li><b>• endColumnName:</b> Name of the column with end DateTime</li>
            </ul>

            <p><b>Returns:</b></p>
            A table with an additional column [HourlyRows], each cell holding a breakdown of overlapping hours.

            <p><b>Formula Bar Example:</b></p>
            <code>ToHourlyRows(MyTable, ""Time Interval Start"", ""Time Interval End"")</code>
        ",

        Documentation.Examples = {
            [
                Description = "Add hourly breakdown based on flexible column names.",
                Code = "ToHourlyRows(#table({""Start"", ""End""}, {{#datetime(2024,1,1,13,15,0), #datetime(2024,1,1,15,45,0)}}), ""Start"", ""End"")",
                Result = "A table with [HourlyRows] column containing detailed overlaps"
            ]
        }
    ],

    // Main function
    ToHourlyRows = (inputTable as table, startColumnName as text, endColumnName as text) as table =>
        Table.AddColumn(
            inputTable,
            "HourlyRows",
            each 
                let
                    row = _,
                    StartTime = DateTime.From(Record.Field(row, startColumnName)),
                    EndTime   = DateTime.From(Record.Field(row, endColumnName)),

                    StartOfHour = #datetime(
                        Date.Year(StartTime),
                        Date.Month(StartTime),
                        Date.Day(StartTime),
                        Time.Hour(DateTime.Time(StartTime)),
                        0,
                        0
                    ),
                    EndOfHour = #datetime(
                        Date.Year(EndTime),
                        Date.Month(EndTime),
                        Date.Day(EndTime),
                        Time.Hour(DateTime.Time(EndTime)),
                        0,
                        0
                    ),

                    NumberOfHourSlots = 
                        Number.RoundDown(Duration.TotalHours(EndOfHour - StartOfHour)) + 1,

                    HourOffsets = {0 .. NumberOfHourSlots - 1},

                    HourSlotRecords = 
                        List.Transform(
                            HourOffsets,
                            (offset) =>
                                let
                                    ThisSlotStart = StartOfHour + #duration(0, offset, 0, 0),
                                    ThisSlotEnd   = ThisSlotStart + #duration(0, 1, 0, 0),
                                    OverlapStart  = if StartTime > ThisSlotStart then StartTime else ThisSlotStart,
                                    OverlapEnd    = if EndTime < ThisSlotEnd then EndTime else ThisSlotEnd,
                                    OverlapHours  =
                                        if OverlapEnd > OverlapStart 
                                        then Duration.TotalHours(OverlapEnd - OverlapStart)
                                        else 0
                                in
                                    [
                                        HourStart    = ThisSlotStart,
                                        OverlapHours = OverlapHours
                                    ]
                        ),

                    HourlyTable = Table.FromRecords(HourSlotRecords)
                in
                    HourlyTable
        ),

    // Attach metadata
    output = Value.ReplaceType(ToHourlyRows, metaDocumentation)
in
    output