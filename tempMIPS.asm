
.text
main:
# -----------------------

l.s $f0, f       # load the value of f into $t0

l.s $f1, g       # load the value of g into $t1

l.s $f2, f       # load the value of f into $t2, h = f

li $v0, 2         # call code to print a float
mov.s $f12, $f2   # move the value of h into $f12
syscall           # system call to print float

# -----------------------
#  done, terminate program.

li $v0, 10      # call code to terminate program
syscall         # system call (terminate)
.end main
