SECTIONS
{
  . = 0x00000000;
  .text.init : { *(.text.init) }
  .text : { *(.text) }
  . = 0x10000000;
  .data : { *(.data) }
  .bss : { *(.bss) }
  _end = .;
}
