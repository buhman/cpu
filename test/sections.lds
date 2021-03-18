MEMORY
{
   IMEM (xr) : ORIGIN = 0x0, LENGTH = 0x400
}

SECTIONS {
    .text :
    {
        . = ALIGN(4);
        *(.text)
    } >IMEM
}
