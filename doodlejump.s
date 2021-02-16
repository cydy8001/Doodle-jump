#####################################################################
#
# CSCB58 Fall 2020 Assembly Final Project
# University of Toronto, Scarborough
#
# Student: Yihang Cheng
#
# Bitmap Display Configuration:
# - Unit width in pixels: 16
# - Unit height in pixels: 16
# - Display width in pixels: 512
# - Display height in pixels: 512
# - Base Address for Display: 0x10008000 ($gp)
#
# Which milestone is reached in this submission?
# (See the assignment handout for descriptions of the milestones)
# - Milestone 1/2/3/4/5 (choose the one the applies)
#   Milestone 1,2,3,4,5 
# Which approved additional features have been implemented?
# (See the assignment handout for the list of additional features)
# 1. Milestone 1,2,3
# 
#		
# 2. Milestone 4:
#   a. ScoreBoard
#   b. Obstacle type     (Grey platform represents obstacle)
#   c. Dynamic increase in difficulty (speed, obstacles, shapes etc.) as game progresses
#	speed of object will increase as getting more scores
# 3. Milestone 5:
#   b. More platform types: moving blocks and fragile blocks
#   d. fancier graphics:
# 	restart game by pressing "s" after seeing bye when losing. It only has 5 secs to do. If not do
# 	in 5 secs. game will end 
#   f. two doodles: 
#		doodle1:
#			use key "a" and "s" to control <- and ->. 
#		doodle2:
#			use key "j" and "k" to control <- and ->
#   g. lethal creature: The aqua color represents lethal creature. If doodle collides with it, game will end
#
# Link to video demonstration for final submission:
# - (insert YouTube / MyMedia / other URL here).
#    https://play.library.utoronto.ca/b17155b89085e402ab76fb58bf17b254
# Any additional information that the TA needs to know:
# - (write here, if any)
#	Press s to retry in 5 secs after seeing bye. If not retry in 5 secs, game will exit.
#	press "a" and "s" to control another doodle
#  	Green block represents platform. Red one represents doodle. Grey one represents block. Brown one 
#	reprsents fragile block. Aqua color one represents opponent
#####################################################################

#row plus +128
.data 
	
	objRedColor: .word 0xff0000
	platfGreenColor: .word 0x00ff00
	exitBlueColor: .word 0x0000ff
	backgroundPinkColor: .word 0xFFC0CB
	scoreColor: .word 0xFFA500
	displayAddress: .word 0x10008000
	endAddress: .word 0x10009000
	levelNumber: .word 1
	objPosition: .word 0x10008340
	platMaxNum: .word 5
	platStartNum: .word 0
	moveSpeed: .word 128
	heightObjPlatMax: .word 2
.globl main1
.text
setup1:
	addi $sp, $sp, -160
	lw $t0 objRedColor
	sw $t0 0($sp)
	lw $t0 platfGreenColor
	sw $t0 4($sp)
	lw $t0 backgroundPinkColor
	sw $t0 8($sp)
	lw $t0 displayAddress
	sw $t0 12($sp)
	lw $t0 endAddress
	sw $t0 16($sp)
	lw $t0 levelNumber
	sw $t0 20($sp)
	lw $t0 objPosition
	sw $t0 24($sp)
	lw $t0 exitBlueColor
	sw $t0 28($sp)
	lw $t0 moveSpeed
	sw $t0 32($sp)
	lw $t0 platMaxNum
	sw $t0 36($sp)
	lw $t0 platStartNum #counter for platform
	sw $t0 40($sp)
	li $t0 0	
	sw $t0 44($sp)#counter for height
	li $t0 20	
	sw $t0 48($sp)#max height
	li $t0 0
	sw $t0 52($sp) #up counter
	lw $t0 heightObjPlatMax
	sw $t0 56($sp)
	li $t0 0
	sw $t0 60($sp) # lvl counter
	lw $t0 8($sp)
	sw $t0 64($sp) # the color should in current position
	lw $t0 scoreColor
	sw $t0 68($sp)
	li $t0 0
	sw $t0 72($sp) # score counter
	li $t0 0
	sw $t0 76($sp) #first digit
	li $t0 0
	sw $t0 80($sp) #second digit
	lw $t0 12($sp) 
	sw $t0 84($sp) #score start address
	li $t0 0x808080
	sw $t0 88($sp)	# obstacle color
	li $t0 100
	sw $t0 92($sp) #sleeping time
	li $t0 0x00ffff
	sw $t0 96($sp)	#opponent color
	lw $t0 0x10008800
	sw $t0 100($sp) #opponent position
	li $t0 128
	sw $t0 104($sp) #opponent speed
	li $t0 0
	sw $t0 108($sp) #opponent move counter
	lw $t0 8($sp)
	sw $t0 112($sp) # opponent retore color
	lw $t0 0x10008400
	sw $t0 116($sp) #moving blcok position
	li $t0 0
	sw $t0 120($sp) #counter for moving block
	li $t0 4 
	sw $t0 124($sp) #moving block speed
	li $t0 0xD2691E
	sw $t0 128($sp) #fragile platform color
	li $t0 0x10008800
	sw $t0 132($sp) #fragile platform position
	li $t0 0x10008330
	sw $t0 136($sp) #doodle 2 position
	li $t0 0x10008280
	sw $t0 140($sp) # start address for blocks
	li $t0 128
	sw $t0 144($sp) #doodle 2 speed
	li $t0 0
	sw $t0 148($sp) #doodle 2 counter
	li $t0 0
	sw $t0 152($sp) # addreess for either doodle
	lw $t0 8($sp)
	sw $t0 156($sp) # the color should in current address for doodle 2
setup2:
	
	jal backgroundSetUp
	jal generateSetUp1 #Generate platform
	jal displayScore1
	jal generateObstacle1
	jal initSetOppo1
	jal initmovingBlock
	jal initFragileBlock
	jal initSetObj
	jal initSetObj2
	# sleep for 1 sec
	li $v0, 32
	li $a0, 1000
	syscall
	j main1
backgroundSetUp:
	li $t0 0
	lw $t2 12($sp) # displayAddress
	lw $t3 8($sp)  # backgroundPinkColor
	lw $t4 16($sp) # endAddress
	add $t0 $t0 $t2
setBackground:
	bge $t0 $t4 backgroundExit
	sw $t3 0($t0)
	addi $t0 $t0 4
	j setBackground
backgroundExit:
	jr $ra
initSetObj:
	lw $t0 24($sp) #initial obj position
	lw $t1 0($sp) #obj color
	sw $t1 0($t0)
	jr $ra
initSetObj2:
	lw $t0 136($sp) #initial obj position
	lw $t1 0($sp) #obj color
	sw $t1 0($t0)
	jr $ra
displayScore1:
	lw $t0 72($sp)# score counter
	lw $t3 84($sp)
	li $t6 10
	div $t0 $t6
	mflo $t1	#second digit 
	mfhi $t2	#first digit
	beq $t1 0 generateScoreZero
	beq $t1 1 generateScoreOne
	beq $t1 2 generateScoreTwo
	beq $t1 3 generateScoreThree
	beq $t1 4 generateScoreFour
	beq $t1 5 generateScoreFive
	beq $t1 6 generateScoreSix
	beq $t1 7 generateScoreSeven
	beq $t1 8 generateScoreEight
	beq $t1 9 generateScoreNine
displayScore2:
	addi $t3 $t3 16
	sw $t3 84($sp)
	beq $t2 0 generateScoreZero
	beq $t2 1 generateScoreOne
	beq $t2 2 generateScoreTwo
	beq $t2 3 generateScoreThree
	beq $t2 4 generateScoreFour
	beq $t2 5 generateScoreFive
	beq $t2 6 generateScoreSix
	beq $t2 7 generateScoreSeven
	beq $t2 8 generateScoreEight
	beq $t2 9 generateScoreNine
ScoreExit:
	lw $t4 12($sp)
	sw $t4 84($sp)	
	jr $ra
generateObstacle1:
	li $v0, 42
	li $a0, 0
	li $a1, 600
	syscall
	li $t0 4
	mult $a0 $t0
	lw $t1 140($sp) #display address
	lw $t4 88($sp)
	mflo $t3
	add $t3 $t3 $t1
	sw $t4 0($t3)
	sw $t4 4($t3)
	sw $t4 8($t3)
	jr $ra
initSetOppo1:
	lw $s0 140($sp)
	li $v0, 42
	li $a0, 0
	li $a1, 600
	syscall
	li $t0 4
	mult $a0 $t0
	mflo $t0	#opponent position
	add $t0 $t0 $s0
	sw $t0 100($sp)
	lw $t1 96($sp) #opponent color
	sw $t1 0($t0)
	jr $ra
initmovingBlock:
	lw $s0 140($sp)
	li $v0, 42
	li $a0, 0
	li $a1, 600
	syscall
	li $t0 4
	mult $a0 $t0
	mflo $t0	
	add $t0 $t0 $s0
	sw $t0 116($sp)#movingblock position
	lw $t1 4($sp) #movingblock color
	sw $t1 0($t0)
	sw $t1 4($t0)
	sw $t1 8($t0)
	jr $ra
initFragileBlock:
	lw $s0 140($sp)
	li $v0, 42
	li $a0, 0
	li $a1, 600
	syscall
	li $t0 4
	mult $a0 $t0
	mflo $t0	
	add $t0 $t0 $s0
	sw $t0 132($sp)
	lw $t1 128($sp) #movingblock color
	sw $t1 0($t0)
	sw $t1 4($t0)
	sw $t1 8($t0)
	jr $ra
main1:	
	jal Opponentmove1
	jal verifyOppo
	jal geneMovBlo
	jal verifyFraBlo
	jal verifyFraBlod2
	jal checkKeyboard
	jal objmove1
	jal objmove1dd
	jal getBottom
	#--------------
	#For get above:
	lw $t0 136($sp)
	lw $t1 12($sp) #display adrees
	lw $t2 24($sp) #obj position
	blt $t2 $t1 inAbove
	blt $t0 $t1 inAbove
	#-------------
	#sleep
	jal sleep1
	j main1
sleep1:
	lw $t0 72($sp)
	li $t1 15 #minus this 8 milisec
	mult $t0 $t1
	mflo $t0 
	li $v0, 32
	li $a0, 100
	sub $a0 $a0 $t0
	li $t3 20 #lowest milisec
	ble $a0 $t3 lowestSleep
sleep2:
	syscall
	jr $ra
lowestSleep:
	move $a0 $t3
	j sleep2
Opponentmove1:
	lw $t0 108($sp) #opponent move counter
	lw $t1 104($sp) #opponent speed
	lw $t2 100($sp) #opponent position
	lw $t3 96($sp) 	#opponent color
	lw $t4 112($sp) #The color should in current position
	add $t5 $t2 $t1	 #next possible position
	lw $t6 0($t5) #next possible postion color
	li $t7 15
	bge $t0 $t7 OppoReverse
Opponentmove2:
	sw $t4 0($t2)
	move $t2 $t5
	sw $t2 100($sp)
	lw $t4 0($t2)
	sw $t4 112($sp)
	sw $t3 0($t2)
	addi $t0 $t0 1
	sw $t0 108($sp)
	jr $ra
OppoReverse:
	move $t7 $t1
	add $t7 $t7 $t7
	sub $t1 $t1 $t7
	sw $t1 104($sp)
	add $t5 $t1 $t2 #next possible position
	lw $t6 0($t5)#next possible postion color
	li $t0 0
	j Opponentmove2
verifyOppo:
	lw $t0 24($sp)	# obj pos
	lw $t1 32($sp)	# move speed
	lw $t2 96($sp)	# oppo color
	lw $s0 136($sp)# d2 pos
	lw $s1 144($sp)# d2 speed
	add $s3 $s1 $s0
	add $t3 $t1 $t0
	lw $t4 0($t3) #next possible color
	lw $s4 0($s3)
	beq $t4 $t2 getBottomTrue
	beq $s4 $t2 getBottomTrue
	jr $ra
geneMovBlo:
	lw $s0 116($sp) #moving block position1
	lw $s3 8($sp) #background pink color
	lw $t0 4($sp) #moving block color
	lw $t1 120($sp) #counter for moving block
	lw $t2 124($sp) #moving block speed
	li $t6 8 #maximum move
	#t7 for intermediate
	bge $t1 $t6 MovBloRever
geneMovBlo2:
	bgtz $t2 rightMove
	bltz $t2 leftMove
geneMovBloExit:
	jr $ra
rightMove:
	sw $t0 12($s0)
	sw $s3 0($s0)
	add $s0 $s0 $t2
	sw $s0 116($sp)
	addi $t1 $t1 1
	sw $t1 120($sp)
	j geneMovBloExit
leftMove:
	sw $t0 -4($s0)
	sw $s3 8($s0)
	add $s0 $s0 $t2
	sw $s0 116($sp)
	addi $t1 $t1 1
	sw $t1 120($sp)
	j geneMovBloExit
MovBloRever:
	move $t7 $t2
	add $t7 $t7 $t7
	sub $t2 $t2 $t7
	sw $t2 124($sp)
	li $t1 0
	sw $t1 120($sp)
	j geneMovBlo2
verifyFraBlo:
	lw $t0 32($sp) #doodle speed
	bgtz $t0 verifyFraBlo2
	j verifyFraBloExit
verifyFraBlo2:
	lw $t1 24($sp) #doodle position
	add $t2 $t1 $t0 # next possible postion of doodle
	lw $t3 128($sp) #frag blo color
	lw $t4 0($t2) #next possible color
	lw $t5 8($sp) #background pink color
	lw $t6 132($sp) #frag blo position
	beq $t3 $t4 collideFragBlo
	j verifyFraBloExit
collideFragBlo:
	li $t0 -128
	sw $t0 32($sp)
	li $s0 0
	sw $s0 44($sp)
	sw $t5 0($t6)
	sw $t5 4($t6)
	sw $t5 8($t6)
	j verifyFraBloExit
verifyFraBloExit:
	jr $ra
#----------------------------Doodle2 fragile verification
verifyFraBlod2:
	lw $t0 144($sp) #doodle speed
	bgtz $t0 verifyFraBlo2d2
	j verifyFraBloExitd2
verifyFraBlo2d2:
	lw $t1 136($sp) #doodle position
	add $t2 $t1 $t0 # next possible position of doodle
	lw $t3 128($sp) #frag blo color
	lw $t4 0($t2) #next possible color
	lw $t5 8($sp) #background pink color
	lw $t6 132($sp) #frag blo position
	beq $t3 $t4 collideFragBlod2
	j verifyFraBloExitd2
collideFragBlod2:
	li $t0 -128
	sw $t0 144($sp)
	li $s0 0
	sw $s0 148($sp)
	sw $t5 0($t6)
	sw $t5 4($t6)
	sw $t5 8($t6)
	j verifyFraBloExitd2
verifyFraBloExitd2:
	jr $ra	
checkKeyboard:
	lw $t0, 0xffff0000 #keyboard input
	beq $t0, 1, keyboard_input1
	jr $ra
keyboard_input1:
	lw $t0, 0xffff0004 
	lw $t1 0($sp) #obj color
	lw $t2, 24($sp) #object2 position
	#$t3 is for next possible obj pos
	#$t4 is for next possible color
	lw $t5 64($sp) #$t5 is for storing color
	lw $s2, 136($sp)
	#$s3 is for next possible obj pos
	#$s4 is for next possible color
	lw $s5 156($sp) #$s5 is for storing color
	beq $t0, 0x6A, respond_to_j 
	beq $t0, 0x6B, respond_to_k	
	beq $t0, 0x61, respond_to_add 
	beq $t0, 0x73, respond_to_sdd	
	jr $ra
keyboard_Exit:
	jr $ra
generateOneObj:
	sw $t5 0($t2)   # restore color
	sw $t4 64($sp)	 # save the color should in obj
	move $t2 $t3	# 
	sw $t2 24($sp)
	sw $t1 0($t2)
	jr $ra
generateOneObjdd:
	sw $s5 0($s2)   # restore color
	sw $s4 64($sp)	 # save the color should in obj
	move $s2 $s3	# 
	sw $s2 136($sp)
	sw $t1 0($s2)
	jr $ra
respond_to_j:
	addi $t3 $t2 -4
	lw $t4 0($t3)
	move $s1 $ra
	jal generateOneObj
	move $ra $s1
	li $v0, 32
	li $a0, 30
	syscall 
	j keyboard_Exit
respond_to_k:	
	addi $t3 $t2 4
	lw $t4 0($t3)
	move $s1 $ra
	jal generateOneObj
	move $ra $s1
	li $v0, 32
	li $a0, 30
	syscall 
	j keyboard_Exit
respond_to_add:
	addi $s3 $s2 -4
	lw $s4 0($s3)
	move $s1 $ra
	jal generateOneObjdd
	move $ra $s1
	li $v0, 32
	li $a0, 30
	syscall 
	j keyboard_Exit
respond_to_sdd:	
	
	addi $s3 $s2 4
	lw $s4 0($s3)
	move $s1 $ra
	jal generateOneObjdd
	move $ra $s1
	li $v0, 32
	li $a0, 30
	syscall
	j keyboard_Exit

#--------------------
# Doodle 1
objmove1:
	lw $t1 24($sp) #pos
	lw $t2 0($sp) #obj color
	#$t3 is for next possible obj pos
	#$t5 is for receiving input
	lw $t6 4($sp) #plat color
	lw $t7 32($sp) #velocity
	#$t9 is for next obj color
	lw $s0 88($sp) #obstacle color
	#$s1 is for storing return of sub
	move $s2 $ra 	#$s2 is for storing return of objmove
	lw $s4 44($sp) #counter
	lw $s5 48($sp)	#height
	lw $s6 64($sp) # the color should in current pos
	lw $s7 12($sp) #display address
objmove2:	
	bgtz $t7 downcase1
	bltz $t7 upcase1
objmove3:
	move $ra $s2
	jr $ra
downcase1:	
	add $t3 $t1 $t7 #nex pos
	lw $t9 0($t3)
	beq $t9 $t6 downCollide
downcase3:
	lw $t9 0($t3) # next obj color
	move $s1 $ra
	jal generateObj
	move $ra $s1
	addi $t4 $t4 1
	j objmove3

	
downCollide:
	li $t7 -128
	sw $t7 32($sp)
	add $t3 $t1 $t7
	j downcase3
upcase1:
	bge $s4 $s5 upcaselimit
	li $t4 0
upcase2:
	add $t3 $t1 $t7 #nex pos
	lw $t9 0($t3) # next obj color
	beq $t9 $s0 upcaselimit
	move $s1 $ra
	jal generateObj
	move $ra $s1
	blt $t1 $s7 reachAbove
upcaseExit:
	addi $s4 $s4 1
	sw $s4 44($sp)
	j objmove3
upcaselimit:
	li $t7 128
	sw $t7 32($sp)
	li $s4 0
	sw $s4 44($sp)
	j objmove3
	
reachAbove:
	jr $ra
generateObj:
	sw $s6 0($t1)   # restore color
	sw $t9 64($sp)	 # save the color should in obj
	move $t1 $t3	# 
	sw $t1 24($sp)
	sw $t2 0($t1)
	li $v0, 32
	li $a0, 30
	syscall
	jr $ra
#--------------------
# Doodle 2
objmove1dd:
	lw $t0, 0xffff0000 #keyboard input
	lw $t1 136($sp) #pos
	lw $t2 0($sp) #obj color
	#$t3 is for next possible obj pos
	#$t5 is for receiving input
	lw $t6 4($sp) #plat color
	lw $t7 144($sp) #velocity
	#$t9 is for next obj color
	lw $s0 88($sp) #obstacle color
	#$s1 is for storing return of sub
	move $s2 $ra 	#$s2 is for storing return of objmove
	lw $s4 148($sp) #counter
	lw $s5 48($sp)	#height
	lw $s6 156($sp) # the color should in current pos
	lw $s7 12($sp) #display address
objmove2dd:	
	bgtz $t7 downcase1dd
	bltz $t7 upcase1dd
objmove3dd:
	move $ra $s2
	jr $ra
downcase1dd:	
	add $t3 $t1 $t7 #nex pos
	lw $t9 0($t3)
	beq $t9 $t6 downCollidedd
downcase3dd:
	lw $t9 0($t3) # next obj color
	move $s1 $ra
	jal generateObjdd
	move $ra $s1
	addi $t4 $t4 1
	j objmove3dd

	
downCollidedd:
	li $t7 -128
	sw $t7 144($sp)
	add $t3 $t1 $t7
	j downcase3dd
upcase1dd:
	bge $s4 $s5 upcaselimitdd
	li $t4 0
upcase2dd:
	add $t3 $t1 $t7 #nex pos
	lw $t9 0($t3) # next obj color
	beq $t9 $s0 upcaselimitdd
	move $s1 $ra
	jal generateObjdd
	move $ra $s1
	blt $t1 $s7 reachAbovedd
upcaseExitdd:
	addi $s4 $s4 1
	sw $s4 148($sp)
	j objmove3dd
upcaselimitdd:
	li $t7 128
	sw $t7 144($sp)
	li $s4 0
	sw $s4 148($sp)
	j objmove3dd
	
reachAbovedd:
	jr $ra
generateObjdd:
	sw $s6 0($t1)   # restore color
	sw $t9 156($sp)	 # save the color should in obj
	move $t1 $t3	# 
	sw $t1 136($sp)
	sw $t2 0($t1)
	li $v0, 32
	li $a0, 30
	syscall
	jr $ra
#----------------------------------
generateSetUp1:
	li $v0, 42
	li $a0, 0
	li $a1, 600
	lw $t0 36($sp) #platform number
	lw $t1 20($sp) #level number
	lw $t7 140($sp) #display address
	lw $t2 4($sp) #color
	
	sub $t3 $t0 $t1
	addi $t3 $t3 1 #real platform num
	blez $t3 setBasePlatform1
generateSetUp2:
	sw $t3 36($sp) #save number to max
	lw $t4 40($sp)	#instance
	j generatePlatform
setBasePlatform1:
	li $t3 1
	j generateSetUp2
generatePlatform:
	bge $t4 $t3 endGenerate
	move $t5 $ra 
	jal generateOnePlatform
	move $ra $t5
	addi $t4 $t4 1
	j generatePlatform
	
generateOnePlatform:
	syscall
	li $t6 4
	move $s0 $a0 
	mult $s0 $t6
	mflo $s0
	add $s1 $t7 $s0
	sw $t2 0($s1)
	sw $t2 4($s1)
	sw $t2 8($s1)
	sw $t2 -4($s1)
	sw $t2 -8($s1)
endGenerate:
	jr $ra 

inAbove:
	li $t3 0
	sw $t3 44($sp) #save counter to zero
	sw $t3 148($sp)
	li $t4 -128
	sw $t4 32($sp)
	sw $t4 144($sp)
	lw $t5 12($sp) #display address
	li $t6 4032	#new initial position for doodle 1
	add $t6 $t5 $t6
	sw $t6 24($sp)
	li $t6 4016	#new initial position for doodle 2
	add $t6 $t5 $t6
	sw $t6 136($sp)
	lw $s2 8($sp) #pink
	sw $s2 156($sp)
	sw $s2 64($sp)
	lw $s5 72($sp)
	addi $s5 $s5 1
	sw $s5 72($sp)
	li $v0, 32
	li $a0, 1000
	syscall
	j setup2
getBottom:
	lw $t0 16($sp) #bottom
	lw $t1 24($sp) #obj position
	lw $s0 136($sp) #dd2 pos
	bgt $t1 $t0 getBottomTrue
	bgt $s0 $t0 getBottomTrue
	j getBottomFalse
getBottomTrue:
	lw $t4 28($sp) #bye color
	move $t6 $ra 
	jal backgroundSetUp
	move $ra $t6
	lw $t3 12($sp) #start address
	li $s0 400 #of1
	li $s1 960
	li $s2 736
	add $s0 $s0 $t3
	add $s1 $s1 $t3
	add $s2 $s2 $t3
	#b
	sw $t4 0($s0)
	sw $t4 128($s0)
	sw $t4 256($s0)
	sw $t4 384($s0)
	sw $t4 512($s0)
	sw $t4 640($s0)
	sw $t4 768($s0)
	sw $t4 896($s0)
	
	sw $t4 900($s0)
	sw $t4 904($s0)
	sw $t4 908($s0)
	sw $t4 912($s0)
	sw $t4 916($s0)
	
	sw $t4 512($s0)
	sw $t4 516($s0)
	sw $t4 520($s0)
	sw $t4 524($s0)
	sw $t4 528($s0)
	
	sw $t4 656($s0)
	sw $t4 784($s0)
	#y
	sw $t4 0($s1)
	sw $t4 128($s1)
	sw $t4 256($s1)
	
	sw $t4 260($s1)
	sw $t4 264($s1)
	sw $t4 268($s1)
	sw $t4 140($s1)
	sw $t4 12($s1)
	sw $t4 396($s1)
	sw $t4 524($s1)
	sw $t4 520($s1)
	sw $t4 516($s1)
	sw $t4 512($s1)
	#e
	sw $t4 0($s2)
	sw $t4 4($s2)
	sw $t4 8($s2)
	sw $t4 128($s2)
	sw $t4 256($s2)
	sw $t4 384($s2)
	sw $t4 388($s2)
	sw $t4 392($s2)
	sw $t4 512($s2)
	sw $t4 640($s2)
	sw $t4 644($s2)
	sw $t4 648($s2)
	addi $sp, $sp, 120
	# wait for retry for 10 secs
getBottom2:
	li $s3 0
	li $s4 5
getBottom3:
	beq $s3 $s4 getBottomExit
	lw $s0, 0xffff0000 #keyboard input
	beq $s0, 1, keyboard_re
getBottom4:	
	li $v0, 32
	li $a0, 1000
	syscall
	addi $s3 $s3 1
	j getBottom3
keyboard_re:
	lw $t5, 0xffff0004 
	beq $t5, 0x73, respond_to_s 
	j getBottom4
respond_to_s:
	j setup1
getBottomExit:
	li $v0, 10 
	syscall
getBottomFalse:
	jr $ra 
generateScoreZero:
	lw $s0 68($sp) #score color
	lw $s1 84($sp) #start address
	lw $s3 12($sp) #display address
	sw $s0 0($s1)
	sw $s0 4($s1)
	sw $s0 8($s1)
	sw $s0 136($s1)
	sw $s0 264($s1)
	sw $s0 392($s1)
	sw $s0 520($s1)
	sw $s0 128($s1)
	sw $s0 256($s1)
	sw $s0 384($s1)
	sw $s0 512($s1)
	sw $s0 516($s1)
	beq $s1 $s3 displayScore2
	j ScoreExit
generateScoreOne:
	lw $s0 68($sp) #score color
	lw $s1 84($sp) #start address
	lw $s3 12($sp) #display address
	sw $s0 0($s1)
	sw $s0 128($s1)
	sw $s0 256($s1)
	sw $s0 384($s1)
	sw $s0 512($s1)
	beq $s1 $s3 displayScore2
	j ScoreExit
generateScoreTwo:
	lw $s0 68($sp) #score color
	lw $s1 84($sp) #start address
	lw $s3 12($sp) #display address
	sw $s0 0($s1)
	sw $s0 4($s1)
	sw $s0 8($s1)
	sw $s0 136($s1)
	sw $s0 264($s1)
	sw $s0 260($s1)
	sw $s0 520($s1)
	sw $s0 256($s1)
	sw $s0 384($s1)
	sw $s0 512($s1)
	sw $s0 516($s1)
	beq $s1 $s3 displayScore2
	j ScoreExit
generateScoreThree:
	lw $s0 68($sp) #score color
	lw $s1 84($sp) #start address
	lw $s3 12($sp) #display address
	sw $s0 0($s1)
	sw $s0 4($s1)
	sw $s0 8($s1)
	sw $s0 136($s1)
	sw $s0 264($s1)
	sw $s0 260($s1)
	sw $s0 256($s1)
	sw $s0 392($s1)
	sw $s0 520($s1)
	sw $s0 516($s1)
	sw $s0 512($s1)
	beq $s1 $s3 displayScore2
	j ScoreExit
generateScoreFour:
	lw $s0 68($sp) #score color
	lw $s1 84($sp) #start address
	lw $s3 12($sp) #display address
	sw $s0 0($s1)
	sw $s0 8($s1)
	sw $s0 136($s1)
	sw $s0 264($s1)
	sw $s0 392($s1)
	sw $s0 520($s1)
	sw $s0 128($s1)
	sw $s0 256($s1)
	sw $s0 260($s1)
	beq $s1 $s3 displayScore2
	j ScoreExit
generateScoreFive:
	lw $s0 68($sp) #score color
	lw $s1 84($sp) #start address
	lw $s3 12($sp) #display address
	sw $s0 0($s1)
	sw $s0 4($s1)
	sw $s0 8($s1)
	sw $s0 128($s1)
	sw $s0 256($s1)
	sw $s0 260($s1)
	sw $s0 264($s1)
	sw $s0 392($s1)
	sw $s0 520($s1)
	sw $s0 512($s1)
	sw $s0 516($s1)
	beq $s1 $s3 displayScore2
	j ScoreExit
generateScoreSix:
	lw $s0 68($sp) #score color
	lw $s1 84($sp) #start address
	lw $s3 12($sp) #display address
	sw $s0 0($s1)
	sw $s0 4($s1)
	sw $s0 8($s1)
	sw $s0 264($s1)
	sw $s0 260($s1)
	sw $s0 392($s1)
	sw $s0 520($s1)
	sw $s0 128($s1)
	sw $s0 256($s1)
	sw $s0 384($s1)
	sw $s0 512($s1)
	sw $s0 516($s1)
	beq $s1 $s3 displayScore2
	j ScoreExit
generateScoreSeven:
	lw $s0 68($sp) #score color
	lw $s1 84($sp) #start address
	lw $s3 12($sp) #display address
	sw $s0 0($s1)
	sw $s0 4($s1)
	sw $s0 8($s1)
	sw $s0 136($s1)
	sw $s0 264($s1)
	sw $s0 392($s1)
	sw $s0 520($s1)
	beq $s1 $s3 displayScore2
	j ScoreExit
generateScoreEight:
	lw $s0 68($sp) #score color
	lw $s1 84($sp) #start address
	lw $s3 12($sp) #display address
	sw $s0 0($s1)
	sw $s0 4($s1)
	sw $s0 8($s1)
	sw $s0 136($s1)
	sw $s0 264($s1)
	sw $s0 392($s1)
	sw $s0 520($s1)
	sw $s0 128($s1)
	sw $s0 256($s1)
	sw $s0 260($s1)
	sw $s0 384($s1)
	sw $s0 512($s1)
	sw $s0 516($s1)
	beq $s1 $s3 displayScore2
	j ScoreExit
generateScoreNine:
	lw $s0 68($sp) #score color
	lw $s1 84($sp) #start address
	lw $s3 12($sp) #display address
	sw $s0 0($s1)
	sw $s0 4($s1)
	sw $s0 8($s1)
	sw $s0 136($s1)
	sw $s0 264($s1)
	sw $s0 392($s1)
	sw $s0 520($s1)
	sw $s0 128($s1)
	sw $s0 256($s1)
	sw $s0 260($s1)
	sw $s0 512($s1)
	sw $s0 516($s1)
	beq $s1 $s3 displayScore2
	j ScoreExit	
	




