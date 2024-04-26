let
    // Define metadata for the function, describing its purpose and usage.
    metaDocumentation = type function (
        baseURL as (type text meta [
            Documentation.FieldCaption = "SharePoint base url without ending ""/""",
            Documentation.SampleValues = {"https://<sharepoint site>"},
            Formatting.IsMultiLine = false,
            Formatting.IsCode = false
        ]),
        listName as (type text meta [
            Documentation.FieldCaption = "SharePoint list or Document Library",
            Documentation.SampleValues = {"<list name>"},
            Formatting.IsMultiLine = false,
            Formatting.IsCode = false
        ]),
        optional waitTime as (type number meta [
            Documentation.FieldCaption = "Wait time between API calls in seconds",
            Documentation.SampleValues = {0.1},
            Formatting.IsMultiLine = false,
            Formatting.IsCode = false
        ]),
        optional selectedColumns as (type text meta [
            Documentation.FieldCaption = "Selected columns separated by comma",
            Documentation.SampleValues = {"Id,FsObjType,Person/EMail"},
            Formatting.IsMultiLine = false,
            Formatting.IsCode = false
        ]),
        optional expandedColumns as (type text meta [
            Documentation.FieldCaption = "Selected the columns that require expansion",
            Documentation.SampleValues = {"Person"},
            Formatting.IsMultiLine = false,
            Formatting.IsCode = false
        ]),
        optional appliedFilter as (type text meta [
            Documentation.FieldCaption = "Filter to be applied",
            Documentation.SampleValues = {"FSObjType eq 0"},
            Formatting.IsMultiLine = false,
            Formatting.IsCode = false
        ])
    ) as any meta [
        Documentation.Name = "SharePoint List Paginated",
        Documentation.LongDescription = 
            //This is the description of the documentation, it only accepts a handful of HTML tags for formatting.
            "    
                <p><b>SharePoint List Paginated</b></p>
                <li><b>Creator: </b>oscar Martinez.</li>
                <li><b>LinkedIn:</b> https://www.linkedin.com/in/oscarmartinezv/</li>
                <li><b>Web: </b>https://bibb.pro</li>

                <p>This function will retrieve all the elements of a SharePoint list or document library. 
                It works with very big document libraries or lists as it has paging mechanism</p>
 
                <p><b>References</b></p>
                <p>Big thanks to Rob Reily and googlogmobi for their entries that made this possible. </p>
                <p>https://www.linkedin.com/pulse/loading-data-paged-related-from-ms-graph-api-power-bi-rob-reilly/</p>
                <p>https://community.powerbi.com/t5/Power-Query/Dynamic-data-sources-aren-t-refreshed-in-the-Power-BI-service/td-p/1563630</p>
            "
    ],
    // Define the main function
    myFunction = (
        baseURL as text, 
        listName as text, 
        optional waitTime as number, 
        optional selectedColumns as text, 
        optional expandedColumns as text,
        optional appliedFilter as text
    )=>
        let 
            selectSPColumns= if selectedColumns is null then "" else "&$select=" & selectedColumns,
            selectExpandedColumns= if expandedColumns is null then "" else "&$expand=" & expandedColumns,
            selectedWaitTime = if waitTime is null then 0.1 else waitTime,
            selectedAppliedFilter = if appliedFilter is null then "" else "&$filter=" & appliedFilter,
            GetPages = (Path) =>
                let
                    Source = Json.Document(
                        Web.Contents(
                            baseURL, 
                            [
                                RelativePath = Path,
                                Headers=[
                                    Accept="application/json;odata=nometadata"
                                ]
                            ]
                        )
                    ),
                    ll= Source[value],
                    Next = Text.Replace(Source[odata.nextLink], baseURL, ""),
                    result = try @ll & Function.InvokeAfter(()=> @GetPages(Next) , #duration(0,0,0,selectedWaitTime)) otherwise @ll
                in
                result,
                
                Fullset = GetPages("/_api/web/lists/getbytitle('"&listName&"')/items?"
                    & selectSPColumns 
                    & selectExpandedColumns
                    & selectedAppliedFilter
                ),
            #"Converted to Table" = Table.FromList(Fullset, Splitter.SplitByNothing(), null, null, ExtraValues.Error)
        in 
            #"Converted to Table"
in
    // Apply the function metadata to myFunction.
    Value.ReplaceType(myFunction, metaDocumentation)