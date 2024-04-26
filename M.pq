let

    GitHubUser = "OscarValerock",
    GitHubRepo = "PowerQueryFunctions",
    BaseURL = "https://api.github.com/repos/",
    PAT = "", // Personal Access Token (PAT) for GitHub API https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/managing-your-personal-access-tokens
    QueryHeaders = if PAT <> ""
        then
            [Authorization = "Bearer  " & PAT] 
        else
            [],

    #"Get Trees all trees" = Json.Document(
        Web.Contents(
            BaseURL,[
                 RelativePath = GitHubUser&"/"&GitHubRepo&"/git/trees/main",
                 Query = [],
                 Headers = QueryHeaders
             ]
        )
    ),
    funtionTree = #"Get Trees all trees"[tree],
    filterList = List.Select(funtionTree, each _[path] = "Functions"){0}[sha],

    #"Get Trees from functions" = Json.Document(
        Web.Contents(
            BaseURL,[
                 RelativePath = GitHubUser&"/"&GitHubRepo&"/git/trees/"&filterList,
                 Query = [],
                 Headers = QueryHeaders
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
                 Query = [],
                 Headers = QueryHeaders
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
                    Query = [],
                    Headers = QueryHeaders
                ]
            ))[content],
            #"To function" = 
                Expression.Evaluate(
                    Text.FromBinary(
                        Binary.FromText(#"Get functions fx")
                    ),
                    [ 
                        Any.Type = Any.Type,
                        Binary.ToText = Binary.ToText,
                        BinaryEncoding.Base64 = BinaryEncoding.Base64,
                        Character.FromNumber = Character.FromNumber,
                        Comparer.OrdinalIgnoreCase = Comparer.OrdinalIgnoreCase,
                        Date.AddDays = Date.AddDays,
                        Date.AddMonths = Date.AddMonths,
                        Date.AddYears = Date.AddYears,
                        Date.Day = Date.Day,
                        Date.DayOfWeek = Date.DayOfWeek,
                        Date.DayOfWeekName = Date.DayOfWeekName,
                        Date.DayOfYear = Date.DayOfYear,
                        Date.DaysInMonth = Date.DaysInMonth,
                        Date.EndOfMonth = Date.EndOfMonth,
                        Date.EndOfQuarter = Date.EndOfQuarter,
                        Date.EndOfWeek = Date.EndOfWeek,
                        Date.EndOfYear = Date.EndOfYear,
                        Date.From = Date.From,
                        Date.Month = Date.Month,
                        Date.MonthName = Date.MonthName,
                        Date.QuarterOfYear = Date.QuarterOfYear,
                        Date.StartOfMonth = Date.StartOfMonth,
                        Date.StartOfQuarter = Date.StartOfQuarter,
                        Date.StartOfWeek = Date.StartOfWeek,
                        Date.ToText = Date.ToText,
                        Date.Type = Date.Type,
                        Date.WeekOfYear = Date.WeekOfYear,
                        Date.Year = Date.Year,
                        DateTime.FixedLocalNow = DateTime.FixedLocalNow,
                        DateTime.LocalNow = DateTime.LocalNow,
                        DateTime.Type = DateTime.Type,
                        DateTimeZone.Type = DateTimeZone.Type,
                        DateTimeZone.ZoneHours = DateTimeZone.ZoneHours,
                        DateTimeZone.ZoneMinutes = DateTimeZone.ZoneMinutes,
                        Day.Friday = Day.Friday,
                        Day.Monday = Day.Monday,
                        Duration.Days = Duration.Days,
                        Duration.From = Duration.From,
                        Duration.Hours = Duration.Hours,
                        Duration.Minutes = Duration.Minutes,
                        Duration.Seconds = Duration.Seconds,
                        Duration.Type = Duration.Type,
                        ExtraValues.Error = ExtraValues.Error,
                        Function.InvokeAfter = Function.InvokeAfter,
                        Int64.From = Int64.From,
                        Int64.Type = Int64.Type,
                        JoinAlgorithm.SortMerge = JoinAlgorithm.SortMerge,
                        JoinKind.LeftOuter = JoinKind.LeftOuter,
                        Json.Document = Json.Document,
                        Json.FromValue = Json.FromValue,
                        Lines.FromBinary = Lines.FromBinary,
                        List.Accumulate = List.Accumulate,
                        List.Average = List.Average,
                        List.Buffer = List.Buffer,
                        List.Combine = List.Combine,
                        List.Contains = List.Contains,
                        List.Count = List.Count,
                        List.Dates = List.Dates,
                        List.Difference = List.Difference,
                        List.Distinct = List.Distinct,
                        List.First = List.First,
                        List.Generate = List.Generate,
                        List.IsEmpty = List.IsEmpty,
                        List.MatchesAny = List.MatchesAny,
                        List.Max = List.Max,
                        List.Median = List.Median,
                        List.Min = List.Min,
                        List.Product = List.Product,
                        List.RemoveItems = List.RemoveItems,
                        List.RemoveNulls = List.RemoveNulls,
                        List.Select = List.Select,
                        List.StandardDeviation = List.StandardDeviation,
                        List.Sum = List.Sum,
                        List.Transform = List.Transform,
                        List.Type = List.Type,
                        List.Union = List.Union,
                        List.Zip = List.Zip,
                        Logical.Type = Logical.Type,
                        Number.Abs = Number.Abs,
                        Number.From = Number.From,
                        Number.IntegerDivide = Number.IntegerDivide,
                        Number.Mod = Number.Mod,
                        Number.PositiveInfinity = Number.PositiveInfinity,
                        Number.Power = Number.Power,
                        Number.RoundDown = Number.RoundDown,
                        Number.RoundUp = Number.RoundUp,
                        Number.ToText = Number.ToText,
                        Number.Type = Number.Type,
                        Order.Descending = Order.Descending,
                        Record.Field = Record.Field,
                        Record.FieldNames = Record.FieldNames,
                        Record.FieldValues = Record.FieldValues,
                        Record.FromList = Record.FromList,
                        Replacer.ReplaceValue = Replacer.ReplaceValue,
                        Splitter.SplitByNothing = Splitter.SplitByNothing,
                        Splitter.SplitTextByRepeatedLengths = Splitter.SplitTextByRepeatedLengths,
                        Table.AddColumn = Table.AddColumn,
                        Table.AddIndexColumn = Table.AddIndexColumn,
                        Table.Buffer = Table.Buffer,
                        Table.Column = Table.Column,
                        Table.ColumnNames = Table.ColumnNames,
                        Table.Combine = Table.Combine,
                        Table.Distinct = Table.Distinct,
                        Table.DuplicateColumn = Table.DuplicateColumn,
                        Table.ExpandTableColumn = Table.ExpandTableColumn,
                        Table.FromList = Table.FromList,
                        Table.FromRecords = Table.FromRecords,
                        Table.FromRows = Table.FromRows,
                        Table.FromValue = Table.FromValue,
                        Table.Group = Table.Group,
                        Table.Join = Table.Join,
                        Table.NestedJoin = Table.NestedJoin,
                        Table.RemoveColumns = Table.RemoveColumns,
                        Table.RenameColumns = Table.RenameColumns,
                        Table.ReorderColumns = Table.ReorderColumns,
                        Table.ReplaceValue = Table.ReplaceValue,
                        Table.RowCount = Table.RowCount,
                        Table.Schema = Table.Schema,
                        Table.SelectColumns = Table.SelectColumns,
                        Table.SelectRows = Table.SelectRows,
                        Table.Sort = Table.Sort,
                        Table.ToRecords = Table.ToRecords,
                        Table.ToRows = Table.ToRows,
                        Table.TransformColumnTypes = Table.TransformColumnTypes,
                        Table.TransformColumns = Table.TransformColumns,
                        Text.BeforeDelimiter = Text.BeforeDelimiter,
                        Text.Combine = Text.Combine,
                        Text.Contains = Text.Contains,
                        Text.End = Text.End,
                        Text.From = Text.From,
                        Text.PadEnd = Text.PadEnd,
                        Text.PadStart = Text.PadStart,
                        Text.Proper = Text.Proper,
                        Text.Repeat = Text.Repeat,
                        Text.Replace = Text.Replace,
                        Text.SplitAny = Text.SplitAny,
                        Text.Start = Text.Start,
                        Text.ToBinary = Text.ToBinary,
                        Text.Type = Text.Type,
                        Time.Hour = Time.Hour,
                        Time.Minute = Time.Minute,
                        Time.Second = Time.Second,
                        Time.Type = Time.Type,
                        Type.Is = Type.Is,
                        Value.ReplaceMetadata = Value.ReplaceMetadata,
                        Value.ReplaceType = Value.ReplaceType,
                        Value.Type = Value.Type
                        //,Web.Contents = Web.Contents //Unfortunately adding this function to the M code will create a dynamic error :(
                    ]
                )
        in
            #"To function",
    #"Get PQ text fx" = (relativePath as text) => 
        let 
            #"Get functions fx" = Json.Document(Web.Contents(
                BaseURL,[
                    RelativePath = GitHubUser&"/"&GitHubRepo&"/git/blobs/"&relativePath,
                    Query = [],
                    Headers = QueryHeaders
                ]
            ))[content],
            #"To function" = 
                Text.FromBinary(Binary.FromText(#"Get functions fx"))

        in
            #"To function",
    #"Get PQ functions" = Table.TransformColumns(
        #"Extracted Text After Delimiter",
        {
            "url", each try #"Get PQ functions fx"(_) otherwise  #"Get PQ text fx"(_)
        }
    ),
    #"Merged Columns" = Table.CombineColumns(#"Get PQ functions",{"Type","Path"},Combiner.CombineTextByDelimiter(".", QuoteStyle.None),"Name"),
    #"ConvertToRecords" = Record.FromTable(Table.RenameColumns(#"Merged Columns",{{"url", "Value"}}))
in
    #"ConvertToRecords"
