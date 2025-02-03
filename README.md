This project is a small brainfuck interpreter for linux it is written in x86_64 assembly for linux

it uses some standard C functions

the interpreter uses 8 bit cells for a tape with 30000 cells 

## compilation 

to compile the project you need:
 - gcc as its used for linking
 - nasm
 - GNU make
just run : 
```
make
```

to run the project use :
```
make run ARGS="[source file]"
```
