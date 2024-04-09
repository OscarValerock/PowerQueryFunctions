let

    GitHubUser = "OscarValerock",
    GitHubRepo = "PowerQueryFunctions",
    BaseURL = "https://api.github.com/repos/",

    #"Get Trees all trees" = Json.Document(
        Web.Contents(
            BaseURL,[
                 RelativePath = GitHubUser&"/"&GitHubRepo&"/git/trees/main",
                 Query = []
             ]
        )
    ),
    funtionTree = #"Get Trees all trees"[tree],
    filterList = List.Select(funtionTree, each _[path] = "Functions"){0}[sha],

    #"Get Trees from functions" = Json.Document(
        Web.Contents(
            BaseURL,[
                 RelativePath = GitHubUser&"/"&GitHubRepo&"/git/trees/"&filterList,
                 Query = []
             ]
        )
    ),
    tree = #"Get Trees from functions"[tree],
    #"Converted to Table" = Table.FromList(tree, Splitter.SplitByNothing(), null, null, ExtraValues.Error),
    #"Expanded Column1" = Table.ExpandRecordColumn(#"Converted to Table", "Column1", {"path", "sha"}, {"Type", "Sha"}),
    #"Get Functions from Github fx" = (tree as text) => Json.Document(
        Web.Contents(
            BaseURL,[
                 RelativePath = GitHubUser&"/"&GitHubRepo&"/git/trees/"& tree,
                 Query = []
             ]
        )
    )[tree],
    #"Get Functions from Github" = Table.TransformColumns(
        #"Expanded Column1",
        {
            "Sha", each #"Get Functions from Github fx"(_)
        }
    ),
    #"Expanded Sha" = Table.ExpandListColumn(#"Get Functions from Github", "Sha"),
    #"Expanded Sha1" = Table.ExpandRecordColumn(#"Expanded Sha", "Sha", {"path", "url"}, {"Path", "url"}),
    #"Filtered Rows" = Table.SelectRows(#"Expanded Sha1", each Text.Contains([Path], ".pq")),
    #"Replaced Value" = Table.ReplaceValue(#"Filtered Rows",".pq","",Replacer.ReplaceText,{"Path"}),
    #"Extracted Text After Delimiter" = Table.TransformColumns(#"Replaced Value", {{"url", each Text.AfterDelimiter(_, "/", {0, RelativePosition.FromEnd}), type text}}),
    #"Get PQ functions fx" = (relativePath as text) => 
        let 
            #"Get functions fx" = Json.Document(Web.Contents(
                BaseURL,[
                    RelativePath = GitHubUser&"/"&GitHubRepo&"/git/blobs/"&relativePath,
                    Query = []
                ]
            ))[content],
            #"To text" = 
                Expression.Evaluate(
                    Text.FromBinary(
                        Binary.FromText(#"Get functions fx")
                    ),
                    [ 
                        Binary.ToText = Binary.ToText,
                        BinaryEncoding.Base64 = BinaryEncoding.Base64,
                        Date.AddDays = Date.AddDays,
                        Date.Day = Date.Day,
                        Date.DayOfWeek = Date.DayOfWeek,
                        Date.DayOfWeekName = Date.DayOfWeekName,
                        Date.DayOfYear = Date.DayOfYear,
                        Date.DaysInMonth = Date.DaysInMonth,
                        Date.EndOfMonth = Date.EndOfMonth,
                        Date.EndOfYear = Date.EndOfYear,
                        Date.From = Date.From,
                        Date.Month = Date.Month,
                        Date.MonthName = Date.MonthName,
                        Date.QuarterOfYear = Date.QuarterOfYear,
                        Date.StartOfMonth = Date.StartOfMonth,
                        Date.StartOfWeek = Date.StartOfWeek,
                        Date.ToText = Date.ToText,
                        Date.Type = Date.Type,
                        Date.Year = Date.Year,
                        DateTime.LocalNow = DateTime.LocalNow,
                        Day.Friday = Day.Friday,
                        Day.Monday = Day.Monday,
                        Documentation.Author = Documentation.Author,
                        Documentation.Category = Documentation.Category,
                        Documentation.Description = Documentation.Description,
                        Documentation.Name = Documentation.Name,
                        Documentation.Source = Documentation.Source,
                        Documentation.Version = Documentation.Version,
                        Duration.Days = Duration.Days,
                        Int64.Type = Int64.Type,
                        Json.Document= Json.Document,
                        List.Combine = List.Combine,
                        List.Dates = List.Dates,
                        List.Transform = List.Transform,
                        Number.From = Number.From,
                        Splitter.SplitByNothing = Splitter.SplitByNothing,
                        Splitter.SplitTextByRepeatedLengths = Splitter.SplitTextByRepeatedLengths,
                        Table.AddColumn = Table.AddColumn,
                        Table.AddIndexColumn = Table.AddIndexColumn,
                        Table.FromList = Table.FromList,
                        Table.ToRows = Table.ToRows,
                        Text.From = Text.From,
                        Text.ToBinary = Text.ToBinary,
                        Value.ReplaceMetadata = Value.ReplaceMetadata,
                        Value.ReplaceType = Value.ReplaceType,
                        Value.Type = Value.Type,
                        Web.Contents = Web.Contents
                    ]
                )
        in
            #"To text",

    #"Get PQ functions" = Table.TransformColumns(
        #"Extracted Text After Delimiter",
        {
            "url", each #"Get PQ functions fx"(_)
        }
    ),
    #"Merged Columns" = Table.CombineColumns(#"Get PQ functions",{"Type","Path"},Combiner.CombineTextByDelimiter(".", QuoteStyle.None),"Name"),
    #"Renamed Columns" = Record.FromTable(Table.RenameColumns(#"Merged Columns",{{"url", "Value"}}))
in
    #"Renamed Columns"
