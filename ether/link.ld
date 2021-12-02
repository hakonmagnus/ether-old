ENTRY(_start)

SECTIONS
{
    . = 1M;
    
    .entry BLOCK(4K) : ALIGN(4K)
    {
        *(.entry)
    }
    
    .text BLOCK(4K) : ALIGN(4K)
    {
        *(.multiboot)
        *(.text)
    }
    
    .rodata BLOCK(4K) : ALIGN(4K)
    {
        *(.rodata)
    }
    
    .data BLOCK(4K) : ALIGN(4K)
    {
        *(.data)
    }
    
    .bss BLOCK(4K) : ALIGN(4K)
    {
        *(.bss)
    }
}