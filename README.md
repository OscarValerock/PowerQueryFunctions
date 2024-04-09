# PowerQueryFunctions
## Introduction
This repository contains a collection of Power Query functions.

## History - This repository and function library stands on the shoulders of giants:
This repository was inspired by [Injae Park's YouTube video](https://www.youtube.com/watch?v=GXFxiEVAmfI) and [repository](https://github.com/PowerBIPark/PowerBI_MQueryTest) on how to version control Power BI, his research and code is a corner stone of this project; specially useful were the references he included: 

- Imke Feldman's [post on expression evaluate](https://www.thebiccountant.com/2018/05/17/automatically-create-function-record-for-expression-evaluate-in-power-bi-and-power-query/) came particularly handy when dealing with documentation. 
- Kim Burgess' [repository, m-tools,](https://www.thebiccountant.com/2018/05/17/automatically-create-function-record-for-expression-evaluate-in-power-bi-and-power-query/) was very useful when defining the usage of the functions and the readme file.

## Usage
1. Open the file [M.pq](M.pq) and copy the code.
2. Open an advanced editor in Power Query and paste the code, rename the query to "M".
3. Use the functions as records on M. For example, PictureBinary, which arguments are one table and two numbers, can be invoked like: 

`M[General.PictureBinary](table, number, number)`

## Contributing
Contributions are welcome! If you have any new functions or improvements to existing ones, feel free to submit a pull request.

## License
This project is licensed under the [MIT License](LICENSE).
