(startYear as number ) =>

let
    Today = Date.From( DateTime.LocalNow() ),
    StartDate = #date(startYear, 1, 1),
    EndDate = Date.EndOfYear( Today ),
    #"List of Dates" = List.Dates( StartDate, Duration.Days( EndDate - StartDate ) +1, #duration( 1, 0, 0, 0 ) ),
    #"Converted to Table" = Table.FromList( #"List of Dates", Splitter.SplitByNothing(), type table[Date = Date.Type] ),
    #"Insert Date Integer" = Table.AddColumn(#"Converted to Table", "Date Integer", each Number.From( Date.ToText( [Date], "yyyyMMdd" ) ), Int64.Type ),
    #"Insert Year" = Table.AddColumn(#"Insert Date Integer", "Year", each Date.Year([Date]), Int64.Type),
    // Creates a dynamic year value called 'Current' that moves with the current date. Put this value in a slicer and it automatically switches to the Current period.
    #"Add Year Default" = Table.AddColumn(#"Insert Year", "Year Default", each if Date.Year( Today ) = [Year] then "Current" else Text.From( [Year] ), type text),
    #"Insert YYYY-MM" = Table.AddColumn(#"Add Year Default", "YYYY-MM", each Date.ToText( [Date], "yyyy-MM"), type text),
    #"Insert Month-Year" = Table.AddColumn(#"Insert YYYY-MM", "Month-Year", each Date.ToText( [Date], "MMM yyyy"), type text),
    #"Insert Month Number" = Table.AddColumn(#"Insert Month-Year", "Month Of Year", each Date.Month([Date]), Int64.Type),
    #"Insert Month Name" = Table.AddColumn(#"Insert Month Number", "Month Name", each Date.MonthName([Date], "EN-us"), type text),
    #"Insert Month Name Short" = Table.AddColumn(#"Insert Month Name", "Month Name Short", each Date.ToText( [Date] , "MMM", "EN-us" ), type text),
    // Creates a dynamic year value called 'Current' that moves with the current date. Put this value in a slicer and it automatically switches to the current period.
    #"Add Month Name Default" = Table.AddColumn(#"Insert Month Name Short", "Month Name Default", each if Date.Month( Today ) = [Month Of Year] then "Current" else [Month Name], type text ),
    #"Insert Start of Month" = Table.AddColumn(#"Add Month Name Default", "Start of Month", each Date.StartOfMonth([Date]), type date),
    #"Inserted End of Month" = Table.AddColumn(#"Insert Start of Month", "End of Month", each Date.EndOfMonth( [Date] ), type date),
    #"Inserted Days in Month" = Table.AddColumn(#"Inserted End of Month", "Days in Month", each Date.DaysInMonth([Date]), Int64.Type),
    #"Add ISO Week" = Table.AddColumn(#"Inserted Days in Month", "ISO Weeknumber", each let
   CurrentThursday = Date.AddDays([Date], 3 - Date.DayOfWeek([Date], Day.Monday ) ),
   YearCurrThursday = Date.Year( CurrentThursday ),
   FirstThursdayOfYear = Date.AddDays(#date( YearCurrThursday,1,7),- Date.DayOfWeek(#date(YearCurrThursday,1,1), Day.Friday) ),
   ISO_Week = Duration.Days( CurrentThursday - FirstThursdayOfYear) / 7 + 1
in ISO_Week, Int64.Type ),
    #"Add ISO Year" = Table.AddColumn(#"Add ISO Week", "ISO Year", each Date.Year(  Date.AddDays( [Date], 26 - [ISO Weeknumber] ) ), Int64.Type ),
    #"Insert Start of Week" = Table.AddColumn(#"Add ISO Year", "Start of Week", each Date.StartOfWeek([Date], Day.Monday ), type date),
    #"Insert Quarter Number" = Table.AddColumn(#"Insert Start of Week", "Quarter Number", each Date.QuarterOfYear([Date]), Int64.Type),
    #"Added Quarter" = Table.AddColumn(#"Insert Quarter Number", "Quarter", each "Q" & Text.From( Date.QuarterOfYear([Date]) ), type text ),
    #"Add Year-Quarter" = Table.AddColumn(#"Added Quarter", "Year-Quarter", each Text.From( Date.Year([Date]) ) & "-Q" & Text.From( Date.QuarterOfYear([Date]) ), type text ),
    #"Insert Day Name" = Table.AddColumn(#"Add Year-Quarter", "Day Name", each Date.DayOfWeekName([Date], "EN-us" ), type text),
    #"Insert Day Name Short" = Table.AddColumn( #"Insert Day Name", "Day Name Short", each Date.ToText( [Date], "ddd", "EN-us" ), type text),
    #"Insert Day of Month Number" = Table.AddColumn(#"Insert Day Name Short", "Day of Month Number", each Date.Day([Date]), Int64.Type),
    // Day.Monday indicates the week starts on Monday. Change this in case you want the week to start on a different date. 
    #"Insert Day of Week" = Table.AddColumn(#"Insert Day of Month Number", "Day of Week Number", each Date.DayOfWeek( [Date], Day.Monday ), Int64.Type),
    #"Insert Day of Year" = Table.AddColumn(#"Insert Day of Week", "Day of Year Number", each Date.DayOfYear( [Date] ), Int64.Type),
    #"Add Day Offset" = Table.AddColumn(#"Insert Day of Year", "Day Offset", each Number.From( Date.From( Today ) - [Date] ) , Int64.Type ),
    #"Add Week Offset" = Table.AddColumn(#"Add Day Offset", "Week Offset", each Duration.Days( Date.StartOfWeek( [Date], Day.Monday ) - Date.StartOfWeek( Today, Day.Monday ) ) / 7 , Int64.Type ),
    #"Add Month Offset" = Table.AddColumn(#"Add Week Offset", "Month Offset", each ( [Year] - Date.Year( Today ) ) * 12 + ( [Month Of Year] - Date.Month( Today ) ), Int64.Type ),
    #"Add Quarter Offset" = Table.AddColumn(#"Add Month Offset", "Quarter Offset", each ( [Year] - Date.Year(Today) ) * 4 + Date.QuarterOfYear( [Date] ) - Date.QuarterOfYear( Today ), Int64.Type ),
    #"Add Year Offset" = Table.AddColumn(#"Add Quarter Offset", "Year Offset", each [Year] - Date.Year(Today), Int64.Type ),
    #"Insert Is Weekend" = Table.AddColumn(#"Add Year Offset", "Is Weekend", each if Date.DayOfWeek( [Date] ) >= 5 then 1 else 0, Int64.Type ),
    #"Insert Is Weekday" = Table.AddColumn(#"Insert Is Weekend", "Is Weekday", each if Date.DayOfWeek( [Date] ) < 5 then 1 else 0, Int64.Type )
in
    #"Insert Is Weekday"
