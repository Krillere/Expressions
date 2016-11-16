# Expressions

A simple compiler for a simple functional programming language. Everything is an expression, hence the name for the language; Expressions. The language is a statically typed functional language using some syntactic elements from C.
The compiler is written in Swift 3.0. The compiler compiles the Expression code to the intermediate language C++.

ToDo list:
- ~~Function implementation~~ (Done)
- ~~Switch implementation~~ (Done)
- ~~Let implementation~~ (Done)
- ~~Built-in functions~~ (Mostly done for now. Missing some important ones.)
- ~~Simple types~~ (Done)
- ~~Lists~~ (Done)
- ~~Objects~~ (Done)
- ~~Side conditions~~ (Print, IO and such)
- ~~Functions as first-class-citizens~~ (Somewhat done)
- ~~Generics~~ (Done)
- ~~Higher order functions~~ (map, filter, simple ones first)
- ~~Variadic functions~~ (Seems to work, sometimes at least)
- Lambdas
- Validating (Scope check, type check and so on. Currently performed by the C++ compiler)

## Project structure
The compiler consists of four major parts; scanner, parser, validator and code generation.

The scanner creates tokens from the input source code. The parser determines the code structure and syntactical correctness and creates the program tree. The root node being a 'program', with multiple functions.
The validator will, at some point, validate the scope of variables, types and such. Currently, this is only handled by the C++ compiler.
The code generator traverses the tree created by the parser and produces the C++ intermediate code. This intermediate code is saved on the users desktop in the file intermediate.cpp.

# The language

Overview:

1.  [Functions](#functions)
3.  [Conditionals](#conditionals)
5.  [Variables](#variables)
2.  [Types](#types)
3.  [Generics](#generics)
3.  [Objects](#objects)
3.  [Functions as objects](#functions-as-a-type)
6.  [Comments](#comments)
7.  [Standard functions](#standard-functions--built-in-functions)
7.  [Higher order functions](#higher-order-functions)
8.  [Side conditions](#side-conditions)
9.  [Variadics](#variadics)

## Functions
[functions]:asd
Functions are declared by using the following general syntax:
```
define functionName: Type1 name1, Type2 name2 .. TypeN nameN -> ReturnType {
}
```

For example, a *min* function will look like the following:
```
define min: Int a, Int b -> Int {
}
```

A function can be declared without any parameters, for example the required *main* function, which is the entrypoint.
```
define main: -> Int {
}
```

Functions can be overloaded, meaning that different versions of the same function can be created. An example is the built in function ```map```, which has two definitions; one for a list and a function, and one for two lists and a function. The compiler should be able to figure out which one you want.

## Conditionals
Expressions supports two types of conditionals; If-statements and switch-statements.
Boolean literals are either *true* or *false*, and they can be combined with the *AND* and *OR* operators.
Comparisons are performed using the following operators: *==*, *!=*, *<*, *>*, *<=*, *>=*

### If
The syntax for if-statements is; if CONDITIONAL { IfBlock } { ElseBlock }.
For example:
```
if 1 > 2 { 1 } { 2 }
```
Which would return 2, as 1 is not larger than 2. 

A slightly more complex example:
```
if (1 > 2) OR true { 1 } { 2 }
```
Which would return 1.

### Switch
The switch is useful when having multiple things that can happen. It's basically syntactic sugar for nested if-statements.
The general structure is as follows: 
```
switch Bool1 { Block1 }
       Bool2 { Block2 }
       Bool3 { Block3 }
       else { ElseBlock }
```
The statement always have to end on 'else'.
For example:
```
switch  1 == 2 { 1 }
        2 == 1 { 2 }
        3 == 1 { 3 }
        else { 4 }
```
Which, of course, returns 4.

## Variables
In order to define variables in a scope, the *let* keyword is used. The general syntax is as follows:
```
let Type1 name1 = expression1, Type2 name2 = expression2 ... TypeN nameN = expressionN {
}
```
The variables are only accessible inside the scope.

## Types
The language contains a few simple types: Int, Float, Char, String and Boolean. Lists of these are also accepted. A String is considered a list of characters in the language, so built-in functions such as *first* and *last* works on Strings as they would on lists of other types. Characters are declared using single-quotes: ```Char c = 'c'```

Lists are created using square brackets. For example, a list of integers from 0-5 can be defined like this in a *let* block:
```
let [Int] myIntegers = [1, 2, 3, 4, 4+1] {
}
```
Consider a String as [Char].

Nested lists are also possible, simply by adding another layer of square brackets. List literals can be used in all function calls that accepts these. For example:
```
take([1, 2, 3, 4], 2) # Returns [1, 2]
take("1234", 2) # Returns "12"
```

## Generics
Instead of defining a specific type for an object in a function, generics can be used. This means that it is not necessary to create a function for every type for a specific purpose. For example, a recursive *length* function using generics can be written as:
```
define length: [Generic] lst -> Int {
  if null(list) { 0 }
                { 1 + length(tail(lst)) }
}
```
Generics can also be used in *let* and as return types. The following example returns a list containing the first and last element in a list:
```
define ends: [Generic] lst -> [Generic] {
  let Generic f = first(lst), Generic l = last(lst) {
    append(list(f), l) # Appens 'l' to a list containing 'f'
  }
}
```
Currently, only one type of generic can be used in a function. Meaning that if a function takes a Generic and returns a Generic, they will have to be the same type at runtime. At some point, it should be possible to define multiple types of generics in a function.

## Objects
Objects can be defined to contain a number of different values using the *type* keyword. For example:
```
type MyType {
  Int myInteger,
  String myString,
  Char myCharacter,
}
```
The last comma is optional. Could just be ```Char myCharacter }```

To create an object of this type, use:
```
let MyType t = MyType(4, "string", 'c') {
  # myInteger = 4, myString = "string", myCharacter = 'c'
}
```

To access functions or variables inside the object, use a dot. For exampe:
```
let Int tmp = myType.myInteger
let Int tmp = myType.myFunction(1, 2) # Assume MyType contains a function called 'myFunction'
```

## Functions as a type
Functions are first-class-citizens in Expression, hence they can be used as variables. The syntax for a function as a variable the following (InpType1, InpType2, ... InpTypeN -> RetType). An example:
```
define add: Int a, Int b -> Int {
  a + b
}
define subtract: Int a, Int b -> Int {
  a - b
}

define test: (Int, Int -> Int) funcToCall -> Int {
  funcToCall(10, 10)
}

# 'test' can now be called with the parameter 'add', which will then return 20 or 'subtract' which will return 0
```
Function types can't be nested. 

Functions can be declared in objects as well, and used in *let* expressions. Example of usage in *let*:
```
let (Int, Int -> Int) addFunc = add {
  1 + addFunc(1, 1) # 3
}
```

## Comments
Comments are created using a \# in the code. Currently there only exists one-line comments and they can't be stopped by using another \#.

A comment: 
```
define main: -> Int {
  # This is ignored by the compiler
  0
}
```

## Standard functions / built-in functions

Functions to handle lists:
```
length(list) # Returns the length of a list
null(lst) # true of list is empty

first(list) # Returns the first object in the list
last(list) # Returns the last object in the list

tail(list) # Returns everything but the first object
init(list) # Returns everything but the last object

get(list, nth) # Fetches the nth object in a list
take(list, num) # Returns 'num' items from list

list(obj) # Returns a list containing 'obj'
reverse(list) # Reverses a list

append(lst, obj) # Appends 'obj' to the end of 'lst'
append(lst, listObj) # Appends all the objects from 'listObj' to the end of 'lst'

```

Functions for type checking:
```
isInt(Generic)
isFloat(Generic)
isString(Generic)
isChar(Generic)
isBool(Generic)
```

Functions for changing types. Shows possible input types. More functions probably comming here at some point.
```
# Different types to ints
convertToInt(String)
convertToInt(Int)
convertToInt(Float)
convertToInt(Char)

# Different types to floats
convertToFloat(Int)
convertToFloat(String)

convertToChar(Int) # Converts int to char (ASCII values)

# Different types to string
convertToString(Int)
convertToString(Float)
convertToString(Char)
```

Other functions:
```
CLArguments() # returns a list of strings containing the command line arguments. first(CLArguments()) is always the path of the program

factorial(num) # Returns the factorial value of 'num'
even(int) # Returns true if int is even
odd(int) # Returns true if int is odd
```

Higher order functions:
```
map(lst, func) # Applies 'func' to each element in 'lst'
map(lst, lst, func) # Applies 'func' to elements of each list, adding them to one list. 
filter(lst, func) # Tests each element in 'lst' against 'func', if true, then it is added to the list
```

## Higher order functions
Map and filter functions exists in Expressions. Map is used to apply a function to one or two lists, and filter is used for filtering a list using a function.

A simple map example is:
```
define addOne: Int a -> Int {
  a + 1
}

map([1, 2, 3, 4], addOne) # Returns: [2, 3, 4, 5]

# Other map function:
define addNumbers: Int a, Int b -> Int {
  a + b
}

map([1, 2, 3, 4], [4, 3, 2, 1], addNumbers) # Returns [5, 5, 5, 5]
```

A simple filter example:
```
define even: Int a -> Bool {
  (a % 2) == 0
}

filter([1, 2, 3, 4, 5, 6], even) # Returns: [2, 4, 6]
```

## Side conditions
Certain functions, even though they have side effects, can be utilized.
```
print(msg) # Prints 'msg' to console. Does not return a value.
printLn(msg) # Prings 'msg' and a newline to console. Does not return a value.
writeFileContents(path, content) # Writes 'content' to the file at 'path'. Does not return a value.

readFileContents(path) # Reads the contents from 'path'. Returns a string.
```

The first three (With no return values) can be used in every codeblock along with normal expressions. For example:
```
define main: -> Int {
  print("This will be printed. ")
  printLn("This will be printed, along with a newline.")
  print("This will be on a new line!")
  
  0   # Returns
}
```
Using any one of these but ```readFileContents``` in an expression context (```1 + print("Error") + 2```) will not compile.

These can be used together, for example:
```
define main: -> Int {
  let String path = "/Folder/file.txt" {
    writeFileContents(path, "This is text.")
  
    print("From file: ")
    print(readFileContents(path)) # Prints 'This is text.'
    
    0   # Returns
  }
}
```

The ```CLArguments``` function could be considered as a function with side effects. This function returns a string list, containing the arguments passed to the program. The first one is always the path of the executable and is always present.

## Variadics
Variadics are also possible to use in Expressions. This allows a function to take an unknown number of arguments, though they still have to be statically typed (Determinable at compile-time). When used, the argument can be accessed as a list inside the function.

An example of a variadic function:
```
define add: Int ... var -> Int {
  if null(var) { 0 }
               { first(var) + add(tail(var)) }
}

add(1, 2, 3, 4, 5) # Result is 15
```

Consider variadics to be syntactic sugar for a lists as parameters.
