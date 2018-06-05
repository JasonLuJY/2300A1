  .syntax unified
  .global main
  .type main, %function

main:
  
  b begin
  
  @store the all the values of r0 for sinx while x is from 0 to pi/2
  sinx_init:

    mov r10, 0  @a counter of the number of values
    mov r12, 0x20000000 @address to store the values

    init_loop:

      @ r11 equals to 24000/(pi*frequency*counter), just for convenience
      ldr r11, =7639
      udiv r11, r4

      @ sinx = x - x^3/3! + x^5/5! - ... 
      @ this is the first piece of the polynomial
      mov r9, r5
      mul r9, r10
      udiv r9, r11
      mov r8, r9  

      @ second piece of the polynomial
      mov r9, r10
      mul r9, r10
      mul r9, r10
      udiv r9, r11
      mul r9, r5
      udiv r9, r11
      udiv r9, r11
      mov r7, 6
      udiv r9, r7
      sub r8, r9

      @ third piece of the polynomial
      mov r9, r10
      mul r9, r10
      udiv r9, r11
      mul r9, r10
      udiv r9, r11
      mul r9, r10
      udiv r9, r11
      mul r9, r10
      udiv r9, r11
      mul r9, r5
      udiv r9, r11
      mov r7, 120
      udiv r9, r7
      add r8, r9

      add r8, 0x10000

      @ store the value
      str r8, [r12], 4
      
      @ check if x approaches pi/2
      mov r8, 12000
      udiv r7, r8, r4
      add r7, 1
      adds r10, 1
      cmp r10, r7
      bne init_loop

      @ if yes, then finish the initialization
      mov r8, 12000
      udiv r4, r8, r4
      mov r11, 0x20000
      mov r9, 0x20000000
      mov r8, 360
      sub r6, r8, r6
      mul r6, r4
      mov r8, 90
      udiv r6, r8
      bx lr

begin:
  
  mov r4, 440  @ Frequency
  mov r5, 0x7000  @ Amplitude from 0 to 7fff
  mov r6, 90  @ Initial phase (degree) from -180 to 179

  bl init  @ built-in
  bl sinx_init  @ initialize

  @ delay for a while to approaches the initial phase
  init_phase:
    mov r0, 0
    bl BSP_AUDIO_OUT_Play_Sample
    subs r6, 1
    bne init_phase
  
  @start to make sound
  sound_loop:

    mov r8, 1
    mov r12, r4
    add r12, 1

    @ A cycle contains 4 parts, which are from 0 to pi/2, 
    @ from pi/2 to pi, from pi to 3pi/2, from 3pi/2 to 2pi.
    @ In each part, load the value from memory to r0 and
    @ make sound according to that. r8 is the counter of
    @ number of values that are loaded.
    zero:
      ldr r0, [r9, 4]!
      bl BSP_AUDIO_OUT_Play_Sample
      add r8, 1
      cmp r8, r12
      bne zero 

    add r12, r4

    half_pi:
      ldr r0, [r9, -4]!
      bl BSP_AUDIO_OUT_Play_Sample
      add r8, 1
      cmp r8, r12
      bne half_pi
      
    add r12, r4

    one_pi:
      ldr r10, [r9, 4]!
      sub r0, r11, r10
      bl BSP_AUDIO_OUT_Play_Sample
      add r8, 1
      cmp r8, r12
      bne one_pi

    add r12, r4

    one_and_half_pi:
      ldr r10, [r9, -4]!
      sub r0, r11, r10
      bl BSP_AUDIO_OUT_Play_Sample
      add r8, 1
      cmp r8, r12
      bne one_and_half_pi
    
    b sound_loop
      
  b main
  .size main, .-main
