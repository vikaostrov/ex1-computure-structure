/* 212736219 Vika Ostrovsky */

#for read only data
.section .rodata
    Seed: .string "Enter configuration seed: "
    Format_d: .string "%d" #the string for scanf
    #which mode str
    Mode_Q: .string "Would you like to play in easy mode? (y/n) "
    Format_c: .string " %c"
    Guess_Q: .string "What is your guess? "
    Smaller_msg: .string "Incorrect. Your guess was below the actual number ..."
    Greater_msg: .string "Incorrect. Your guess was above the actual number ..."
    Win_ask_double: .string "Double or nothing! Would you like to continue to another round? (y/n) "
    win_final_msg: .string "Congratz! You won %d rounds!\n"
    lose_msg: .string "Game over, you lost :(. The correct answer was %d\n"

.section .data
    N: .long 10
    M: .long 5
     
#variable initialized to 0
.section .bss
    #saves 4 bytes in ram with the value 0
    user_seed: .zero 4 
    user_mode: .zero 1
    random_num: .zero 4
    user_guess: .zero 4
    turn_count: .zero 4
    win_count: .zero 4
    user_answer: .zero 1
     
.section .text
.globl main
    main:
        #makes the stack to 16 bytes(for the functions)
        pushq %rbp  
        #move the adress to the register
        leaq Seed, %rdi 
        movq $0, %rax #the convention
        call printf

        leaq Format_d, %rdi
        leaq user_seed, %rsi
        movq $0, %rax #the convention
        call scanf  

        #print the question
        leaq Mode_Q, %rdi
        movq $0, %rax #the convention
        call printf

        #get the result
        leaq Format_c, %rdi
        leaq user_mode, %rsi
        movq $0, %rax #the convention
        call scanf 

    start_round:
        #the function srand
        #mun =32bits so use the low part of the register
        movl user_seed, %edi
        call srand

        #random number generate
        call rand
        #put the immidiate num 0 at edx(part of rdx), equal to "random_num = (rand() % 10) + 1"
        movl $0, %edx
        #divide in 10
        divl N
        addl $1, %edx
        movl %edx, random_num

        #the loop of the turns
        game_loop:
            #first ask the guess(print question)
            leaq Guess_Q, %rdi
            movq $0, %rax #the convention
            call printf

            #the second step is scanf
            leaq Format_d, %rdi
            leaq user_guess, %rsi
            movq $0, %rax #the convention
            call scanf

            #compare and take the guess from the ram to register
            #check if the user was right
            movl user_guess, %ecx
            cmpl random_num, %ecx
            #jump if equal to the label win_game
            je win_game

            #otherwise,the guess is wrong

            addl $1, turn_count

            movl turn_count, %r8d
            cmpl M, %r8d
            je lose_game

            #check which mode the user chose
            cmpb $'y', user_mode
            jne game_loop

            #compare again
            cmpl random_num, %ecx
            jg print_greater

            #otherwise the number is smaller and we in easy mode
            #print the number is smaller- hint
            leaq Smaller_msg, %rdi
            movq $0, %rax
            call printf
            jmp game_loop

        #print the number is grater- hint
        print_greater:
            leaq Greater_msg, %rdi
            movq $0, %rax
            call printf
            jmp game_loop


        win_game:
            #ask the user for another round
            addl $1, win_count

            leaq Win_ask_double, %rdi
            movq $0, %rax
            call printf

            #get the result
            leaq Format_c, %rdi
            leaq user_answer, %rsi
            movq $0, %rax #the convention
            call scanf 

            #check the answer
            cmpb $'y', user_answer
            je double_round

            #if the user doesnt want another round
            leaq win_final_msg, %rdi
            movq $0, %rax
            movl win_count, %esi
            call printf

            popq %rbp
            ret

        double_round:    
            shll $1, user_seed
            shll $1, N
            movl $0, turn_count
            jmp start_round

        lose_game:
             leaq lose_msg, %rdi
            movl random_num, %esi
            movq $0, %rax
            call printf
            
            movq $0, %rax
            popq %rbp
            ret





