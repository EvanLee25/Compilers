
with open("calc.input","r") as file:
    equation = file.read()
    equation = equation[::-1]
    print(f"\nEquation input: {equation}\n")
    result = eval(equation)
    print(f"\nEquation output: {result}\n")
    
with open("calc.output","w") as file:
    file.write(str(result))