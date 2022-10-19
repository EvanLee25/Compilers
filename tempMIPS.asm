
.text
main:
# -----------------------

li $t2, 12       # load the value of x into $t2

li $t0, 'a'     # load the value of a into $t0

li $t1, 'b'     # load the value of b into $t1

li $v0, 11      # call code to print a single char
move $a0, $t0   # move the value of a into $a0
syscall         # system call to print char

addi $a0, $0 0xA  # new line
addi $v0, $0 0xB  # new line
syscall           # syscall to print new line

li $v0, 11      # call code to print a single char
move $a0, $t1   # move the value of b into $a0
syscall         # system call to print char

li $t1, 'a'       # load the value of a into $t1
move $t0, $t1    # move the value of a into b

addi $a0, $0 0xA  # new line
addi $v0, $0 0xB  # new line
syscall           # syscall to print new line

li $v0, 11      # call code to print a single char
move $a0, $t1   # move the value of b into $a0
syscall         # system call to print char

addi $a0, $0 0xA  # new line
addi $v0, $0 0xB  # new line
syscall           # syscall to print new line

li $v0, 1       # call code to print an integer
move $a0, $t2   # move the value of x into $a0
syscall         # system call to print integer

# -----------------------
#  done, terminate program.

li $v0, 10      # call code to terminate program
syscall         # system call (terminate)
.end main
