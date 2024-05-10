let
    // Step 1: Define metadata for each parameter describing its purpose and usage
    metaDocumentation = type function () as list 
    // Step 2: Define global metadata in detail
    meta [

        Documentation.Name = "API.WorldBankCountries",
        Documentation.LongDescription = 
        "    
                <p><b>  API.WorldBankCountries  </b></p>

                <li>------------------------------------------------------</li>
                
                <li><b>  Creator: </b>  Oscar Martinez  </li>
                <li><b>  LinkedIn: </b>  https://www.linkedin.com/in/oscarmartinezv/    </li>
                <li><b>  Web: </b>https://bibb.pro  </li>
                <li><b>  Acknowledgements: </b> Name  </li>
                <li><b>  Source: </b> https://datahelpdesk.worldbank.org/knowledgebase/articles/898590-country-api-queries  </li>

                <li>------------------------------------------------------</li>

                <p><b>  Function Description:  </b></br>
                This function returns a list of countries from the World Bank API.
                
                <b>  Returns:  </b></br>
                A table with a list of countries according to the World Bank with the following columns: ISO 3 code, ISO 2 code, Country name, Region, Admin region, Income level, Lending type, Capital city, Longitude, Latitude.
                
            "
      
    ],
    // Define the main function and parameters
    myFunction = () =>
    let
        // Make the API call
        baseUrl = "https://api.worldbank.org/v2/",
        response = Json.Document(
            Web.Contents(baseUrl, [
                RelativePath = "country",
                Query = [
                    format="json",
                    per_page = "1000"
                ],
                Headers = []
            ])
        ),
        response1 = response{1},
        #"Converted to Table" = Table.FromList(response1, Splitter.SplitByNothing(), null, null, ExtraValues.Error),
        #"Expanded Column1" = Table.ExpandRecordColumn(#"Converted to Table", "Column1", 
    {"id", "iso2Code", "name", "region", "adminregion", "incomeLevel", "lendingType", "capitalCity", "longitude", "latitude"}, 
    {"ISO 3 code", "ISO 2 code", "Country name", "Region", "Admin region", "Income level", "Lending type", "Capital city", "Longitude", "Latitude"})
    in
        #"Expanded Column1"
in
    Value.ReplaceType(myFunction, metaDocumentation)