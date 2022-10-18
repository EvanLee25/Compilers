.globl main
.data
f: .float 1.9
.text
main:
# -----------------------

l.s $f0, f       # load the value of f into $t0

li $v0, 2       # call code to print a float
mov.s $f12, $f0   # move the value of f into $f12
syscall         # system call to print float

# -----------------------
#  done, terminate program.

li $v0, 10      # call code to terminate program
syscall         # system call (terminate)
.end main
