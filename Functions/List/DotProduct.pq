let
    // Define metadata for the function, describing its purpose and usage.
    metaDocumentation = type function (
        list1 as (type list),
        list2 as (type list)
    ) as number meta [
        Documentation.Name = "List.DotProduct",
        Documentation.Author = "Alexis Olson",
        Documentation.LongDescription = 
            // This is the description of the documentation, it only accepts a handful of HTML tags for formatting.
            "
                Returns the dot product of two lists.
                <p></p>
                <li><b>Author: </b>Alexis Olson</li>
                <li><b>LinkedIn: </b>https://www.linkedin.com/in/alexis-olson-81726818/</li>
            ",
        Documentation.Examples = {
            [
                Description = " Compute the dot product of {1, 3, -5} and {4, -2, -1}.", 
                Code = "List.DotProduct({1, 3, -5}, {4, -2, -1})", 
                Result = "3 = (1 * 4) + (3 * -2) + (-5 * -1)"
            ]
      }
    ],
    myFunction =
        (list1 as list, list2 as list) as number =>
        let
            Zip = List.Zip({list1, list2}),
            Result = List.Sum(List.Transform(Zip, List.Product))
        in
            Result
in
    // Apply the function metadata to myFunction.
    Value.ReplaceType(myFunction, metaDocumentation)
