let
    // Define metadata for the function, describing its purpose and usage.
    metaDocumentation = type function (
        apiKey as (type text meta [
            Documentation.FieldCaption = "Open API Key",
            Documentation.SampleValues = {"sk-"},
            Formatting.IsMultiLine = false,
            Formatting.IsCode = false
        ]),
        model as (type text meta [
            Documentation.FieldCaption = "GPT Model",
            Documentation.SampleValues = {"gpt-3.5-turbo"},
            Formatting.IsMultiLine = false,
            Formatting.IsCode = false
        ]),
        prompt as (type text meta [
            Documentation.FieldCaption = "MGPT Prompt",
            Documentation.SampleValues = {"Please show me how to create a Date Table"},
            Formatting.IsMultiLine = true,
            Formatting.IsCode = true
        ])
    ) as text meta [
        Documentation.Name = "MCopilot",
        Documentation.LongDescription = "    
            <p><b>MCopilot</b></p>
            <li><b>Creator: </b>Oscar Martinez.</li>
            <li><b>LinkedIn:</b> https://www.linkedin.com/in/oscarmartinezv/.</li>
            <li><b>Web: </b>bibb.pro</li>

            <p>This function, interacts with the OpenAI API to provide responses based on given prompts. It serves as a tool for generating meaningful explanations and full code related to Power Query.</p>
            <p>The function takes three parameters:</p>
            <ul>
                <li><b>apiKey:</b> This is the Open API Key required for authentication.</li>
                <li><b>model:</b> This is the GPT chosen model.</li>
                <li><b>prompt:</b> This is the prompt provided to the function, requesting information or code related to Power Query.</li>
            </ul>
            <p>The function,  constructs a request to the OpenAI API endpoint <code>https://api.openai.com/v1/chat/completions</code>.</p>
            <p>The request body includes a system message indicating the role of the responder, as well as the user's prompt. The API key is included in the request headers for authentication.</p>
            <p>Upon receiving the response from the API, the function extracts the content of the response message and returns it as the output.</p>
        "

    ],

    // Define the main function to interact with the OpenAI API.
    MGPT = (apiKey as text, model as text, prompt as text) as text => let
        // API endpoint and request body.
        url = "https://api.openai.com/v1/chat/completions",
        body = "{
            ""model"": """ & model & """,
            ""messages"": [
                {
                    ""role"": ""system"",
                    ""content"": ""You are a Power Query expert, your role is to respond with meaningful explanations and full code""
                },
                {
                    ""role"": ""user"",
                    ""content"": """ & prompt & """
                }
            ]
        }",
        
        // API key and headers configuration. Remember to replace {Your API Key} with your actual API key.

        Headers = [
            #"Content-Type" = "application/json",
            #"Authorization" = "Bearer " & apiKey
        ],
        
        // Execute the web request and parse the JSON response.
        Source = Json.Document(Web.ContentsTest(url, [
            Headers = Headers,
            Content = Text.ToBinary(body)
        ])),
        Response = Source[choices]{0}[message][content]
    in
        Response
in
    // Apply the function metadata to the MGPT function.
    Value.ReplaceType(MGPT, metaDocumentation)
