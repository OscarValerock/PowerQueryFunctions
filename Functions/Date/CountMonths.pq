let pq_custom_function =

let
    // Define metadata for the function, describing its purpose and usage.
    metaDocumentation = type function (
        StartDate as (type date meta [
            Documentation.FieldCaption = "Start Date",
            Documentation.SampleValues = {" 01/01/2024 (dd/MM/yyyy) "},
            // Documentation.AllowedValues = {"01/01/2024"},
            Formatting.IsMultiLine = false,
            Formatting.IsCode = false
        ]),
        EndDate as (type date meta [
            Documentation.FieldCaption = "End Date",
            Documentation.SampleValues = {" 31/01/2024 (dd/MM/yyyy) "},
            // Documentation.AllowedValues = {"31/01/2025"},
            Formatting.IsMultiLine = false,
            Formatting.IsCode = false
        ]),
        optional CompletedMonthsOnly as (type nullable logical meta [
            Documentation.FieldCaption = "Do you want to count completed months only?",
            Documentation.FieldDescription = "Count by completed months (true) or actual months (false)",
            Documentation.SampleValues = {"True", "False"},
            Documentation.AllowedValues = {true,false},
            Formatting.IsMultiLine = false,
            Formatting.IsCode = true
        ])
    ) as list meta [
        Documentation.Name = "fnCountMonths",
        
        Documentation.LongDescription = 
        "    
                <p><b>  Count Months Between Dates  </b></p>

                <li>------------------------------------------------------</li>
                
                <li><b>  Creator: </b> Imran Haq  </li>
                <li><b>  Web: </b> https://github.com/PBIQueryous  </li>
                <li><b>  Acknowledgements: </b>   </li>
                <li><b>  LinkedIn: </b>   </li>

                <li>------------------------------------------------------</li>

                <li><b>  Editor: </b>  Oscar Martinez  </li>
                <li><b>  Web: </b>  https://bibb.pro  </li>
                <li><b>  LinkedIn: </b>  https://www.linkedin.com/in/oscarmartinezv/  </li>

                <li>------------------------------------------------------</li>

                <p><b>  Function Description:  </b></br>
                This function counts the number of months between the a selected Start Date and End Date. The third parameter allow you to count either complete months or actual months
                
                <p><b>  Parameters:  </b></br>
                <ul>
                    <li><b>  • StartDate:  </b>  The Start Date field from your data. <code> (eg: 01/01/2024) </code> </li>
                    <li><b>  • EndDate:  </b>  The End Date field from your data. <code> (eg: 31/12/2025) </code> </li>
                    <li><b>  • CompletedMonthsOnly:  </b>  Select 'true' to count only completed months, 'false' for actual months. </li>
                    
                </ul>

                <b>  Returns:  </b></br>
                A custom column.

                <p><b>  formula bar (fx) example:  </b></br>
                <code>  fn_CountMonths( [StartDate], [EndDate], true )  </code>
                
            "
    ],
    // Define the main function
    
myFunction = (StartDate as date, EndDate as date, optional CompletedMonthsOnly as nullable logical) =>

  let invoke_custom_function =
// paste your custom function here
// _______________________________
        let
          countWholeMonths = if (CompletedMonthsOnly ?? true) = true then -1 else 0, 
          MonthsList = List.Generate(
            () => [DateValue = Date.From(StartDate)], 
            each Date.From([DateValue]) <= Date.AddDays(Date.StartOfMonth(Date.From(EndDate)), countWholeMonths), 
            each [DateValue = Date.AddMonths([DateValue], 1)], 
            each Date.From([DateValue])
          ), 
          MonthsCount = Int64.From(List.Count(MonthsList))
        in
          MonthsCount
// _______________________________
  in invoke_custom_function,
        
    replaceMetaData = Value.ReplaceType(myFunction, metaDocumentation)
        
  in
    replaceMetaData
in
  pq_custom_function
