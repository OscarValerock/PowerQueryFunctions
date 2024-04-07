let

    picresult = (InputTable as table, InputBinaryZBPosition as number, InputKeyZBPosition as number ) as table  =>

let
    
    
    //Get list of files in folder
    Source = (InputTable),
    //Converts table that contians image to list
    ListToInput = Table.ToRows(Source),
    //Creates Splitter function
    SplitTextFunction = Splitter.SplitTextByRepeatedLengths(30000),
    //Function to convert binary of photo to multiple
    ConvertOneFile = (InputRow as list) =>
        let
            BinaryIn = InputRow{InputBinaryZBPosition},
            ID = InputRow{InputKeyZBPosition},
            BinaryText = Binary.ToText(BinaryIn, BinaryEncoding.Base64),
            SplitUpText = SplitTextFunction(BinaryText),
            AddFileName = List.Transform(SplitUpText, each {ID,_})
        in
            AddFileName,
    //Loops over all photos and calls the above function
    ConvertAllRows = List.Transform(ListToInput, each ConvertOneFile(_)),
    //Combines lists together
    CombineLists = List.Combine(ConvertAllRows),
    //Converts results to table
    ToTable = #table(type table[ID=text,Pic=text],CombineLists),
    //Adds index column to output table
    AddIndexColumn = Table.AddIndexColumn(ToTable, "Index", 0, 1)
in
    AddIndexColumn,
    documentation = [
        Documentation.Name =  " Picture.binary",
        Documentation.Description = " Returns a list of hours (datetime) that lie between the <code>Start</code> and <code>End</code>  ",
        Documentation.LongDescription = " Returns a list of hours (datetime) that lie between the <code>Start</code> and <code>End</code>  ",
        Documentation.Category = " DateTime ",
        Documentation.Source = " . https://goo.gl/1mJHpP . ",
        Documentation.Version = " 1.0 ",
        Documentation.Author = " BillSzysz https://goo.gl/1mJHpP . ",
        Documentation.Examples = {[Description =  "  ",
        Code = " DateTime.HoursBetween( #datetime(2018, 7, 8, 1, 0, 0), #datetime(2018, 7, 8, 4, 29, 0) ) ",
        Result = " {""08/07/2018 01:00:00"", ""08/07/2018 02:00:00"", ""08/07/2018 03:00:00"", ""08/07/2018 04:00:00""} "]}
    ]

in
    Value.ReplaceType(picresult, Value.ReplaceMetadata(Value.Type(picresult), documentation))  
