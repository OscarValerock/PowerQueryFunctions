
# Power Query Functions
## Introduction
This repository contains a collection of Power Query functions intended for ease of use. 

Libraries play a crucial role in programming, offering reusable functions that save time. Power Query, though powerful for data manipulation, lacks this library support, leading to inefficiencies and duplicated efforts among developers.

This repository attempts to fill that void by providing a collection of Power Query functions and scripts. Despite Power Query's limitations, such as its unique M code environment, this project encourages community collaboration to enhance its capabilities, making data transformation more efficient.

This repository represents an approach to bridge this gap by offering a collection of reusable Power Query functions and scripts. Although not perfect due to Power Query's inherent limitations, such as its M code environment and data privacy settings, which may restrict some functionalities, this initiative aims to foster a community-driven development of Power Query libraries. By sharing knowledge and code, developers can overcome some of these limitations, streamlining their workflows and pushing the boundaries of what's possible in Power Query.


### This M functions library stands on the shoulders of giants:
This repository was inspired by [Injae Park's YouTube video](https://www.youtube.com/watch?v=GXFxiEVAmfI) and [repository](https://github.com/PowerBIPark/PowerBI_MQueryTest) on how to version control M Code, his research and code is a cornerstone of this project; extremely useful were the references he included: 

- Imke Feldman's [post on expression evaluate](https://www.thebiccountant.com/2018/05/17/automatically-create-function-record-for-expression-evaluate-in-power-bi-and-power-query/) came particularly handy when dealing with documentation. 
- Kim Burgess' [repository, m-tools](https://github.com/acaprojects/m-tools/blob/master/M.pq) was instrumental when defining the usage of the functions and the readme file.

## Usage
### Library installation and usage

This library is "imported" into Power Query by following these steps:

1. Open the file [M.pq](M.pq) and copy the code.
2. Open an advanced editor in Power Query and paste the code; rename the query to "M".
3. Use the functions as records on M. For example, PictureBinary, which is located in the General Folder, has as arguments one table and two numbers, can be invoked like: 

`M[General.PictureBinary](table, number, number)`

## Contributing
Contributions are welcome! Feel free to submit a pull request if you have any new functions or improvements to existing ones.

Please contribute in the folder category that best suits. If the folder does not exist, create it. 

The functions you create will only work if all the Power Query native functions used are declared in the [M.pq](M.pq) file. You can run the [M_Creator.py](M_Creator.py) Python script, which will locate all the functions via regex and rewrite an M.pq file. 

### Contributing guidelines
1. Make sure to add the corresponding credits to your code. Plagiarism will not be tolerated.
2. **Document your functions,** for this you can use the file  [M_FxDocTemplate.pq](https://github.com/OscarValerock/PowerQueryFunctions/blob/main/M_FxDocTemplate.pq "M_FxDocTemplate.pq")
3. Comment your code.
4. Have fun! 🎉

## License
This project is licensed under the [MIT License](LICENSE).
<!--stackedit_data:
eyJoaXN0b3J5IjpbMTA5NjIyODU5NywyMTA0NzczNywxMzE1OD
E4NTQ2LDExODI5ODI5ODYsLTUzMjA2MDQzLC0xNjc1NDM3Njg4
XX0=
-->