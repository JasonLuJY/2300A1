  .syntax unified
  .global main
  .type main, %function

main:

  @ Store all the required values of r0 into memory in
  @ order to reduce the calculation in the main loop.
  saw_tooth_init:
    mov r1, 0x20000000  @ the memory address to store the value
    mov r2, 109  @ set the counter to 109 which is 48kHz div 440Hz
    mov r0, 0x8170 @ this value is determined to be the smallest value for r0
    init_loop:
      strh r0, [r1, 2]! @ only halfword is needed because of the characteristics of the sound player
      add r0, 600 @ difference between two adjacent values
      subs r2, 1
      bne init_loop

  bl init  @ built in function
  work_loop:  @ each loop represents a circle in the sawtooth wave
    mov r4, 109  @ counter
    mov r5, 0x20000000  @ memory address to load the values
    inner_loop:
      ldrh r0, [r5, 2]!
      bl BSP_AUDIO_OUT_Play_Sample @ play the sound
      subs r4, 1
      bne inner_loop
    b work_loop
  b main
  .size main, .-main
