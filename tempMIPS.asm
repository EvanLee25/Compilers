
.text
main:
# -----------------------

	la $a0, 20      # store value in $a0
	la $t0, Gx      # load variable address into $t0
	sw $a0, 0($t0)  # move value from $a0 into .word variable

	jal whileLoop0       # goto loop: whileLoop0

	next:       # return from loop here

	# -----------------------
	#  done, terminate program.

	li $v0, 10      # call code to terminate program
	syscall         # system call (terminate)
	.end main
