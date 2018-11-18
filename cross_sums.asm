#
#
# Main driver for cross sums program
#
# Due:	 	11/20/18
#
# Author: 	G. Mule
#
# Section: 	03
#
# Input: 	This program accepts user input describing the size and inital
# 		set up of the board
#
# Output:	Upon running, the solver will display a title banner, the initial 
#		board, and then the solved board. Boards will depict hints as
#		well as empty boxes, which will be filled in after solving the
#		puzzle. 
#
# Errors:	The program will print error messages if: 
#			1. given a board size not within [2,12]; 
#			2. given an illegal 
#			3. given an impossible puzzle
#
# Impossible:	Impossible is defined as trying all values for all boxes
#		without arriving at a valid solution; a valid solution has
#		no repeated values in any rows or columns, and adds to exactly
#		the value given in the hint boxes at the ends of the row or
#		column.
#		Hints are given in a slash notation, with the number below the 
#		slash defining the sum for the column, and above the slash 
#		defining the sum for the row; # is used to denote a block,
#		meaning the box is neither a hint nor a cell to fill in
#
#

	.data	
	.align 2

#
# Miscellaneous variables
#
size:
	.word 12		# size of the board, changed by user later
board:
	.space 144		# board of maximum legal size
hAcross:
	.space 144		# across hints, match board
hDown:
	.space 144		# down hints, match board

#
# Error Messages
#
INVALID_SIZE:
	.asciiz	"Invalid board size, Cross Sums terminating\n"

ILLEGAL_INPUT:
	.asciiz	"Illegal input value, Cross Sums terminating\n"

IMPOSSIBLE:
	.asciiz	"Impossible Puzzle\n"

#
# Strings to be printed
#
banner_border:
	.asciiz	"******************\n"

banner_text:
	.asciiz	"**  CROSS SUMS  **\n"

blank:
	.asciiz	"\n"

init:
	.asciiz	"Initial Puzzle\n"

final:
	.asciiz "Final Puzzle\n"

cell_h_border:
	.asciiz	"+---"

blank_cell:
	.asciiz "|   |"

block_cell_1:
	.asciiz	"|\##|"

block_cell_2:
	.asciiz	"|#\#|"

block_cell_3:
	.asciiz	"|##\|"

pound:
	.asciiz	"#"

plus:
	.asciiz	"+"

across_open:
	.asciiz	"|\"

down_close:
	.asciiz "\|"

vert_bar:
	.asciiz	"|"

#
# Other Constants
#
PRINT_INT =	1
PRINT_STRING = 	4
READ_INT = 	5
READ_STRING =	8

	.text

handle_input:
	addi	$sp, $sp, -28			# allocate stack, store s-reg
	sw	$s6, 0($sp)
	sw	$s5, 4($sp)
	sw	$s4, 8($sp)
	sw	$s3, 12($sp)
	sw	$s2, 16($sp)
	sw	$s1, 20($sp)
	sw	$s0, 24($sp)
	li	$v0, READ_INT			# read the size of board
	syscall
	move	$s0, $v0
	slti	$t0, $s0, 2			# check if size is in [2,12]
	bne	$t0, $zero, size_err	
	li	$t1, 12
	slt	$t0, $t1, $s0
	bne	$t0, $zero, size_err
	la	$t0, size			# size valid, store
	sw	$s0, 0($t0)
	mul	$s0, $s0, $s0			# s0 = # cells
	la	$s1, hAcross			# s1 = pointer to across hints
	la	$s2, hDown			# s2 = pointer to down hints
	move	$s3, $zero			# s3 = index for storing hints
read_hint:
	li	$v0, READ_INT
	syscall
	move	$t0, $v0			# t0 = input given
	li	$t1, 100
	div	$t0, $t1
	mflo	$s5				# s5 = across clue
	mfhi	$s6				# s6 = down clue
	add	$t1, $s1, $s3
	sw	$s5, 0($t1)			# store values in hint tables
	add	$t2, $s2, $s3
	sw	$s6, 0($t2)
	addi	$s0, $s0, -1
	bne	$s0, $zero, read_hint		# loop more?
	lw	$s6, 0($sp)			# pop s-reg
	lw	$s5, 4($sp)
	lw	$s4, 8($sp)
	lw	$s3, 12($sp)
	lw	$s2, 16($sp)
	lw	$s1, 20($sp)
	lw	$s0, 24($sp)
	addi	$sp, $sp, 28			# de-allocate stack
	j	print_board

size_err:
	li	$v0, PRINT_STRING
	la	$a0, INVALID_SIZE
	syscall
	lw	$s6, 0($sp)			# pop s-reg
	lw	$s5, 4($sp)
	lw	$s4, 8($sp)
	lw	$s3, 12($sp)
	lw	$s2, 16($sp)
	lw	$s1, 20($sp)
	lw	$s0, 24($sp)
	addi	$sp, $sp, 28			# de-allocate stack
	j	terminate

	.globl main
main:
	addi	$sp, $sp, -4			# allocate stack
	sw	$ra, 0($sp)			# store registers
	li	$v0, PRINT_STRING
	la	$a0, blank
	syscall					# print banner
	la	$a0, banner_border
	syscall
	la	$a0, banner_text
	syscall
	la	$a0, banner_border
	syscall
	la	$a0, blank
	syscall
	jal	handle_input			# parse input
terminate:
	lw	$ra, 0($sp)			# pop registers
	addi	$sp, $sp, 4			# de-allocate stack
	jr	$ra				# terminate program

print_board:
	addi	$sp, $sp, -8
	sw	$s0, 0($sp)
	sw	$s1, 4($sp)
	la	$t0, size
	lw	$s0, 0($t0)			# s0 = row/col size
print_loop:
	move	$s1, $zero			# s1 = counter
	la	$s2, hAcross			# s2 = across hints
	la	$s3, hDown			# s3 = down hints
	move	$s4, $zero			# s4 = layer in cell
	beq	$s4, $zero, top_cell
row_loop:
	lw	$t0, 0($s2)
	beq	$t0, $zero, print_blank
	li	$t1, 99
	beq	$t0, $t1, print_block
top_cell:
	la	$a0, cell_h_border
	li	$v0, PRINT_STRING
	syscall
	
print_blank:
	la	$a0, blank_cell
	li	$v0, PRINT_STRING
	syscall
print_block:
	lw	$s1, 4($sp)
	lw	$s1, 0($sp)
	addi	$sp, $sp, 8
	j	terminate
