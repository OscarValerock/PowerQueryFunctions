let
    // Step 1: Define metadata for each parameter describing its purpose and usage
    metaDocumentation = type function (
        mytext as (type text meta [
            Documentation.FieldCaption = "Input Text",
            Documentation.FieldDescription = "The primary text input on which cleaning and manipulation operations will be performed.",
            Documentation.SampleValues = {"Example text"},
            Formatting.IsMultiLine = false,
            Formatting.IsCode = false
        ]),
        optional characters as (type text meta [
            Documentation.FieldCaption = "Characters to Replace",
            Documentation.FieldDescription = "A semicolon-separated list of character pairs to be replaced in the input text. Each pair should be delimited by a comma.",
            Documentation.SampleValues = {"a,b;c,d"},
            Formatting.IsMultiLine = false,
            Formatting.IsCode = true
        ]),
        optional words as (type text meta [
            Documentation.FieldCaption = "Words to Replace",
            Documentation.FieldDescription = "A semicolon-separated list of word pairs to be replaced in the input text. Each pair should be delimited by a comma.",
            Documentation.SampleValues = {"hello,hi;world,earth"},
            Formatting.IsMultiLine = false,
            Formatting.IsCode = true
        ]),
        optional charactersRemove as (type text meta [
            Documentation.FieldCaption = "Characters to Remove",
            Documentation.FieldDescription = "A string of characters that will be removed from the input text.",
            Documentation.SampleValues = {"abc"},
            Formatting.IsMultiLine = false,
            Formatting.IsCode = false
        ]),
        optional wordsRemove as (type text meta [
            Documentation.FieldCaption = "Words to Remove",
            Documentation.FieldDescription = "A string representing a word or words that will be removed from the input text.",
            Documentation.SampleValues = {"Hello;World"},
            Formatting.IsMultiLine = false,
            Formatting.IsCode = false
        ]),
        optional fullCellContents as (type text meta [
            Documentation.FieldCaption = "Full Cell Content Replace",
            Documentation.FieldDescription = "A semicolon-separated list of old and new content pairs for full cell replacement. Each pair should be delimited by a comma.",
            Documentation.SampleValues = {"old text,new text"},
            Formatting.IsMultiLine = false,
            Formatting.IsCode = true
        ])
    ) as list 
    // Step 2: Define global metadata in detail
    meta [

        Documentation.Name = "Text.CleanString",
        Documentation.LongDescription = 
        "    
                <p><b>Text.CleanString</b></p>

                <li>------------------------------------------------------</li>

                <li><b>  Creator: </b>  Oscar Martinez  </li>
                <li><b>  Web: </b>  https://bibb.pro  </li>
                <li><b>  LinkedIn: </b>  https://www.linkedin.com/in/oscarmartinezv/  </li>

                <li>------------------------------------------------------</li>

                <p><b>  Function Description:  </b></br>
                <p>This function provides various text manipulation capabilities such as replacing specific characters or words, removing certain characters, and replacing entire cell contents based on user-defined parameters.</p>
                
            ",
        Documentation.Examples = {
            [
                Description = "Replace specific characters in a text string.", 
                Code = "Text.CleanString(""Hello, World!"", ""o,r"")",
                Result =  "Hellr, Wrrld!"
            ]
        }
    ],
    
  // Define the main function and parameters
  myFunction = (mytext as text, optional characters as text, optional words as text, optional charactersRemove as text, optional wordsRemove as text, optional fullCellContents as text) =>

let
    // Use the input text as the initial source
    Source = mytext,

    // Function to convert a delimited string into a list of lists
    ListFromString = (string as text, delimiter1 as text, delimiter2 as text) as any =>
        let
            SplitPairs = Text.Split(string, delimiter1),
            ConvertToLists = List.Transform(SplitPairs, each Text.Split(_, delimiter2))
        in
            ConvertToLists,

    // Replace characters if 'characters' parameter is provided
    ReplaceMatchingChar = if characters <> null then 
        Text.Combine(
            List.ReplaceMatchingItems(
                Text.ToList(Source), 
                ListFromString(characters, ";", ",")
            )
        )
        else Source,

    // Replace words if 'words' parameter is provided
    ReplaceMatchingWord = if words <> null then
        Text.Combine(
            List.ReplaceMatchingItems(
                Text.Split(ReplaceMatchingChar, " "), 
                ListFromString(words, ";", ",")
            ), " "
        )
        else ReplaceMatchingChar,

    // Remove characters if 'charactersRemove' parameter is provided
    RemoveCharacters = if charactersRemove <> null then
        Text.Remove(ReplaceMatchingWord, Text.ToList(charactersRemove))
        else ReplaceMatchingWord,

    // Remove full words if 'fullWordsRemove' parameter is provided
    RemoveWords = if wordsRemove <> null then 
        let
            WordsToRemove = Text.Split(wordsRemove, ";"),
            RemoveWords = List.RemoveItems(Text.Split(RemoveCharacters, " "), WordsToRemove)
        in
            Text.Combine(RemoveWords, " ")
        else RemoveCharacters,

    // Replace full cell contents if 'fullCellContents' parameter is provided
    FinalText = if fullCellContents <> null then
        let
            ReplacementList = ListFromString(fullCellContents, ";", ","),
            ReplacedFullContent = List.ReplaceMatchingItems({RemoveWords}, ReplacementList)
        in
            ReplacedFullContent{0}
        else RemoveWords

in
    FinalText
    // _______________________________ \\
  in  

    Value.ReplaceType(myFunction, metaDocumentation)
