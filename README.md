# Expressions

A simple compiler for a simple functional programming language. Everything is an expression, hence the name for the language; Expressions. The language is a statically typed functional language with inspiration from C, Haskell and Scheme.

The compiler is written in Swift 3.0. The compiler compiles the Expression code to the intermediate language C++.

The EBNF for the language can be found in the project: [EBNF](https://github.com/Krillere/Expressions/blob/master/Expressions/Expressions/EBNF.txt).

Working (Somewhat):
- ~~Function implementation~~
- ~~Let implementation~~
- ~~Built-in functions~~ (More to come.)
- ~~Simple types~~
- ~~Switch implementation~~
- ~~Lists~~
- ~~Objects~~
- ~~Side conditions~~
- ~~Functions as first-class-citizens~~
- ~~Generics~~ (Simple implementation now)
- ~~Higher order functions~~ (map, filter implemented)
- ~~Variadic functions~~
- ~~Lambdas~~
- ~~Module and import system~~

ToDo list:
- Add 'guards' 
  - Early return system, like how Swift does it
- Mutable values
  - Will require a keyword, as well as a new layer of nesting that reassigns the mutable variable
- Module system
  - Namespaces or modules that allow only importing some functions and types to decrease size and compile time
- Fix generics
  - Should be that every type that is not known by the compiler is presumed to be a generic type, and generated as such
- User defined functions with side-effects
  - For printing and stuff
  
- Scope check (Function calls already validated)
- Validating (Scope check, type check and so on. Currently performed by the C++ compiler)

## Project Structure
The compiler consists of four major parts; scanner, parser, validator and code generation, with some tree handling in between phases (Pre-code generation, for example).

The scanner creates tokens from the input source code. The parser determines the code structure and syntactical correctness and creates the program tree. The root node being a 'program', with multiple functions and/or types.
The validator will, at some point, validate the scope of variables, and the typechecker will determine if types are correct. Currently, this is mostly handled by the C++ compiler.
The code generator traverses the tree created by the parser and produces the C++ intermediate code. This intermediate code is saved on the users desktop in the file intermediate.cpp.

Some standard functions are implemented in Expressions, but some are implemented in C++. The ```std.expr``` file contains the standard functions implemented in Expressions, and these can also be found on the Wiki.

The scanner and parser is pretty good. It's easy to understand and the code works. There needs to be better error handling, but that can be added. The code generator needs some cleaning. This will be performed in increments, and is already underway.

# The Language

Overview:

1.  [Functions](#functions)
3.  [Conditionals](#conditionals)
5.  [Variables](#variables)
2.  [Types](#types)
3.  [Generics](#generics)
3.  [Objects](#objects)
3.  [Functions as objects](#functions-as-objects)
4.  [Lambdas](#lambdas)
6.  [Comments](#comments)
6.  [Operators](#operators)
7.  [Standard functions](#standard-functions--built-in-functions)
7.  [Higher order functions](#higher-order-functions)
8.  [Side conditions](#side-conditions)
9.  [Imports](#imports)

## Functions
[functions]:asd
Functions are declared by using the following general syntax:
```
define functionName: Type1 name1, Type2 name2 .. TypeN nameN -> ReturnType {
  CODE
}
```

For example, a ```min``` function will look like the following:
```
define min: Int a, Int b -> Int {
  CODE
}
```

A function can be declared without any parameters, for example the required *main* function, which is the entrypoint.
```
define main: -> Int {
  CODE
}
```

Functions can not be overloaded.

## Conditionals
Expressions supports two types of conditionals; If-statements and switch-statements.
Boolean literals are either *true* or *false*, and they can be combined with the *AND* and *OR* operators.
Comparisons are performed using the following operators: *==*, *!=*, *<*, *>*, *<=*, *>=*

### If
The syntax for if-statements is; 'if' CONDITIONAL '{' IfBlock '}' 'else' '{' ElseBlock '}'.
For example:
```
if 1 > 2 { 1 } else { 2 }
```
Which would return 2, as 1 is not larger than 2. 

An example using OR:
```
if (1 > 2) OR true { 1 } else { 2 }
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
In order to define variables in a scope, the ```let``` keyword is used. The general syntax is as follows:
```
let Type1 name1 = expression1, Type2 name2 = expression2 ... TypeN nameN = expressionN {
}
```
The variables are only accessible inside the scope.

## Types
The language contains a few simple types: ```Int```, ```Float```, ```Char```, ```String``` and ```Bool```. Lists of these are also accepted. A String is considered a list of characters in the language, so built-in functions such as ```first``` and ```last``` works on Strings as they would on lists of other types. Characters are declared using single-quotes: ```Char c = 'c'```

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
  else { 1 + length(tail(lst)) }
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

Multiple types of generics can be used in functions or let-expressions. For example:
```
define multGen: Generic_A genA, Generic_B genB -> Int {
 1 + 1
}
```
The name of the type can be anything. The compiler will conclude that a type is generic if it is not known by the compiler by either being a standard type or defined by the developer.

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

In order for a value in a type to not be set, the keyword ```null``` can be used. This is necessary in, for example, a tree structure, as seen below:
```
type Tree {
  Tree left,
  Tree right,
  Int value
}
```
In order to define a leaf node, ```null``` could be used on left and right, meaning that this node does not have anything below.


## Functions as Objects
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

## Lambdas
Lambdas, or anonymous functions, can be used instead of defining a function. The general syntax is: ```lambda (Type1 name1, Type2 name2 ... TypeN nameN) -> Type { expression }```
The ```lambda``` keyword is the inline equivalent of ```define```.

The following example uses ```map```, explained at [Higher order functions](#higher-order-functions), but uses a lambda instead of defining a function to perform the mapping. The example shows how to do a simple mapping using lambdas, and one using functions. Lambdas mostly make sense when a specific function is only used once. If it's used multiple times, it's easier to define it as a function, instead of defining the lambda each time it's needed.
```
# Without lambdas:
define addOne: Int a -> Int {
  a + 1
}
map([1, 2, 3, 4], addOne) # Returns [2, 3, 4, 5]

#Lambda:
map([1, 2, 3, 4], lambda (Int a -> Int) { a + 1})
```

Lambdas can also be used in ```let``` expressions, although it's not very pretty.
```
let (Int, Int -> Int) func = lambda (Int a, Int b -> Int) { a + b } {
  func(1, 2)
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

## Operators
The 'usual' operators are available in Expressions, meaning:
```
+ Addition
- Subtraction
* Multiplication
/ Division
% Modulus
= Assign (Only allowed in 'let')
! Negation
== Equals
!= Not equals
< Smaller than
> Larger than
<= Less than or equal
>= Larger than or equal
```

Besides this there exists a few operators to make things easier. Instead of using ```list(1)``` to create a list containing 1, use ```[1]```. 

The ```append``` function can be replaced by ```++```, for example:
```
# Using append: 
[Int] lst = [1, 2]
append(lst, [3], [4, 5])

# Using ++
[Int] lst = [1, 2]
lst ++ [3] ++ [4, 5]
```

## Standard Functions / Built-in Functions

Functions to handle lists:
```
length(list) # Returns the length of a list
null(lst) # true of list is empty

min(int, int) # Returns the smaller int
max(int, int) # Returns the larger int

first(list) # Returns the first object in the list
last(list) # Returns the last object in the list

tail(list) # Returns everything but the first object
init(list) # Returns everything but the last object
ends(lst) # Returns a list containing the first and last object in 'lst'

get(list, nth) # Fetches the nth object in a list
take(list, num) # Returns 'num' items from list
subset(list, from, to) # Returns a subset of the list, between and including 'from' and 'to'
indexOf(list, obj) # Returns the first encountered index of 'obj' in 'list', or -1 of 'list' does not contain 'obj'

list(obj) # Returns a list containing 'obj'
list(obj, ... objs) # Creates a list with all objects appended
reverse(list) # Reverses a list

append(list, ... lists) # Appends all the objects from 'lists' (Variadic) to 'list'

split(lst, spl) # Splits 'lst' at 'spl'. Returns a nested list. For example: split("this is test", ' ') -> ["this", "is", "test"]

hasPrefix(lst, items) # Returns true of 'items' is the prefix of 'lst'
hasPostfix(lst, items) # Returns true if 'items' is the postfix of 'lst'
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
getEnvironmentVariable(str) # Returns the environment value for 'str'

factorial(num) # Returns the factorial value of 'num'
even(int) # Returns true if int is even
odd(int) # Returns true if int is odd

error(reason) # Throws an exception and stops execution. Should be used when something is wrong and execution can't continue.
```

Higher order functions:
```
map(list, func) # Applies 'func' to each element in 'list'
map2(list, list, func) # Applies 'func' to elements of each list, adding them to one list. 
filter(list, func) # Tests each element in 'list' against 'func', if true, then it is added to the list
```

## Higher Order Functions
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

map2([1, 2, 3, 4], [4, 3, 2, 1], addNumbers) # Returns [5, 5, 5, 5]
```

A simple filter example:
```
define even: Int a -> Bool {
  (a % 2) == 0
}

filter([1, 2, 3, 4, 5, 6], even) # Returns: [2, 4, 6]
```

## Side Conditions
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


## Imports
Imports can be used to import source from other files, making it possible to create shared libraries and less cluttered code.
For example, we might have two files: program.expr (Main function and some helpers) and myLibrary.expr (Some often used functions).
Because we often need myLibrary.expr, we can import it in our different programs by doing the following:
```
import "myLibrary.expr"
```
This will make all functions in this file accessible in the file where you import it.
