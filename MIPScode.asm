.globl main
.text
main:
# -----------------------
li $t0, 5
li $t1, 9

li $v0, 1
move $a0, $t0
syscall

li $v0, 1
move $a0, $t1
syscall
# -----------------
#  done, terminate program.

li $v0, 10   # call code for terminate
syscall      # system call (terminate)
.end main
