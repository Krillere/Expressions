# Expressions

A simple compiler for a simple functional programming language. Everything is an expression, hence the name.
The compiler is written in Swift 3.0.

# The language

## Functions
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
Something here soon.

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

## Variables
In order to define variables in a scope, the *let* keyword is used. The general syntax is as follows:
```
let Type1 name1 = expression1, Type2 name2 = expression2 ... TypeN nameN = expressionN {
}
```
The variables are only accessible inside the scope.

## Comments
Comments are created using a \# in the code. Currently there only exists one-line comments and they can't be stopped by using another \#.
