let
    // Step 1: Define metadata for each parameter describing its purpose and usage
    metaDocumentation = type function (
        gitHubUser as (type text meta [
            Documentation.FieldCaption = "GitHub Username",
            Documentation.FieldDescription = "The GitHub username or organization that owns the repository",
            Documentation.SampleValues = {"Templarian", "microsoft", "facebook"},
            Formatting.IsMultiLine = false,
            Formatting.IsCode = false
        ]),
        gitHubRepo as (type text meta [
            Documentation.FieldCaption = "GitHub Repository Name",
            Documentation.FieldDescription = "The name of the GitHub repository to fetch files from",
            Documentation.SampleValues = {"MaterialDesign", "vscode", "react"},
            Formatting.IsMultiLine = false,
            Formatting.IsCode = false
        ]),
        optional personalAccessToken as (type nullable text meta [
            Documentation.FieldCaption = "Personal Access Token",
            Documentation.FieldDescription = "GitHub Personal Access Token for authentication. Leave null for public repositories with rate limits.",
            Documentation.SampleValues = {"github_pat_11ABC..."},
            Formatting.IsMultiLine = false,
            Formatting.IsCode = false
        ]),
        optional pathFilter as (type nullable text meta [
            Documentation.FieldCaption = "Path Filter",
            Documentation.FieldDescription = "Filter files by path prefix. Use null or empty string to include all files.",
            Documentation.SampleValues = {"svg/", "docs/", "src/components/"},
            Formatting.IsMultiLine = false,
            Formatting.IsCode = false
        ]),
        optional fileExtension as (type nullable text meta [
            Documentation.FieldCaption = "File Extension",
            Documentation.FieldDescription = "Filter files by extension. Include the dot (e.g., '.svg'). Use null for all files.",
            Documentation.SampleValues = {".svg", ".md", ".js", ".py"},
            Formatting.IsMultiLine = false,
            Formatting.IsCode = false
        ])
    ) as table 
    // Step 2: Define global metadata in detail
    meta [

        Documentation.Name = "GitHubRepoFiles",
        Documentation.Author = "Oscar Martinez",
        Documentation.InspiredBy = "GitHub API Documentation",
        Documentation.LongDescription = 
        "    
                <p><b>GitHub Repository Files Fetcher</b></p>

                <li>------------------------------------------------------</li>
                
                <li><b>Creator:</b> Oscar Martinez</li>
                <li><b>LinkedIn:</b> https://www.linkedin.com/in/oscarmartinezv/</li>
                <li><b>Web:</b> https://bibb.pro</li>
                <li><b>Acknowledgements:</b> GitHub API Team</li>
                <li><b>Source:</b> https://docs.github.com/en/rest/git/trees</li>

                <li>------------------------------------------------------</li>

                <p><b>Function Description:</b><br/>
                This function connects to the GitHub API to fetch a complete repository tree, filter files based on path and extension criteria, and retrieve the actual content of matching files. It handles authentication via Personal Access Tokens and automatically decodes base64-encoded file content returned by the GitHub API.

                <p><b>Parameters Description:</b><br/>
                <ul>
                    <li><b>• gitHubUser:</b> The GitHub username or organization name <code>(e.g., 'Templarian')</code></li>
                    <li><b>• gitHubRepo:</b> The repository name <code>(e.g., 'MaterialDesign')</code></li>
                    <li><b>• personalAccessToken:</b> Optional GitHub PAT for authentication <code>(e.g., 'github_pat_11ABC...')</code></li>
                    <li><b>• pathFilter:</b> Optional path prefix to filter files <code>(e.g., 'svg/')</code></li>
                    <li><b>• fileExtension:</b> Optional file extension filter <code>(e.g., '.svg')</code></li>
                </ul>

                <b>Returns:</b><br/>
                A table with columns: Path, Type, Sha, ApiUrl, and Content containing the filtered repository files and their decoded content.

                <p><b>Formula Bar (fx) Output:</b><br/>
                <code>GitHubRepoFiles(""Templarian"", ""MaterialDesign"", null, ""svg/"", "".svg"")</code>
                
            ",
        Documentation.Examples = {
            [
                Description = "Fetch all SVG files from the MaterialDesign repository", 
                Code = "GitHubRepoFiles(""Templarian"", ""MaterialDesign"", null, ""svg/"", "".svg"")", 
                Result = "Table with Path, Type, Sha, ApiUrl, and Content columns"
            ],
            [
                Description = "Fetch all markdown files from a repository with authentication", 
                Code = "GitHubRepoFiles(""microsoft"", ""vscode"", ""your_token_here"", null, "".md"")", 
                Result = "Table with all .md files and their content"
            ],
            [
                Description = "Fetch all files from a specific directory", 
                Code = "GitHubRepoFiles(""facebook"", ""react"", null, ""packages/react/"", null)", 
                Result = "Table with all files from the packages/react/ directory"
            ]
      }
    ],
    
  // Define the main function and parameters
  myFunction = (gitHubUser as text, gitHubRepo as text, optional personalAccessToken as nullable text, optional pathFilter as nullable text, optional fileExtension as nullable text) =>

    let
        // ---- CONFIG ----
        BaseURL = "https://api.github.com/repos/",
        PAT = if personalAccessToken is null then "" else Text.From(personalAccessToken),
        PathPrefix = if pathFilter is null then "" else pathFilter,
        Extension = if fileExtension is null then "" else fileExtension,

        // Compose headers (GitHub requires a User-Agent)
        BaseHeaders = [#"User-Agent" = "PowerQuery", Accept = "application/vnd.github+json"],
        QueryHeaders = if PAT <> "" then BaseHeaders & [Authorization = "Bearer " & PAT] else BaseHeaders,

        // ---- 1) Find default branch ----
        RepoInfo = Json.Document(
            Web.Contents(
                BaseURL,
                [ RelativePath = gitHubUser & "/" & gitHubRepo,
                  Headers     = QueryHeaders ]
            )
        ),
        DefaultBranch = RepoInfo[default_branch],

        // ---- 2) Get full tree recursively ----
        TreeResponse = Json.Document(
            Web.Contents(
                BaseURL,
                [ RelativePath = gitHubUser & "/" & gitHubRepo & "/git/trees/" & DefaultBranch,
                  Query       = [ recursive = "1" ],
                  Headers     = QueryHeaders ]
            )
        ),
        FullTree = TreeResponse[tree],

        // ---- 3) Tabularize & keep path/type/sha ----
        TreeTable0 = Table.FromList(FullTree, Splitter.SplitByNothing(), null, null, ExtraValues.Error),
        TreeTable  = Table.ExpandRecordColumn(TreeTable0, "Column1", {"path","type","sha","url"}, {"Path","Type","Sha","ApiUrl"}),

        // ---- 4) Filter to the files you want ----
        FilteredBlobs = Table.SelectRows(
            TreeTable,
            each [Type] = "blob" 
              and (PathPrefix = "" or Text.StartsWith([Path], PathPrefix))
              and (Extension = "" or Text.EndsWith([Path], Extension))
        ),

        // ---- 5) Function: fetch & decode blob content ----
        GetBlobText = (sha as text) as text =>
            let
                BlobJson  = Json.Document(
                    Web.Contents(
                        BaseURL,
                        [ RelativePath = gitHubUser & "/" & gitHubRepo & "/git/blobs/" & sha,
                          Headers     = QueryHeaders ]
                    )
                ),
                // GitHub returns Base64 with line breaks; handle robustly
                EncText   = BlobJson[content],
                CleanBase64 = Text.Replace(EncText, "#(lf)", ""),
                Decoded   = Binary.FromText(CleanBase64, BinaryEncoding.Base64),
                AsText    = Text.FromBinary(Decoded)
            in
                AsText,

        // ---- 6) Add decoded content ----
        WithContent = Table.AddColumn(FilteredBlobs, "Content", each GetBlobText([Sha]), type text)
    in
        WithContent
  in  

    Value.ReplaceType(myFunction, metaDocumentation)