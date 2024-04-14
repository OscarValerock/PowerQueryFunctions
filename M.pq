

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
                        Any.Type = Any.Type,
                        Binary.ToText = Binary.ToText,
                        BinaryEncoding.Base64 = BinaryEncoding.Base64,
                        Date.AddDays = Date.AddDays,
                        Date.Day = Date.Day,
                        Date.DayOfWeek = Date.DayOfWeek,
                        Date.DayOfWeekName = Date.DayOfWeekName,
                        Date.DayOfYear = Date.DayOfYear,
                        Date.DaysInMonth = Date.DaysInMonth,
                        Date.EndOfMonth = Date.EndOfMonth,
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
                        DateTime.Type = DateTime.Type,
                        DateTimeZone.Type = DateTimeZone.Type,
                        DateTimeZone.ZoneHours = DateTimeZone.ZoneHours,
                        DateTimeZone.ZoneMinutes = DateTimeZone.ZoneMinutes,
                        Day.Friday = Day.Friday,
                        Day.Monday = Day.Monday,
                        Duration.Days = Duration.Days,
                        Duration.Hours = Duration.Hours,
                        Duration.Minutes = Duration.Minutes,
                        Duration.Seconds = Duration.Seconds,
                        Duration.Type = Duration.Type,
                        ExtraValues.Error = ExtraValues.Error,
                        Function.InvokeAfter = Function.InvokeAfter,
                        Int64.Type = Int64.Type,
                        Json.Document = Json.Document,
                        Json.FromValue = Json.FromValue,
                        Lines.FromBinary = Lines.FromBinary,
                        List.Accumulate = List.Accumulate,
                        List.Combine = List.Combine,
                        List.Dates = List.Dates,
                        List.IsEmpty = List.IsEmpty,
                        List.MatchesAny = List.MatchesAny,
                        List.RemoveItems = List.RemoveItems,
                        List.Transform = List.Transform,
                        List.Type = List.Type,
                        Logical.Type = Logical.Type,
                        Number.From = Number.From,
                        Number.IntegerDivide = Number.IntegerDivide,
                        Number.Type = Number.Type,
                        Splitter.SplitByNothing = Splitter.SplitByNothing,
                        Splitter.SplitTextByRepeatedLengths = Splitter.SplitTextByRepeatedLengths,
                        Table.AddColumn = Table.AddColumn,
                        Table.AddIndexColumn = Table.AddIndexColumn,
                        Table.ExpandTableColumn = Table.ExpandTableColumn,
                        Table.FromList = Table.FromList,
                        Table.FromRows = Table.FromRows,
                        Table.FromValue = Table.FromValue,
                        Table.Group = Table.Group,
                        Table.Schema = Table.Schema,
                        Table.ToRecords = Table.ToRecords,
                        Table.ToRows = Table.ToRows,
                        Table.TransformColumns = Table.TransformColumns,
                        Text.BeforeDelimiter = Text.BeforeDelimiter,
                        Text.Combine = Text.Combine,
                        Text.From = Text.From,
                        Text.Repeat = Text.Repeat,
                        Text.Replace = Text.Replace,
                        Text.ToBinary = Text.ToBinary,
                        Text.Type = Text.Type,
                        Time.Hour = Time.Hour,
                        Time.Minute = Time.Minute,
                        Time.Second = Time.Second,
                        Time.Type = Time.Type,
                        Value.ReplaceType = Value.ReplaceType,
                        Value.Type = Value.Type
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
