
.text
main:
# -----------------------

# -----------------------
#  done, terminate program.

li $v0, 10      # call code to terminate program
syscall         # system call (terminate)
.end main
