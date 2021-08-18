OUTPUT_ARCH("riscv")

ENTRY(_start)

MEMORY
{
    IRAM (rx!wai) : ORIGIN = 0x00000000, LENGTH = 16K
    DRAM (wa!rxi) : ORIGIN = 0x10000000, LENGTH = 16K
}

SECTIONS
{
    __stack_size = DEFINED(__stack_size) ? __stack_size : 2K;

    .init : {
        *(.vector)
        KEEP (*(SORT_NONE(.init)))
    } >IRAM AT>IRAM

    .text : {
        *(.text.unlikely .text.unlikely.*)
        *(.text.startup .text.startup.*)
        *(.text .text.*)
        *(.gnu.linkonce.t.*)
    } >IRAM AT>IRAM

    .rodata : {
        *(.rdata)
        *(.rodata .rodata.*)
        *(.srodata .srodata.*)
    } >DRAM AT>DRAM

    .data : {
        *(.data .data.*)
        *(.gnu.linkonce.d.*)
        PROVIDE( __global_pointer$ = . + 0x800 );
        *(.sdata .sdata.* .sdata*)
        *(.gnu.linkonce.s.*)
    } >DRAM AT>DRAM

    .bss : {
        *(.sbss*)
        *(.gnu.linkonce.sb.*)
        *(.bss .bss.*)
        *(.gnu.linkonce.b.*)
        *(COMMON)
    } >DRAM AT>DRAM

    .stack ORIGIN(DRAM) + LENGTH(DRAM) - __stack_size : {
        . = __stack_size;
        PROVIDE( __stack_pointer$ = . );
    } >DRAM AT>DRAM
}
