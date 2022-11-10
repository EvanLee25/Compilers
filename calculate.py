from colorama import Fore,Back,Style
print(Style.NORMAL)

with open("calc.input","r") as file:
    equation = file.read()
    print(Fore.GREEN)
    print(f"\nEquation input: {equation}\n")
    print(Style.RESET_ALL)

    try:
        result = eval(equation)

    except ZeroDivisionError:
        print(Fore.RED)
        print("Cannot divide by 0.")
        print(Style.RESET_ALL)
        with open("calc.output","w") as file:
            file.write("ERROR")

    except Exception as e:
        print(Fore.RED)
        print(e)
        print(Style.RESET_ALL)
        with open("calc.output","w") as file:
            file.write("ERROR")

    else:
        print(Fore.GREEN)
        print(f"\nEquation output: {result}\n")
        print(Style.RESET_ALL)
    
        with open("calc.output","w") as file:
            file.write(str(result))