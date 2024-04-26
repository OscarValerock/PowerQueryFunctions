let
  customFunction =
// 1.0: invoke function & define parameter inputs
  
    let
     // 4.0: edit function metadata here
      documentation = [
        // Inspired by Enterprise DNA - Melissa de Korte (https://www.youtube.com/watch?v=H8F60sgQZOI)
        Documentation.Name = " fnDates ", 
        Documentation.Description = " Dates Table with Fiscal and Academic Year ", 
        Documentation.LongDescription = "    
                <p><b>  Date Table Generator  </b></p>

                <li>------------------------------------------------------</li>
                
                <li><b>  Creator: </b> Imran Haq  </li>
                <li><b>  Web: </b> https://github.com/PBIQueryous/M-Code/tree/main/Calendars  </li>
                <li><b>  Acknowledgements: </b> Melissa de Korte  </li>
                <li><b>  LinkedIn: </b> (https://www.linkedin.com/in/melissa-de-korte/)  </li>

                <li>------------------------------------------------------</li>

                <li><b>  Editor: </b>  Oscar Martinez  </li>
                <li><b>  Web: </b>  https://bibb.pro  </li>
                <li><b>  LinkedIn: </b>  https://www.linkedin.com/in/oscarmartinezv/  </li>

                <li>------------------------------------------------------</li>

                <p><b>  Function Description:  </b></p>
                <p>  This function generates a date table with a range of dates from the start year to the end year. Additional parameters are available generate Fiscal/Financial and Academic Year columns.  </p>
                <p><b>  Parameters:  </b></p>
                <ul>
                    <li><b>  StartYearNUM:  </b>  The starting year of the date range. <code> (eg: 2023) </code> </li>
                    <li><b>  EndYearNUM:  </b>  The ending year of the date range. <code> (eg: 2025) </code> </li>
                    <li><b>  FYStartMonthNUM (optional):  </b>  The fiscal year start month.  <code> (eg: 4) </code> </li>
                    <li><b>  AYStartMonthNUM (optional):  </b>  The academic year start month.  <code> (eg: 8) </code> </li>
                    <li><b>  Holidays (optional):  </b>  Provide a list of public holidays.   </li>
                    <li><b>  WDStartNum (optional):  </b>  Weekday start (1 = Monday, 0 = Sunday).  <code> (eg: null) </code> </li>
                    <li><b>  AddRelativeNetworkDays (optional):  </b>  Include Relative Network Days.  <code> (eg: null) </code> </li>
                </ul>
                <p><b>  Returns:  </b></p>
                <p>  A date table.  </p>

                <li><b>  fx:  </b> <code> = fnDates(2023, 2025, 4, 8, null, null, null) </code> </li>
            ", 
        Documentation.Category = " Dates / Calendar ", 
        Documentation.Source = "  PBI Queryous  ", 
        Documentation.Version = " 4.0: Upated for Oscar Valderock", 
        Documentation.Author = " Imran Haq ", 
        Documentation.Examples = {
          [
            Description = "  Dates Table with Fiscal and Academic Year   ", 
            Code = " = fnDates(2023, 2025, 4, 8, null, null, null) ", 
            Result = 
"
  1. Input paramaters
  2. Invoke function
  3. Optional: replace start / end year parameters with dynamic values to automatically extend table

"
          ]
        /* ,
            [
            Description = "  description   ",
            Code    = " code ", 
            Result  = " result #(cr,lf) new line
                      #(cr,lf) new line #(cr,lf) 2 "
            ] */
        }
      ], 
      invokeFunction = (StartYearNUM as number,  // start year             
      EndYearNUM as number,  // end year           
      optional FYStartMonthNum as nullable number,  // Fiscal Year Start                    
      optional AYStartMonthNum as nullable number,  // Academic Year Start                      
      optional Holidays as list,  // Holidays list                
      optional WDStartNum as number,  // WeekDay Start                
      optional AddRelativeNetWorkdays as logical // Network Days               
      ) as table =>
        // ------------------------------------------------------------------
        // 2.0: function transformations
let
          // // //Parameters

          // StartDate = #date(2020, 1, 1), // - turn off in custom function
          // EndDate = #date(2024, 12, 31), // -turn off in custom function
          // FYStartMonthNum = 4,
          // AYStartMonthNum  = 8,
          // Holidays = {},
          // WDStartNum = 1,
          // AddRelativeNetWorkdays = true,

        // //-- Date table code

          StartDate = Date.From("01/01/" & Text.From(StartYearNUM)),  // -- turn ON for CUSTOM FN
          EndDate = Date.From("31/12/" & Text.From(EndYearNUM)),  // -- turn ON for CUSTOM FN 
                                                                             
          FYStartMonth = List.Select({1 .. 12}, each _ = FYStartMonthNum){0}? ?? 1, 
          AYStartMonth = List.Select({1 .. 12}, each _ = AYStartMonthNum){0}? ?? 1, 
          WDStart = List.Select({0 .. 1}, each _ = WDStartNum){0}? ?? 0, 
          var_CurrentDate = Date.From(DateTime.FixedLocalNow()), 
          var_DayCount = Duration.Days(Duration.From(EndDate - StartDate)) + 1, 
          list_Dates = List.Dates(StartDate, var_DayCount, #duration(1, 0, 0, 0)), 
          tx_AddToday = 
            if EndDate < var_CurrentDate then
              List.Combine({list_Dates, {var_CurrentDate}})
            else
              list_Dates, 
          make_Table = Table.FromList(
            tx_AddToday, 
            Splitter.SplitByNothing(), 
            type table [Date = Date.Type]
          ), 
          
          // start deriving columns here

          // Year as integer
          col_Year = Table.AddColumn(make_Table, "YearNUM", each Date.Year([Date]), type number),

          // calendar Year Offset 
          col_YearOFFSET = Table.AddColumn(
            col_Year, 
            "YearOFFSET", 
            each Date.Year([Date]) - Date.Year(Date.From(var_CurrentDate)), 
            type number
          ), 

          // is current calendar year complete as boolean
          col_isYearComplete = Table.AddColumn(
            col_YearOFFSET, 
            "isYearComplete", 
            each Date.EndOfYear([Date]) < Date.From(Date.EndOfYear(var_CurrentDate)), 
            type logical
          ),


          // calendar quarter as integer 
          col_QuarterNUM = Table.AddColumn(
            col_isYearComplete, 
            "QuarterNUM", 
            each Date.QuarterOfYear([Date]), 
            type number
          ),

          // calendar quart as text 
          col_QuarterTXT = Table.AddColumn(
            col_QuarterNUM, 
            "Quarter", 
            each "Q" & Number.ToText([QuarterNUM]), 
            type text
          ),

          // start of calendar quarter as date 
          col_QuarterSTART = Table.AddColumn(
            col_QuarterTXT, 
            "Quarter Start", 
            each Date.StartOfQuarter([Date]), 
            type date
          ),

          // end of calendar quarter as date 
          col_QuarterEND = Table.AddColumn(
            col_QuarterSTART, 
            "Quarter End", 
            each Date.EndOfQuarter([Date]), 
            type date
          ),

          // calendar quarter & year as text (Q1 23) 
          col_Quarter_Year = Table.AddColumn(
            col_QuarterEND, 
            "Quarter & Year", 
            each "Q"
              & Number.ToText(Date.QuarterOfYear([Date]))
              & Date.ToText([Date], [Format = " yy"]), 
            type text
          ), 

          // calendar quarter and year as integer key (202302)
          col_QuarterYearINT = Table.AddColumn(
            col_Quarter_Year, 
            "QuarterYearINT", 
            each [YearNUM] * 10 + [QuarterNUM], 
            type number
          ), 

          // calendar quarter offset
          col_QuarterOFFSET = Table.AddColumn(
            col_QuarterYearINT, 
            "QuarterOFFSET", 
            each ((4 * Date.Year([Date])) + Date.QuarterOfYear([Date]))
              - (
                (4 * Date.Year(Date.From(var_CurrentDate)))
                  + Date.QuarterOfYear(Date.From(var_CurrentDate))
              ), 
            type number
          ), 

          // is current quarter complete as boolean
          col_isQuarterComplete = Table.AddColumn(
            col_QuarterOFFSET, 
            "isQuarterComplete", 
            each 
              let
                qtrEnd        = Date.EndOfQuarter([Date]), 
                currQtrEnd    = Date.From(Date.EndOfQuarter(var_CurrentDate)), 
                isQtrComplete = qtrEnd < currQtrEnd
              in
                isQtrComplete, 
            type logical
          ), 

          // calendar month num
          col_MonthNUM = Table.AddColumn(
            col_isQuarterComplete, 
            "MonthNUM", 
            each Date.Month([Date]), 
            type number
          ), 

          // calendar month start date
          col_MonthSTART = Table.AddColumn(
            col_MonthNUM, 
            "Month Start", 
            each Date.StartOfMonth([Date]), 
            type date
          ), 

          // calendar month end date
          col_MonthEND = Table.AddColumn(
            col_MonthSTART, 
            "Month End", 
            each Date.EndOfMonth([Date]), 
            type date
          ), 

          // calendar month and year as text
          col_CalendarMONTH = Table.AddColumn(
            col_MonthEND, 
            "Month & Year", 
            each Text.Proper(Date.ToText([Date], [Format = "MMM yy"])), 
            type text
          ), 

          // calendar month and year as integer key (20230001)
          col_MonthYearINT = Table.AddColumn(
            col_CalendarMONTH, 
            "MonthYearINT", 
            each [YearNUM] * 100 + [MonthNUM], 
            type number
          ), 

          // calendar month offset
          col_MonthOFFSET = Table.AddColumn(
            col_MonthYearINT, 
            "MonthOFFSET", 
            each ((12 * Date.Year([Date])) + Date.Month([Date]))
              - (
                (12 * Date.Year(Date.From(var_CurrentDate)))
                  + Date.Month(Date.From(var_CurrentDate))
              ), 
            type number
          ), 

          // is month complete as boolean
          col_isMonthComplete = Table.AddColumn(
            col_MonthOFFSET, 
            "isMonthComplete", 
            each Date.EndOfMonth([Date]) < Date.From(Date.EndOfMonth(var_CurrentDate)), 
            type logical
          ), 

          // month long name
          col_MonthNAME = Table.AddColumn(
            col_isMonthComplete, 
            "Month Name", 
            each Text.Proper(Date.ToText([Date], "MMMM")), 
            type text
          ), 

          // month short name
          col_MonthNameSHORT = Table.AddColumn(
            col_MonthNAME, 
            "Month Short", 
            each Text.Proper(Date.ToText([Date], "MMM")), 
            type text
          ), 

          // month initial
          col_MonthNameINITIAL = Table.AddColumn(
            col_MonthNameSHORT, 
            "Month Initial", 
            each Text.Start([Month Name], 1)
              & Text.Repeat(Character.FromNumber(8203), Date.Month([Date])), 
            type text
          ), 

          // variable (current month name)
          var_CurrentMonthName = Date.MonthName(DateTime.LocalNow()), 

          // month selection (if month name = variable_crrentMonthName, then "Current" else [Month Short] )
          col_MonthSelection = Table.AddColumn(
            col_MonthNameINITIAL, 
            "Month Selection", 
            each if [Month Name] = var_CurrentMonthName then "Current" else [Month Short], 
            type text
          ), 

          // fiscal month ( duplicate for report purposes - needs fiscal month sort order)
          col_FiscalMonth = Table.DuplicateColumn(col_MonthSelection, "Month Short", "Fiscal Month", type text),

          // academic month ( duplicate for report purposes - needs academic month sort order)
          col_AcademicMonth = Table.DuplicateColumn(col_FiscalMonth, "Month Short", "Academic Month", type text),
          
          // add day month number
          col_DayMonthNUM = Table.AddColumn(
            col_AcademicMonth, 
            "DayMonthNUM", 
            each Date.Day([Date]), 
            type number
          ), 

          // calendar week number
          col_WeekNUM = Table.AddColumn(
            col_DayMonthNUM, 
            "Week Number", 
            each 
              if Number.RoundDown(
                (Date.DayOfYear([Date]) - (Date.DayOfWeek([Date], Day.Monday) + 1) + 10) / 7
              )
                = 0
              then
                Number.RoundDown(
                  (
                    Date.DayOfYear(#date(Date.Year([Date]) - 1, 12, 31))
                      - (Date.DayOfWeek(#date(Date.Year([Date]) - 1, 12, 31), Day.Monday) + 1)
                      + 10
                  )
                    / 7
                )
              else if (
                Number.RoundDown(
                  (Date.DayOfYear([Date]) - (Date.DayOfWeek([Date], Day.Monday) + 1) + 10) / 7
                )
                  = 53 and (Date.DayOfWeek(#date(Date.Year([Date]), 12, 31), Day.Monday) + 1 < 4)
              )
              then
                1
              else
                Number.RoundDown(
                  (Date.DayOfYear([Date]) - (Date.DayOfWeek([Date], Day.Monday) + 1) + 10) / 7
                ), 
            type number
          ), 

          // calendar week start date
          col_WeekSTART = Table.AddColumn(
            col_WeekNUM, 
            "Week Start", 
            each Date.StartOfWeek([Date], Day.Monday), 
            type date
          ), 

          // calendar week end date
          col_WeekEND = Table.AddColumn(
            col_WeekSTART, 
            "Week End", 
            each Date.EndOfWeek([Date], Day.Monday), 
            type date
          ), 

          // week and year as text
          col_CalendarWEEK = Table.AddColumn(
            col_WeekEND, 
            "Week & Year", 
            each "W"
              & Text.PadStart(Text.From([Week Number]), 2, "0")
              & " "
              & Text.End(
                Text.From(Date.Year(Date.AddDays(Date.StartOfWeek([Date], Day.Monday), 3))), 
                2
              ), 
            type text
          ), 

          // week year integer
          col_WeekYearINT = Table.AddColumn(
            col_CalendarWEEK, 
            "WeekYearINT", 
            each Date.Year(Date.AddDays(Date.StartOfWeek([Date], Day.Monday), 3))
              * 100 + [Week Number], 
            Int64.Type
          ), 
          col_WeekOFFSET = Table.AddColumn(
            col_WeekYearINT, 
            "WeekOFFSET", 
            each (
              Number.From(Date.StartOfWeek([Date], Day.Monday))
                - Number.From(Date.StartOfWeek(var_CurrentDate, Day.Monday))
            )
              / 7, 
            type number
          ), 
          col_isWeekComplete = Table.AddColumn(
            col_WeekOFFSET, 
            "WeekCompleted", 
            each Date.EndOfWeek([Date], Day.Monday)
              < Date.From(Date.EndOfWeek(var_CurrentDate, Day.Monday)), 
            type logical
          ), 
          col_DayWeekNUM = Table.AddColumn(
            col_isWeekComplete, 
            "DayWeekNUM", 
            each Date.DayOfWeek([Date], Day.Monday) + WDStart, 
            Int64.Type
          ), 
          col_DayNAME = Table.AddColumn(
            col_DayWeekNUM, 
            "Day of Week Name", 
            each Text.Proper(Date.ToText([Date], "dddd")), 
            type text
          ), 
          col_DayINITIAL = Table.AddColumn(
            col_DayNAME, 
            "Day Initial", 
            each Text.Proper(Text.Start([Day of Week Name], 1))
              & Text.Repeat(
                Character.FromNumber(8203), 
                Date.DayOfWeek([Date], Day.Monday) + WDStart
              ), 
            type text
          ), 
          col_DayYearNUM = Table.AddColumn(
            col_DayINITIAL, 
            "DayYearNUM", 
            each Date.DayOfYear([Date]), 
            Int64.Type
          ), 
          col_DayMonthYearINT = Table.AddColumn(
            col_DayYearNUM, 
            "DateINT", 
            each [YearNUM] * 10000 + [MonthNUM] * 100 + [DayMonthNUM], 
            type number
          ), 
          col_DayOFFSET = Table.AddColumn(
            col_DayMonthYearINT, 
            "DayOffset", 
            each Number.From([Date]) - Number.From(var_CurrentDate), 
            type number
          ), 
          col_isYTD = Table.AddColumn(
            col_DayOFFSET, 
            "IsYTD", 
            each ([Date] <= Date.From(var_CurrentDate)), 
            type logical
          ), 
          col_isFuture = Table.AddColumn(
            col_isYTD, 
            "IsFuture", 
            each not ([Date] <= Date.From(var_CurrentDate)), 
            type logical
          ), 
          col_isAfterToday = Table.AddColumn(
            col_isFuture, 
            "IsAfterToday", 
            each not ([Date] <= Date.From(var_CurrentDate)), 
            type logical
          ), 
          col_isWeekDay = Table.AddColumn(
            col_isAfterToday, 
            "IsWeekDay", 
            each if Date.DayOfWeek([Date], Day.Monday) > 4 then false else true, 
            type logical
          ), 
          col_isHoliday = Table.AddColumn(
            col_isWeekDay, 
            "IsHoliday", 
            each if Holidays = null then "Unknown" else List.Contains(Holidays, [Date]), 
            if Holidays = null then type text else type logical
          ), 
          col_isBusinessDay = Table.AddColumn(
            col_isHoliday, 
            "IsBusinessDay", 
            each if [IsWeekDay] = true and [IsHoliday] <> true then true else false, 
            type logical
          ), 
          col_DayTYPE = Table.AddColumn(
            col_isBusinessDay, 
            "Day Type", 
            each 
              if [IsHoliday] = true then
                "Holiday"
              else if [IsWeekDay] = false then
                "Weekend"
              else if [IsWeekDay] = true then
                "Weekday"
              else
                null, 
            type text
          ), 
          col_ISOYear = Table.AddColumn(
            col_DayTYPE, 
            "ISO Year", 
            each Date.Year(Date.AddDays(Date.StartOfWeek([Date], Day.Monday), 3)), 
            type number
          ), 
          col_ISOQuarterNUM = Table.AddColumn(
            col_ISOYear, 
            "ISO QuarterNUM", 
            each 
              if [Week Number] > 39 then
                4
              else if [Week Number] > 26 then
                3
              else if [Week Number] > 13 then
                2
              else
                1, 
            Int64.Type
          ), 
          col_ISOQuarterNAME = Table.AddColumn(
            col_ISOQuarterNUM, 
            "ISO Quarter", 
            each "Q" & Number.ToText([ISO QuarterNUM]), 
            type text
          ), 
          col_ISOQuarterYearNAME = Table.AddColumn(
            col_ISOQuarterNAME, 
            "ISO Quarter & Year", 
            each "Q" & Number.ToText([ISO QuarterNUM]) & " " & Number.ToText([ISO Year]), 
            type text
          ), 
          col_ISOQuarterYearINT = Table.AddColumn(
            col_ISOQuarterYearNAME, 
            "ISO QuarterYearINT", 
            each [ISO Year] * 10 + [ISO QuarterNUM], 
            type number
          ), 
          // BufferTable = Table.Buffer(Table.Distinct( col_ISOQuarterYearINT[[ISO Year], [DateInt]])),
          // InsertISOday = Table.AddColumn(col_ISOQuarterYearINT, "ISO Day of Year", (OT) => Table.RowCount( Table.SelectRows( BufferTable, (IT) => IT[DateInt] <= OT[DateInt] and IT[ISO Year] = OT[ISO Year])),  Int64.Type),
          col_FY = Table.AddColumn(
            col_ISOQuarterYearINT, 
            "Fiscal Year", 
            each 
              let
                arg1     = ([MonthNUM] >= FYStartMonth and FYStartMonth > 1), 
                yearNum1 = Text.End(Text.From([YearNUM] + 0), 2), 
                yearNum0 = Text.End(Text.From([YearNUM] - 1), 2), 
                result1  = if arg1 then yearNum1 else yearNum0
              in
                "FY" & result1, 
            type text
          ),
          col_FY1 = Table.AddColumn(
            col_FY, 
            "Fiscal_Year", 
            each 
              let
                
                yearNum1 = Number.From(Text.End([Fiscal Year], 2)), 
                 
                result1  = Text.From(yearNum1) & "/" & Text.From(yearNum1+1)
              in
                result1, 
            type text
          ), 
          col_AY = Table.AddColumn(
            col_FY1, 
            "Academic Year", 
            each 
              let
                arg1     = ([MonthNUM] >= AYStartMonth and AYStartMonth > 1), 
                yearNum1 = Text.End(Text.From([YearNUM] + 0), 2), 
                yearNum0 = Text.End(Text.From([YearNUM] - 1), 2), 
                result1  = if arg1 then yearNum1 else yearNum0
              in
                "AY" & result1, 
            type text
          ),
          col_AY1 = Table.AddColumn(
            col_AY, 
            "Academic_Year", 
            each 
              let
                
                yearNum1 = Number.From(Text.End([Academic Year], 2)), 
                 
                result1  = Text.From(yearNum1) & "/" & Text.From(yearNum1+1)
              in
                result1, 
            type text
          ),  
          //col_FYs = Table.AddColumn(col_FY, "Fiscal Year short", each "FY" & (if [MonthNUM] >= FYStartMonth and FYStartMonth >1 then Text.PadEnd( Text.End( Text.From([YearNUM] +1), 2), 2, "0") else Text.End( Text.From([YearNUM]), 2)), type text),
          col_FQ = Table.AddColumn(
            col_AY1, 
            "Fiscal Quarter", 
            each "FQ"
              & Text.From(
                Number.RoundUp(Date.Month(Date.AddMonths([Date], - (FYStartMonth - 1))) / 3)
              )
              & " "
              & (
                if [MonthNUM] >= FYStartMonth and FYStartMonth > 1 then
                  Text.End(Text.From([YearNUM] + 0), 2)
                else
                  Text.End(Text.From([YearNUM] - 1), 2)
              ), 
            type text
          ), 
          col_AQ = Table.AddColumn(
            col_FQ, 
            "Academic Quarter", 
            each "AQ"
              & Text.From(
                Number.RoundUp(Date.Month(Date.AddMonths([Date], - (AYStartMonth - 1))) / 3)
              )
              & " "
              & (
                if [MonthNUM] >= AYStartMonth and AYStartMonth > 1 then
                  Text.End(Text.From([YearNUM] + 0), 2)
                else
                  Text.End(Text.From([YearNUM] - 1), 2)
              ), 
            type text
          ), 
          col_FQtrYrINT = Table.AddColumn(
            col_AQ, 
            "FiscalQuarterYearINT", 
            each (
              if [MonthNUM] >= FYStartMonth and FYStartMonth > 1 then
                [YearNUM] + 0
              else
                [YearNUM] - 1
            )
              * 10 + Number.RoundUp(Date.Month(Date.AddMonths([Date], - (FYStartMonth - 1))) / 3), 
            type number
          ), 
          col_AQtrYrINT = Table.AddColumn(
            col_FQtrYrINT, 
            "AcademicQuarterYearINT", 
            each (
              if [MonthNUM] >= AYStartMonth and AYStartMonth > 1 then
                [YearNUM] + 0
              else
                [YearNUM] - 1
            )
              * 10 + Number.RoundUp(Date.Month(Date.AddMonths([Date], - (AYStartMonth - 1))) / 3), 
            type number
          ), 
          col_FPNUM = Table.AddColumn(
            col_AQtrYrINT, 
            "FiscalPeriodNUM", 
            each 
              let
                arg1   = [MonthNUM] >= FYStartMonth and FYStartMonth > 1, 
                res1   = [MonthNUM] - (FYStartMonth - 1), 
                arg2   = [MonthNUM] >= FYStartMonth and FYStartMonth = 1, 
                res2   = [MonthNUM], 
                res3   = [MonthNUM] + (12 - FYStartMonth + 1), 
                result = if arg1 then res1 else if arg2 then res2 else res3
              in
                result, 
            type number
          ), 
          col_APNUM = Table.AddColumn(
            col_FPNUM, 
            "AcademicPeriodNUM", 
            each 
              let
                arg1   = [MonthNUM] >= AYStartMonth and AYStartMonth > 1, 
                res1   = [MonthNUM] - (AYStartMonth - 1), 
                arg2   = [MonthNUM] >= AYStartMonth and AYStartMonth = 1, 
                res2   = [MonthNUM], 
                res3   = [MonthNUM] + (12 - AYStartMonth + 1), 
                result = if arg1 then res1 else if arg2 then res2 else res3
              in
                result, 
            type number
          ), 
          col_FYPeriod = Table.AddColumn(
            col_APNUM, 
            "Fiscal Period", 
            each "FP"
              & Text.PadStart(Text.From([FiscalPeriodNUM]), 2, "0")
              & " "
              & (
                if [MonthNUM] >= FYStartMonth and FYStartMonth > 1 then
                  Text.End(Text.From([YearNUM] + 0), 2)
                else
                  Text.End(Text.From([YearNUM] - 1), 2)
              ), 
            type text
          ), 
          col_AYPeriod = Table.AddColumn(
            col_FYPeriod, 
            "Academic Period", 
            each "AP"
              & Text.PadStart(Text.From([AcademicPeriodNUM]), 2, "0")
              & " "
              & (
                if [MonthNUM] >= AYStartMonth and AYStartMonth > 1 then
                  Text.End(Text.From([YearNUM] + 0), 2)
                else
                  Text.End(Text.From([YearNUM] - 1), 2)
              ), 
            type text
          ), 
          col_FPYrINT = Table.AddColumn(
            col_AYPeriod, 
            "FiscalPeriodYearINT", 
            each (
              if [MonthNUM] >= FYStartMonth and FYStartMonth > 1 then
                [YearNUM] + 0
              else
                [YearNUM] - 1
            )
              * 100 + [FiscalPeriodNUM], 
            type number
          ), 
          col_APYrINT = Table.AddColumn(
            col_FPYrINT, 
            "AcademicPeriodYearINT", 
            each (
              if [MonthNUM] >= AYStartMonth and AYStartMonth > 1 then
                [YearNUM] + 0
              else
                [YearNUM] - 1
            )
              * 100 + [AcademicPeriodNUM], 
            type number
          ), 
          var_FiscalCalendarSTART = #date(Date.Year(StartDate) - 1, FYStartMonth, 1), 
          var_AcademicCalendarSTART = #date(Date.Year(StartDate) - 1, AYStartMonth, 1), 
          col_FiscalFirstDay = Table.AddColumn(
            col_APYrINT, 
            "FiscalFirstDate", 
            each 
              if [MonthNUM] >= FYStartMonth and FYStartMonth > 1 then
                #date(Date.Year([Date]) + 0, FYStartMonth, 1)
              else
                #date(Date.Year([Date]) - 1, FYStartMonth, 1), 
            type date
          ), 
          col_AYStartDate = Table.AddColumn(
            col_FiscalFirstDay, 
            "AYStartDate", 
            each 
              if [MonthNUM] >= AYStartMonth and AYStartMonth > 1 then
                #date(Date.Year([Date]) + 0, AYStartMonth, 1)
              else
                #date(Date.Year([Date]) - 1, AYStartMonth, 1), 
            type date
          ), 
          col_AYEndDate = Table.AddColumn(
            col_AYStartDate, 
            "AYEndDate", 
            each 
              if [MonthNUM] >= AYStartMonth and AYStartMonth > 1 then
                Date.AddDays(#date(Date.Year([Date]) + 1, AYStartMonth, 1),-1)
              else
                Date.AddDays(#date(Date.Year([Date]) - 0, AYStartMonth, 1),-1), 
            type date
          ), 
          col_FYStartDate = Table.AddColumn(
            col_AYEndDate, 
            "FYStartDate", 
            each 
              if [MonthNUM] >= FYStartMonth and FYStartMonth > 1 then
                #date(Date.Year([Date]) + 0, FYStartMonth, 1)
              else
                #date(Date.Year([Date]) - 1, FYStartMonth, 1), 
            type date
          ), 
          col_FYEndDate = Table.AddColumn(
            col_FYStartDate, 
            "FYEndDate", 
            each 
              if [MonthNUM] >= FYStartMonth and FYStartMonth > 1 then
                Date.AddDays(#date(Date.Year([Date]) + 1, FYStartMonth, 1),-1)
              else
                Date.AddDays(#date(Date.Year([Date]) - 0, FYStartMonth, 1),-1), 
            type date
          ),
          //------------------------------------------\\ 
          //----- begin sub-ETL stages and return later ----\\
          var_Table = Table.FromList(
            List.Transform(
              {Number.From(var_AcademicCalendarSTART) .. Number.From(EndDate)}, 
              Date.From
            ), 
            Splitter.SplitByNothing(), 
            type table [DateFW = Date.Type]
          ), 
          col_FFD = Table.AddColumn(
            var_Table, 
            "FiscalFirstDay", 
            each 
              if Date.Month([DateFW]) < FYStartMonth then
                #date(Date.Year([DateFW]) - 1, FYStartMonth, 1)
              else
                #date(Date.Year([DateFW]) + 0, FYStartMonth, 1)
          ), 
          col_FWSD = Table.AddColumn(
            col_FFD, 
            "FWStartDate", 
            each Date.AddYears(Date.StartOfWeek([DateFW], Day.Monday), 0)
          ), 
          tbl_Group1 = Table.Group(
            col_FWSD, 
            {"FiscalFirstDay", "FWStartDate"}, 
            {
              {
                "AllRows", 
                each _, 
                type table [DateFW = nullable date, FiscalFirstDay = date, FWStartDate = date]
              }
            }
          ), 
          tbl_Group2 = Table.Group(
            tbl_Group1, 
            {"FiscalFirstDay"}, 
            {
              {
                "AllRows2", 
                each _, 
                type table [FiscalFirstDay = date, FWStartDate = date, AllRows = table]
              }
            }
          ), 
          col_Index = Table.AddColumn(
            tbl_Group2, 
            "Custom", 
            each Table.AddIndexColumn([AllRows2], "Fiscal Week Number", 1, 1)
          )[[Custom]], 
          cols_Expand1 = Table.ExpandTableColumn(
            col_Index, 
            "Custom", 
            {"FiscalFirstDay", "FWStartDate", "AllRows", "Fiscal Week Number"}, 
            {"FiscalFirstDay", "FWStartDate", "AllRows", "Fiscal Week Number"}
          ), 
          cols_Expand2 = Table.ExpandTableColumn(cols_Expand1, "AllRows", {"DateFW"}, {"DateFW"})[
            [DateFW], 
            [Fiscal Week Number]
          ], 
          //------ return here to begin ETL steps again
          join_Date_DateFW = Table.Join(
            col_FYEndDate, 
            {"Date"}, 
            cols_Expand2, 
            {"DateFW"}, 
            JoinKind.LeftOuter, 
            JoinAlgorithm.SortMerge
          ), 
          var_FYLogicTest = List.Contains({null}, FYStartMonthNum), 
          var_AYLogicTest = List.Contains({null}, AYStartMonthNum), 
          var_FYAYTest = var_FYLogicTest = true and var_AYLogicTest = true, 
          txt_Replace = 
            if var_AYLogicTest then
              Table.ReplaceValue(
                join_Date_DateFW, 
                each [Fiscal Week Number], 
                each if FYStartMonth = 1 then [Week Number] else [Fiscal Week Number], 
                Replacer.ReplaceValue, 
                {"Fiscal Week Number"}
              )
            else
              join_Date_DateFW, 
          col_FYW = Table.AddColumn(
            txt_Replace, 
            "Fiscal Week", 
            each 
              if var_AYLogicTest then
                "F" & [#"Week & Year"]
              else if FYStartMonth = 1 then
                "FW"
                  & Text.PadStart(Text.From([Fiscal Week Number]), 2, "0")
                  & Date.ToText(Date.AddYears([Date], 0), " yy")
              else if Date.Month([Date]) < FYStartMonth then
                "FW"
                  & Text.PadStart(Text.From([Fiscal Week Number]), 2, "0")
                  & Date.ToText(Date.AddYears([Date], - 1), " yy")
              else
                "FW"
                  & Text.PadStart(Text.From([Fiscal Week Number]), 2, "0")
                  & " "
                  & Text.End(Text.From(Date.Year([Date]) + 0), 2), 
            type text
          ), 
          col_FWYearINT = Table.AddColumn(
            col_FYW, 
            "FiscalWeekYearINT", 
            each 
              if var_FYLogicTest then
                [WeeknYear]
              else
                (
                  if FYStartMonth = 1 then
                    Date.Year([Date])
                  else if Date.Month([Date]) < FYStartMonth then
                    Date.Year([Date]) - 1
                  else
                    Date.Year([Date]) + 0
                )
                  * 100 + [Fiscal Week Number], 
            Int64.Type
          ), 
          rec_CurrentDate = Table.SelectRows(col_FWYearINT, each ([Date] = var_CurrentDate)), 
          var_CurrISOYear = rec_CurrentDate{0}[ISO Year], 
          var_CurrISOQtr = rec_CurrentDate{0}[ISO QuarterNUM], 
          var_CurrYear = rec_CurrentDate{0}[YearNUM], 
          var_CurrMonth = rec_CurrentDate{0}[MonthNUM], 
          var_FFD = rec_CurrentDate{0}[FiscalFirstDate], 
          var_AFD = rec_CurrentDate{0}[AYStartDate], 
          var_PFFD = Date.AddYears(var_FFD, - 1), 
          var_PAFD = Date.AddYears(var_AFD, - 1), 
          var_CurrFY = rec_CurrentDate{0}[Fiscal Year], 
          var_CurrAY = rec_CurrentDate{0}[Academic Year], 
          var_CurrFQ = rec_CurrentDate{0}[FiscalQuarterYearINT], 
          var_CurrAQ = rec_CurrentDate{0}[AcademicQuarterYearINT], 
          var_CurrFP = rec_CurrentDate{0}[FiscalPeriodYearINT], 
          var_CurrAP = rec_CurrentDate{0}[AcademicPeriodYearINT], 
          var_CurrFW = rec_CurrentDate{0}[FiscalWeekYearINT], 
          col_ISOYearOFFSET = Table.AddColumn(
            col_FWYearINT, 
            "ISO YearOFFSET", 
            each [ISO Year] - var_CurrISOYear, 
            type number
          ), 
          col_ISOQuarterOFFSET = Table.AddColumn(
            col_ISOYearOFFSET, 
            "ISO QuarterOFFSET", 
            each ((4 * [ISO Year]) + [ISO QuarterNUM]) - ((4 * var_CurrISOYear) + var_CurrISOQtr), 
            type number
          ), 
          col_FiscalYearOFFSET = Table.AddColumn(
            col_ISOQuarterOFFSET, 
            "FiscalYearOFFSET", 
            each try
              (if [MonthNUM] >= FYStartMonth then [YearNUM] + 1 else [YearNUM])
                - (if var_CurrMonth >= FYStartMonth then var_CurrYear + 1 else var_CurrYear)
            otherwise
              null, 
            type number
          ), 
          col_AcademicYearOFFSET = Table.AddColumn(
            col_FiscalYearOFFSET, 
            "AcademicYearOFFSET", 
            each try
              (if [MonthNUM] >= AYStartMonth then [YearNUM] + 1 else [YearNUM])
                - (if var_CurrMonth >= AYStartMonth then var_CurrYear + 1 else var_CurrYear)
            otherwise
              null, 
            type number
          ), 
          col_CYSelection = Table.AddColumn(
            col_AcademicYearOFFSET, 
            "CY Selection", 
            each if [YearOFFSET] = 0 then "Current CY" else Text.From([YearNUM]), 
            type text
          ),
          col_AYSelection = Table.AddColumn(
            col_CYSelection, 
            "AY Selection", 
            each if [AcademicYearOFFSET] = 0 then "Current AY" else [Academic_Year], 
            type text
          ),
          col_FYSelection = Table.AddColumn(
            col_AYSelection, 
            "FY Selection", 
            each if [FiscalYearOFFSET] = 0 then "Current FY" else [Fiscal_Year], 
            type text
          ),

          //-- enter function here
          fn_GetAcQtrOFFSET = 
            let
              fxAddFiscalQuarterOFFSET = (Date as date, FiscalYearStartMonth as number) as number =>
                let
                  CurrentDate = Date.From(DateTime.LocalNow()), 
                  n = 
                    if List.Contains({1 .. 12}, FiscalYearStartMonth) and FiscalYearStartMonth > 1 then
                      FiscalYearStartMonth - 1
                    else
                      0, 
                  FiscalQuarterOFFSET = (
                    (4 * Date.Year(Date.AddMonths(Date.StartOfMonth(Date), - n)))
                      + Date.QuarterOfYear(Date.AddMonths(Date.StartOfMonth(Date), - n))
                  )
                    - (
                      (4 * Date.Year(Date.AddMonths(Date.StartOfMonth(CurrentDate), - n)))
                        + Date.QuarterOfYear(Date.AddMonths(Date.StartOfMonth(CurrentDate), - n))
                    )
                in
                  FiscalQuarterOFFSET
            in
              fxAddFiscalQuarterOFFSET, 

          //-- Restart table here
          col_AYQtrOFFSET = Table.AddColumn(
            col_FYSelection, 
            "AcademicQuarterOFFSET", 
            each fn_GetAcQtrOFFSET([Date], AYStartMonth), 
            Int64.Type
          ), 
          col_FYQtrOFFSET = Table.AddColumn(
            col_AYQtrOFFSET, 
            "FiscalQuarterOFFSET", 
            each fn_GetAcQtrOFFSET([Date], FYStartMonth), 
            Int64.Type
          ), 
          col_isCurrFY = Table.AddColumn(
            col_FYQtrOFFSET, 
            "IsCurrentFY", 
            each if [Fiscal Year] = var_CurrFY then true else false, 
            type logical
          ), 
          col_isCurrAY = Table.AddColumn(
            col_isCurrFY, 
            "IsCurrentAY", 
            each if [Academic Year] = var_CurrAY then true else false, 
            type logical
          ), 
          col_isCurrFQ = Table.AddColumn(
            col_isCurrAY, 
            "IsCurrentFQ", 
            each if [FiscalQuarterYearINT] = var_CurrFQ then true else false, 
            type logical
          ), 
          col_isCurrAQ = Table.AddColumn(
            col_isCurrFQ, 
            "IsCurrentAQ", 
            each if [AcademicQuarterYearINT] = var_CurrAQ then true else false, 
            type logical
          ), 
          col_isCurrFP = Table.AddColumn(
            col_isCurrAQ, 
            "IsCurrentFP", 
            each if [FiscalPeriodYearINT] = var_CurrFP then true else false, 
            type logical
          ), 
          col_isCurrAP = Table.AddColumn(
            col_isCurrFP, 
            "IsCurrentAP", 
            each if [AcademicPeriodYearINT] = var_CurrAP then true else false, 
            type logical
          ), 
          col_isCurrFW = Table.AddColumn(
            col_isCurrAP, 
            "IsCurrentFW", 
            each if [FiscalWeekYearINT] = var_CurrFW then true else false, 
            type logical
          ), 
          col_isPrevYTD = Table.AddColumn(
            col_isCurrFW, 
            "IsPreviousYTD", 
            each 
              if var_CurrYear - 1 = [YearNUM] and [DayYearNUM] <= rec_CurrentDate{0}[DayYearNUM] then
                true
              else
                false, 
            type logical
          ), 
          list_PrevFiscalYearDates = List.Buffer(
            Table.SelectRows(
              Table.ExpandTableColumn(
                Table.NestedJoin(
                  Table.AddIndexColumn(
                    Table.RenameColumns(
                      Table.TransformColumnTypes(
                        Table.FromList(
                          List.Dates(
                            var_PFFD, 
                            Number.From(var_FFD - var_PFFD), 
                            #duration(1, 0, 0, 0)
                          ), 
                          Splitter.SplitByNothing()
                        ), 
                        {{"Column1", type date}}
                      ), 
                      {{"Column1", "DateFY"}}
                    ), 
                    "Index", 
                    1, 
                    1
                  ), 
                  {"Index"}, 
                  Table.AddIndexColumn(
                    Table.RenameColumns(
                      Table.TransformColumnTypes(
                        Table.FromList(
                          List.Dates(
                            Date.AddYears(var_PFFD, + 0), 
                            Number.From(var_PFFD - Date.AddYears(var_PFFD, - 1)), 
                            #duration(1, 0, 0, 0)
                          ), 
                          Splitter.SplitByNothing()
                        ), 
                        {{"Column1", type date}}
                      ), 
                      {{"Column1", "DateFY"}}
                    ), 
                    "Index", 
                    1, 
                    1
                  ), 
                  {"Index"}, 
                  "Table", 
                  JoinKind.LeftOuter
                ), 
                "Table", 
                {"DateFY"}, 
                {"PrevDateFY"}
              ), 
              each [DateFY] <= var_CurrentDate
            )[PrevDateFY]
          ), 
          col_isPrevFY = Table.AddColumn(
            col_isPrevYTD, 
            "IsPreviousFY", 
            each 
              if [FiscalYearOFFSET] = - 1 and List.Contains(list_PrevFiscalYearDates, [Date]) then
                true
              else
                false, 
            type logical
          ), 
          col_isPrevAY = Table.AddColumn(
            col_isPrevFY, 
            "IsPreviousAY", 
            each if [AcademicYearOFFSET] = - 1 then true else false, 
            type logical
          ), 
          
          col_NetWorkDays = 
            if AddRelativeNetWorkdays = true then
              Table.AddColumn(
                col_isPrevAY, 
                "Relative Networkdays", 
                each fxNETWORKDAYS(StartDate, [Date], Holidays), 
                type number
              )
            else
              col_isPrevAY, 
      extend_calendar = 
      let

date_periods = let
tbl_weekly = Table.AddColumn( col_NetWorkDays, "2W Date", each if Number.Mod(Date.WeekOfYear([Date]), 2) = 1 then Date.EndOfWeek([Date], Day.Monday) else Date.EndOfWeek(Date.AddDays([Date], - 7), Day.Monday), type date ),
tbl_fortnightly = Table.AddColumn(tbl_weekly, "2M Date", each Date.EndOfMonth(Date.AddMonths([Date], - (Number.Mod(Date.Month([Date]) - 1, 2)))), type date),
tbl_quarterly = Table.AddColumn(tbl_fortnightly, "3W Date", each Date.EndOfMonth(Date.AddMonths([Date], - (Number.Mod(Date.Month([Date]) - 1, 3)))), type date),
tbl_biannually = Table.AddColumn(tbl_fortnightly, "6M Date", each Date.EndOfMonth(Date.AddMonths([Date], - (Number.Mod(Date.Month([Date]) - 1, 6)))), type date),
tbl_ouputs = tbl_biannually
in tbl_ouputs,


fiscal_academic_periods = let
     FY_TBL = Table.RenameColumns( Table.Group(  Table.Distinct( Table.SelectColumns(date_periods,{"Month Start", "Month End", "FiscalPeriodYearINT", "FiscalQuarterYearINT"}) , {"FiscalPeriodYearINT"}) , {"FiscalQuarterYearINT"}, {{"Fiscal Quarter Month Start", each List.Min([Month Start]), type date}, {"Fiscal Quarter Month End", each List.Max([Month End]), type date}}) ,{{"FiscalQuarterYearINT", "FiscalKey"}}),
     AY_TBL = Table.RenameColumns( Table.Group(  Table.Distinct( Table.SelectColumns(date_periods,{"Month Start", "Month End", "AcademicPeriodYearINT", "AcademicQuarterYearINT"}) , {"AcademicPeriodYearINT"}) , {"AcademicQuarterYearINT"}, {{"Academic Quarter Month Start", each List.Min([Month Start]), type date}, {"Academic Quarter Month End", each List.Max([Month End]), type date}}) ,{{"AcademicQuarterYearINT", "AcademicKey"}}),
     tbl_fiscal = Table.Join(date_periods, {"FiscalQuarterYearINT"}, FY_TBL, {"FiscalKey"}, JoinKind.LeftOuter, JoinAlgorithm.SortMerge ) ,
     tbl_academic = Table.Join(tbl_fiscal, {"AcademicQuarterYearINT"}, AY_TBL, {"AcademicKey"}, JoinKind.LeftOuter, JoinAlgorithm.SortMerge ),
     tbl_merges = Table.RemoveColumns( tbl_academic, {"FiscalKey", "AcademicKey"} )
in tbl_merges

in fiscal_academic_periods,

          // function starts here
          fxNETWORKDAYS = (StartDate, EndDate, optional Holidays as list) =>
            let
              list_Dates = List.Dates(
                StartDate, 
                Number.From(EndDate - StartDate) + 1, 
                Duration.From(1)
              ), 
              DeleteHolidays = 
                if Holidays = null then
                  list_Dates
                else
                  List.Difference(list_Dates, List.Transform(Holidays, Date.From)), 
              DeleteWeekends = List.Select(DeleteHolidays, each Date.DayOfWeek(_, Day.Monday) < 5), 
              CountDays = List.Count(DeleteWeekends)
            in
              CountDays,

          // function ends here


          cols_RemoveToday = Table.RemoveColumns(
            if EndDate < var_CurrentDate then
              Table.SelectRows(extend_calendar, each ([Date] <> var_CurrentDate))
            else
              extend_calendar, 
            {"DayYearNUM", "FiscalFirstDate"}
          ), 
          cols_Format = Table.TransformColumnTypes(
            cols_RemoveToday, 
            {
              {"YearNUM", Int64.Type}, 
              {"QuarterNUM", Int64.Type}, 
              {"MonthNUM", Int64.Type}, 
              {"DayMonthNUM", Int64.Type}, 
              {"DateINT", Int64.Type}, 
              {"DayWeekNUM", Int64.Type}, 
              {"ISO YearOFFSET", Int64.Type}, 
              {"ISO QuarterYearINT", Int64.Type}, 
              {"ISO QuarterOFFSET", Int64.Type}, 
              {"Week Number", Int64.Type}, 
              {"WeekYearINT", Int64.Type}, 
              {"MonthYearINT", Int64.Type}, 
              {"QuarterYearINT", Int64.Type}, 
              {"FiscalQuarterYearINT", Int64.Type}, 
              {"FiscalPeriodNUM", Int64.Type}, 
              {"FiscalPeriodYearINT", Int64.Type}, 
              {"WeekOFFSET", Int64.Type}, 
              {"MonthOFFSET", Int64.Type}, 
              {"QuarterOFFSET", Int64.Type}, 
              {"YearOFFSET", Int64.Type}, 
              {"FiscalYearOFFSET", Int64.Type}, 
              {"FiscalWeekYearINT", Int64.Type},
              {"Fiscal Week Number", Int64.Type},
              {"DateFW", type date}
            }
          ), 
          cols_Reorder = Table.ReorderColumns(
            cols_Format, 
            {
              "Date",
              "CY Selection", 
              "isYearComplete", 
              "IsYTD",
              "YearNUM", 
              "YearOFFSET", 
              "Academic Year",
              "Academic_Year",
              "AY Selection",
              "Fiscal Year", 
              "Fiscal_Year",
              "FY Selection", 
              "IsFuture",
              "QuarterNUM", 
              "Quarter", 
              "Quarter Start", 
              "Quarter End", 
              "Quarter & Year", 
              "QuarterYearINT", 
              "QuarterOFFSET", 
              "isQuarterComplete", 
              "MonthNUM",
              "FiscalPeriodNUM",
              "Fiscal Month",
              "AcademicPeriodNUM", 
              "Academic Month",
              "Month Start", 
              "Month End", 
              "Month & Year", 
              "MonthYearINT", 
              "MonthOFFSET", 
              "isMonthComplete", 
              "Month Name", 
              "Month Short", 
              "Month Initial", 
              "DayMonthNUM", 
              "Week Number", 
              "Week Start", 
              "Week End", 
              "Week & Year", 
              "WeekYearINT", 
              "WeekOFFSET", 
              "WeekCompleted", 
              "DayWeekNUM", 
              "Day of Week Name", 
              "Day Initial", 
              "DateINT", 
              "DayOffset", 
              "IsAfterToday", 
              "IsWeekDay", 
              "IsHoliday", 
              "IsBusinessDay", 
              "Day Type", 
              "ISO Year", 
              "ISO YearOFFSET", 
              "ISO QuarterNUM", 
              "ISO Quarter", 
              "ISO Quarter & Year", 
              "ISO QuarterYearINT", 
              "ISO QuarterOFFSET", 
              "FiscalYearOFFSET",
              "FiscalQuarterOFFSET", 
              "Fiscal Quarter", 
              "FiscalQuarterYearINT", 
              "Fiscal Quarter Month Start",
              "Fiscal Quarter Month End",
              "Fiscal Period", 
              "FiscalPeriodYearINT", 
              "DateFW", 
              "Fiscal Week Number", 
              "Fiscal Week", 
              "FiscalWeekYearINT",
              "AcademicYearOFFSET", 
              "AcademicQuarterOFFSET",
              "Academic Quarter Month Start",
              "Academic Quarter Month End", 
              "IsCurrentFY", 
              "IsCurrentFQ", 
              "IsCurrentFP", 
              "IsCurrentFW", 
              "IsPreviousYTD", 
              "IsPreviousFY",
              "2W Date",
              "2M Date",
              "6M Date"
            }
          ), 
          AYCols = {
            "Academic Year",
            "Academic_Year",
            "AY Selection",
            "Academic Quarter", 
            "AcademicQuarterYearINT",
            "Academic Quarter Month Start",
            "Academic Quarter Month End", 
            "Academic Month", 
            "AcademicPeriodNUM", 
            "Academic Period", 
            "AcademicPeriodYearINT", 
            "AcademicYearOFFSET", 
            "AcademicQuarterOFFSET",
            "IsCurrentAQ", 
            "IsCurrentAP", 
            "IsPreviousAY", 
            "IsCurrentAY", 
            "AYStartDate",
            "AYEndDate"

          }, 
          FYCols = {
            "ISO QuarterNUM", 
            "Fiscal Year",
            "Fiscal_Year",
            "FY Selection", 
            "Fiscal Quarter", 
            "FiscalQuarterYearINT",
            "Fiscal Quarter Month Start",
            "Fiscal Quarter Month End",
            "Fiscal Month", 
            "FiscalPeriodNUM", 
            "Fiscal Period", 
            "FiscalPeriodYearINT", 
            "DateFW", 
            "Fiscal Week Number", 
            "Fiscal Week", 
            "FiscalWeekYearINT", 
            "FiscalYearOFFSET",
            "FiscalQuarterOFFSET",
            "IsCurrentFQ", 
            "IsCurrentFP", 
            "IsCurrentFW", 
            "IsPreviousFY", 
            "IsCurrentFY"
          }, 
          AllCols = List.Union({FYCols, AYCols}), 
          ListCols = 
            if var_FYAYTest then
              Table.RemoveColumns(cols_Reorder, AllCols)
            else if var_AYLogicTest then
              Table.RemoveColumns(cols_Reorder, AYCols)
            else if var_FYLogicTest then
              Table.RemoveColumns(cols_Reorder, FYCols)
            else
              Table.RemoveColumns(
                cols_Reorder, 
                {"DateFW", "FiscalWeekYearINT", "ISO QuarterNUM" /* "FiscalPeriodNUM",  */                         }
              )
in
    ListCols
        , 
      // ------------------------------------------------------------------     
      /*
  invokeFunction = (
    StartYearNUM as number, 
    EndYearNUM as number, 
    optional FYStartMonthNum as number, 
    optional AYStartMonthNum as number, 
    optional Holidays as list, 
    optional WDStartNum as number, 
    optional AddRelativeNetWorkdays as logical
  ) as table =>
*/
      // 3.0: change parameter metadata here
      fnType = type function (
        // 3.0.1: Calendar Start Year parameter
        StartYearNUM as (
          type number
            meta [
              Documentation.FieldCaption     = " Start Year: #(lf) 4-digit integer ", 
              Documentation.FieldDescription = " 4-digit integer: #(cr,lf) YYYY ", 
              Documentation.SampleValues     = {2021}
            ]
        ), 
        // 3.0.2: Calendar End Year parameter
        EndYearNUM as (
          type number
            meta [
              Documentation.FieldCaption     = " End Year: #(lf) 4-digit integer ", 
              Documentation.FieldDescription = " 4-digit integer: #(cr,lf) YYYY ", 
              Documentation.SampleValues     = {2023}
            ]
        ), 
        // 3.0.3: Fiscal Start Month parameter
        optional FYStartMonthNum as (
          type number
            meta [
              Documentation.FieldCaption     = " Fiscal Month Start: #(lf) Feb = 2 ", 
              Documentation.FieldDescription = " Fiscal Month Start: #(lf) Feb = 2 ", 
              Documentation.SampleValues     = {02}
            ]
        )// 3.0.4: Academic Start Month parameter
        , 
        optional AYStartMonthNum as (
          type number
            meta [
              Documentation.FieldCaption     = " Academic Month Start: #(lf) Aug = 8 ", 
              Documentation.FieldDescription = " Academic Month Start: #(lf) Aug = 8 ", 
              Documentation.SampleValues     = {08}
            ]
        )// 3.0.5: Holidays list parameter
        , 
        optional Holidays as (
          type list
            meta [
              Documentation.FieldCaption     = " Choose holidays as a list ", 
              Documentation.FieldDescription = " Choose holidays as a list ", 
              Documentation.SampleValues     = {"List"}
            ]
        )// 3.0.6: Weekday Start parameter 
        , 
        optional WDStartNum as (
          type number
            meta [
              Documentation.FieldCaption     = " Input weekday start number  ", 
              Documentation.FieldDescription = " Input weekday start number ", 
              Documentation.SampleValues     = {01}
            ]
        )// 3.0.7: AddRelativeNetWorkdays parameter 
        , 
        optional AddRelativeNetWorkdays as (
          type logical
            meta [
              Documentation.FieldCaption     = " Input relative network days as boolean ", 
              Documentation.FieldDescription = " Input relative network days as boolean ", 
              Documentation.SampleValues     = {"True/False"}
            ]
        )
      // 3.1: parameter return type   
      ) as list, 
      // ------------------------------------------------------------------
     
      // ------------------------------------------------------------------
      // 5.0: Choose between Parameter Documentation or Function Documentation
      functionDocumentation =  // -- function metadata                       
      Value.ReplaceType(
        invokeFunction, 
        Value.ReplaceMetadata(Value.Type(invokeFunction), documentation)
      ), 
      parameterDocumentation =  // -- parameter metadata                        
      Value.ReplaceType(functionDocumentation, fnType)
    in
      // ------------------------------------------------------------------
      // select one of the above steps and paste below
      functionDocumentation /* <-- Choose final documentation type */                                         
in
  customFunction
