.globl main
.text
main:
# -----------------------

li $t0, 5       # load the value of x into $t0

li $v0, 1       # call code to print an integer
move $a0, $t0   # move the value of x into $a0
syscall         # system call to print integer

li $t1, 9       # load the value of y into $t1

li $v0, 1       # call code to print an integer
move $a0, $t1   # move the value of y into $a0
syscall         # system call to print integer

li $t2, 768       # load the value of z into $t2

li $v0, 1       # call code to print an integer
move $a0, $t2   # move the value of z into $a0
syscall         # system call to print integer

# ----------------------
#  done, terminate program.

li $v0, 10      # call code to terminate program
syscall         # system call (terminate)
.end main
