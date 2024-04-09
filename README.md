# Power Query Functions
## Introduction
This repository contains a collection of Power Query functions, the intention is to give the Power Query community the possibility of using tested and proved functions without having to write them from scratch. 

## History
### This M functions library stands on the shoulders of giants:
This repository was inspired by [Injae Park's YouTube video](https://www.youtube.com/watch?v=GXFxiEVAmfI) and [repository](https://github.com/PowerBIPark/PowerBI_MQueryTest) on how to version control M Code, his research and code is a corner stone of this project; also, specially useful were the references he included: 

- Imke Feldman's [post on expression evaluate](https://www.thebiccountant.com/2018/05/17/automatically-create-function-record-for-expression-evaluate-in-power-bi-and-power-query/) came particularly handy when dealing with documentation. 
- Kim Burgess' [repository, m-tools](https://github.com/acaprojects/m-tools/blob/master/M.pq) was very useful when defining the usage of the functions and the readme file.

## Usage
### Library installation
This library is imported into Power Query by copying and 
1. Open the file [M.pq](M.pq) and copy the code.
2. Open an advanced editor in Power Query and paste the code, rename the query to "M".
3. Use the functions as records on M. For example, PictureBinary, which arguments are one table and two numbers, can be invoked like: 

`M[General.PictureBinary](table, number, number)`

## Contributing
Contributions are welcome! If you have any new functions or improvements to existing ones, feel free to submit a pull request.

### Contributing guidelines
1. Make sure to add the corresponding credit on the code you use. Plagiarism will not be tolerated.
2. Document your functions, this is a great place to give credits.
3. Comment your code.
4. have fun!

## License
This project is licensed under the [MIT License](LICENSE).
<!--stackedit_data:
eyJoaXN0b3J5IjpbLTE1ODEzOTU3NDAsLTUzMjA2MDQzLC0xNj
c1NDM3Njg4XX0=
-->