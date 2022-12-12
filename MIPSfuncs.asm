

# -----------------------
# function declarations

addValue:

	add $t0, $a1, $a2         # add the two values into $t0
	sw $t0, addValueresult      # store the sum into target variable

	lw $t0, addValueresult   # load the value of the first variable into $t0
	sw $t0, addValueReturn   # store the value of the first variable into the second

	jr $ra       # return to main

whileLoop0:

	lw $t0, Gx              # load the variable into $t0
	li $t1, 0               # load the number into $t1
	blt $t0, $t1, endloop   # break loop if true 

	lw $a1, Gx         # load x into $a1 as a parameter

	li $a2, -5         # load -5 into $a2 as a parameter

	jal addValue       # goto function: addValue

	lw $t0, addValueReturn     # load the value of the first variable into $t0
	sw $t0, Gresult   # store the value of the first variable into the second

	lw $s0, Gx

	li $s1, 1

	sub $t0, $s0, $s1   # subtract the two values into $t0
	sw $t0, Gx          # store the result into target variable

	lw $t0, Gx       # load the value of x into $t0

	li $v0, 1       # call code to print an integer
	move $a0, $t0   # move the value of x into $a0
	syscall         # system call to print integer

	addi $a0, $0 0xA  # new line
	addi $v0, $0 0xB  # new line
	syscall           # syscall to print new line

	j whileLoop0       # loop back

endloop:

	jal next       # return to main

