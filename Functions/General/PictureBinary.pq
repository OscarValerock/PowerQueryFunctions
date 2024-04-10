let
    // Define metadata for the function, describing its purpose and usage.
    metaDocumentation = type function (
        InputTable as (type table meta [
            Documentation.FieldCaption = "Select table with binary files",
            Formatting.IsMultiLine = false,
            Formatting.IsCode = false
        ]),
        InputBinaryZBPosition as (type number meta [
            Documentation.FieldCaption = "Binary column zero-based position",
            Documentation.SampleValues = {0},
            Formatting.IsMultiLine = false,
            Formatting.IsCode = false
        ]),
        InputKeyZBPosition as (type number meta [
            Documentation.FieldCaption = "Key column zero-based position",
            Documentation.SampleValues = {0},
            Formatting.IsMultiLine = false,
            Formatting.IsCode = false
        ])
    ) as any meta [
        Documentation.Name = "Pictures Binaries to Base64",
        Documentation.LongDescription = 
            //This is the description of the documentation, it only accepts a handful of HTML tags for formatting.
            "    
                <p><b>Pictures Binaries to Base64</b></p>
                <li><b>Creator: </b>Chris Webb and Patrick LeBlanc.</li>
                <li>This YouTube video from Guy in a Cube explain the usage of the function: https://youtu.be/Q82yzcfkqAc?si=aSsNYwwU1usWw94o</li>
                <li>------------------------------------------------------</li>
                <li><b>Editor: </b>Oscar Martinez.</li>
                <li><b>Web: </b>https://bibb.pro</li>
                <li><b>LinkedIn: </b>https://www.linkedin.com/in/oscarmartinezv/</li>

                <p>This function converts binary image files in the InputTable to base64 format. It splits the binary data into smaller chunks and adds the corresponding key value from the InputTable to each chunk. </p>
                <p>The function takes three parameters:</p>
                <ul>
                    <li><b>InputTable: </b>Select table with binary files.</li>
                    <li><b>InputBinaryZBPosition: </b>Binary column zero-based position.</li>
                    <li><b>InputKeyZBPosition: </b>Key column zero-based position.</li>
                </ul>
                <p>The result is a table with two columns: ID (key value) and Pic (base64 encoded image data). The base64 encoded data can now be stitched back with DAX</p>
            "
    ],
    // Define the main function
    myFunction = (InputTable as table, InputBinaryZBPosition as number, InputKeyZBPosition as number ) as table  =>
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
            AddIndexColumn
    in
    // Apply the function metadata to myFunction.
    Value.ReplaceType(myFunction, metaDocumentation)