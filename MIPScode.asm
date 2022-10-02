.globl main
.text
main:
# -----------------------
li $t0, 5
li $t1, 9
# -----------------
#  done, terminate program.

li $v0, 10   # call code for terminate
syscall      # system call (terminate)
.end main
