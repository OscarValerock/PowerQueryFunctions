import os
import re

# Regex pattern to match Power Query functions (e.g., Namespace.Function) but not purely numeric patterns
pattern =  r'\b\w+\.\w+\b'

# Array of strings to exclude and exclude
exclude_strings = [
                   'api.openai' ,
                   'bibb.pro',
                   'community.powerbi',
                   'community.fabric',
                   'Documentation.Author',
                   'Documentation.Examples',
                   'Documentation.FieldCaption',
                   'Documentation.LongDescription',
                   'Documentation.Name',
                   'Documentation.SampleValues',
                   'Formatting.IsCode',
                   'Formatting.IsMultiLine',
                   'gorilla.bi',
                   'microsoft.com',
                   'odata.nextLink',
                   'Web.Contents', #Unfortunately adding this function to the M code will create a dynamic error :(
                   'www.linkedin',
                   'youtu.be',
                ]
manual_strings = [
    'Number.Abs'
 ]

M_Code = """

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
            #"To text" = 
                Expression.Evaluate(
                    Text.FromBinary(
                        Binary.FromText(#"Get functions fx")
                    ),
                    [ 
#TextToReplace
                        //,Web.Contents = Web.Contents //Unfortunately adding this function to the M code will create a dynamic error :(
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
"""
def process_file(file_path):
    """
    Process a single file and extract Power Query functions.

    Args:
        file_path (str): The path to the file to be processed.

    Returns:
        list: A list of extracted Power Query functions.
    """
    with open(file_path, 'r') as file:
        file_content = file.read()
        matches = re.findall(pattern, file_content)
        matches = [match for match in matches if not re.match(r'^\d+\.\d+$', match) and match not in exclude_strings]
        return matches

def process_directory(directory):
    """
    Traverse the directory structure and process each file to extract Power Query functions.

    Args:
        directory (str): The directory to be traversed.

    Returns:
        list: A list of extracted Power Query functions.
    """
    matches = []
    for root, dirs, files in os.walk(directory):
        for file in files:
            file_path = os.path.join(root, file)
            matches.extend(process_file(file_path))
    return matches

# Process the "Functions" folder
matches = process_directory('Functions')

# Deduplicate the list while preserving order
unique_functions = list(dict.fromkeys(matches))

# Append manual strings to the final list
unique_functions.extend(manual_strings)

# Sort the list of unique functions
unique_functions.sort()

unique_functions = list(set(unique_functions))
unique_functions.sort()

print("Extracted Power Query functions (excluding numbers and specified strings):")
result = ""
for i, func in enumerate(unique_functions):
    if i == len(unique_functions) - 1:
        result += f"                        {func} = {func}"
    else:
        result += f"                        {func} = {func},\n"


M_Code = M_Code.replace("#TextToReplace", result)

print(M_Code)
with open('M.pq', 'w') as file:
    file.write(M_Code)

