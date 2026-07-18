import os
import re

# Regex pattern to match Power Query functions (e.g., Namespace.Function) but not purely numeric patterns
pattern =  r'\b\w+\.\w+\b'

# Array of strings to exclude
exclude_strings = [
                'API.WorldBankCountries',
                'Date.Today',
                'Documentation.AllowedValues',
                'Documentation.Author',
                'Documentation.Category',
                'Documentation.Description',
                'Documentation.Examples',
                'Documentation.FieldCaption',
                'Documentation.FieldDescription',
                'Documentation.LongDescription',
                'Documentation.Name',
                'Documentation.SampleValues',
                'Documentation.Source',
                'Documentation.Version',
                'Formatting.IsCode',
                'Formatting.IsMultiLine',
                'List.DotProduct',
                'List.Flatten',
                'List.Norm',
                'OpenAI.AnalyzeTable',
                'PowerPlatform.Dataflows',
                'Table.ToM',
                'Text.CleanString',
                'Text.Collapse',
                'Text.ContainsAll',
                'Text.ContainsAny',
                'Text.ListFromString',
                'Text.ReplaceMany',
                'Web.Contents', # Passing Web.Contents itself into Expression.Evaluate's environment triggers
                                # the "can't use a Dynamic Data Source" Formula.Firewall error. A wrapper function
                                # (see #"Web.Contents wrapper" below) is mapped in via manual_mappings instead -
                                # see https://community.powerbi.com/t5/Power-Query/Dynamic-data-sources-aren-t-refreshed-in-the-Power-BI-service/td-p/1563630
                'api.openai',
                'api.worldbank',
                'bibb.pro',
                'blog.crossjoin',
                'bsky.app',
                'co.uk',
                'community.fabric',
                'community.powerbi',
                'datahelpdesk.worldbank',
                'datavolume.xyz',
                'github.com',
                'gorilla.bi',
                'jamesdbartlett3.bsky',
                'linkedin.com',
                'microsoft.com',
                'odata.nextLink',
                'techhub.social',
                'www.linkedin',
                'www.youtube',
                'youtu.be'
            ]
manual_strings = [
    'Number.Abs'
 ]

# Identifiers that can't just be mapped as `Name = Name` in the Expression.Evaluate
# environment record and need a custom expression instead (see #"Web.Contents wrapper"
# in the M_Code template below).
manual_mappings = {
    'Web.Contents': '#"Web.Contents wrapper"',
}

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

    // Wrapping Web.Contents in a same-signature function lets it be passed into
    // Expression.Evaluate's environment without tripping the "can't use a Dynamic
    // Data Source" Formula.Firewall error that occurs when Web.Contents itself is
    // passed around as a first-class value.
    #"Web.Contents wrapper" = (url as text, optional options as nullable record) as any =>
        Web.Contents(url, options),

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
#TextToReplace
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
entries = [f"{func} = {func}" for func in unique_functions]
entries += [f"{name} = {expression}" for name, expression in manual_mappings.items()]

result = ",\n".join(f"                        {entry}" for entry in entries)

M_Code = M_Code.replace("#TextToReplace", result)

print(M_Code)
with open('M.pq', 'w') as file:
    file.write(M_Code)