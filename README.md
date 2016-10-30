# Expressions

A simple compiler for a simple functional programming language. Everything is an expression, hence the name.
The compiler is written in Swift 3.0. The compiler compiles the Expression code to the intermediate language C++.

ToDo list:
- Function implementation (Done)
- Switch implementation (Done)
- Let implementation (Done)
- Built-in functions (Mostly done for now. Missing some important ones, though.)
- Types (Done)
- Lists (Done)
- Objects
- Generics
- Side conditions (Print, IO and such)
- Type conversions
- Validating (Scope check, type check and so on. Currently performed by the C++ compiler)

## Project structure
The compiler consists of four major parts; scanner, parser, validator and code generation.

The scanner creates tokens from the input source code. The parser determines the code structure and syntactical correctness and creates the program tree. The root node being a 'program', with multiple functions.
The validator will, at some point, validate the scope of variables, types and such. Currently, this is only handled by the C++ compiler.
The code generator traverses the tree created by the parser and produces the C++ intermediate code. This intermediate code is saved on the users desktop in the file intermediate.cpp.

# The language

Overview:

1.  [Functions](#functions)
2.  [Types](#types)
3.  [Objects](#objects)
3.  [Conditionals](#conditionals)
4.  [Switch](#switch)
5.  [Variables](#variables)
6.  [Comments](#comments)
7.  [Standard functions](#standard-functions--built-in-functions)

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

## Types
The language contains a few simple types: Int, Float, Char, String and Boolean. Lists of these are also accepted. A String is considered a list of characters in the language, so built-in functions such as *first* and *last* works on Strings as they would on lists of other types. Characters are declared using quotes, just as strings: ```Char c = "c"```

Currently there is no support of creating types, but there probably will be in the future.

Lists are created using square brackets. For example, a list of integers from 0-5 can be defined like this in a *let* block:
```
let [Int] myIntegers = [1, 2, 3, 4, 4+1] {
}
```
Nested lists are also possible, simply by adding another layer of square brackets. List literals can be used in all function calls that accepts these. For example:
```
take([1, 2, 3, 4], 2) # Returns [1, 2]
take("1234", 2) # Returns "12"
```

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
let MyType t = MyType(4, "string", "c") {
  # myInteger = 4, myString = "string", myCharacter = "c"
}
```


## Conditionals
Expressions supports two types of conditionals; If-statements and switch-statements.
Boolean literals are either *true* or *false*, and they can be combined with the *AND* and *OR* operators.

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

## Comments
Comments are created using a \# in the code. Currently there only exists one-line comments and they can't be stopped by using another \#.

## Standard functions / built-in functions
Some functions to handle lists and strings are already implemented (More are to come, of course!).
```
length(list) # Returns the length of a list
first(list) # Returns the first object in the list
last(list) # Returns the last object in the list
reverse(list) # Reverses a list
get(list, nth) # Fetches the nth object in a list
tail(list) # Returns everything but the first object
init(list) # Returns everything but the last object
take(list, num) # Returns 'num' items from list
```
