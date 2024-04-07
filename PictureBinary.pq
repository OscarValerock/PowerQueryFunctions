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
        Documentation.Name =  " PictureBinary",
        Documentation.Description = "Returns the base64 encoded binary of a picture, broken in 30K chunks, in a table which can be later stitche via DAX",
        Documentation.LongDescription = "Returns the base64 encoded binary of a picture, broken in 30K chunks, in a table which can be later stitche via DAX",
        Documentation.Category = "File Operations",
        Documentation.Source = " . https://goo.gl/1mJHpP . ",
        Documentation.Version = " 1.0 ",
        Documentation.Author = "Oscar martinez"
    ]

in
    Value.ReplaceType(picresult, Value.ReplaceMetadata(Value.Type(picresult), documentation))  
