
with open("calc.input","r") as file:
    equation = file.read()
    result = eval(equation)
    print(equation)
    
with open("calc.output","w") as file:
    file.write(str(result))