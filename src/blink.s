
.syntax unified
.cpu cortex-m0
.thumb

/* =====================================================
   STM32F031F6P6
   Bare-metal ARM assembly LED blink
   LED: PA0 (TSSOP20 physical pin 10)
   Clock: Default HSI = 8 MHz
   ===================================================== */

.equ RCC_AHBENR,  0x40021014
.equ GPIOA_MODER, 0x48000000
.equ GPIOA_BSRR,  0x48000018

.section .isr_vector, "a", %progbits
.align 2

.word _estack
.word Reset_Handler

/* Remaining exception and interrupt vectors */
.rept 46
.word Default_Handler
.endr

.section .text.Reset_Handler
.global Reset_Handler
.type Reset_Handler, %function

Reset_Handler:

    /* Enable GPIOA clock */
    ldr r0, =RCC_AHBENR
    ldr r1, [r0]
    movs r2, #1
    lsls r2, r2, #17
    orrs r1, r2
    str r1, [r0]

    /* Configure PA0 as general-purpose output.
       MODER0 = 01
    */
    ldr r0, =GPIOA_MODER
    ldr r1, [r0]
    bic r1, r1, #3
    orr r1, r1, #1
    str r1, [r0]

main_loop:

    /* LED ON: Set PA0 */
    ldr r0, =GPIOA_BSRR
    movs r1, #1
    str r1, [r0]

    bl delay

    /* LED OFF: Reset PA0 */
    ldr r0, =GPIOA_BSRR
    movs r1, #1
    lsls r1, r1, #16
    str r1, [r0]

    bl delay

    b main_loop

delay:
    /* Software delay loop */
    ldr r2, =100
outer_loop:
    ldr r1, =4000

inner_loop:
    subs r1, r1, #1
    bne inner_loop

    subs r2, r2, #1
    bne outer_loop

    bx lr

Default_Handler:
    b Default_Handler

.size Reset_Handler, .-Reset_Handler

.ltorg
