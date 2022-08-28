# The Ibnalhaytham CPU
### Naming criteria:
This project was named after the great arabic scientist Ibn al-haytham to honor his contributions to science, his most important work is the Kitab al-Manazir (Book of Optics). In the 11th century he managed to pioneer significant contributions in the field of optics and has been referred to as "the father of modern optics". 

<p align="center" float="center">
  <img src="https://upload.wikimedia.org/wikipedia/commons/f/f4/Hazan.png" height="300" />
  <img src="https://upload.wikimedia.org/wikipedia/commons/f/f2/Alhazen1652.png" height="300" /> 
</p>

Numerous scientists from the Golden age of Islam usualy don't get the respect they deserve, I used this oportunity to remind the scientific community of the contributions of these scientists. They were an early pioneer in the scientific method five centuries before Renaissance scientists, they employed experiments and innovation in their research long before anyone else did.
To name a few:
- Persian mathematician al-Khwarizmi who is regarded as "the father of algebra"
- Persian physician, philosopher and alchemist who has been described as the father of pediatrics, and a pioneer of obstetrics and ophthalmology. Notably, he became the first human physician to recognize the reaction of the eye's pupil to light.
- Persian physician and philosopher Ibn Sina (Avicenna) the father of early modern medicine, his book The Canon of Medicine, became a standard medical text at many medieval universities and remained in use as late as 1650.
- Arab physician and surgeon al-Zahrawi is considered to be the greatest surgeon of the Middle Ages, he has been referred to as the "father of modern surgery".

## Introduction
This project is consisted of a memory controller and a processor; The processor is a RISC-V based pipelined processor with 16 registers. The memory controller simulates an instruction memory and has 10 32bit words as the data memory, the contents of which are outputted to io_out periodically. The simulated instruction memory is in fact an interface between the caravel management core and the processor, it can stall the processor until the next instruction arrives from the management core.

<p align="center" float="center">
  <img src="docs/1.jpg" width="350"/>
</p>


## Processor
supported instructions
signals
## Memory Controller
what it does
signals
## Test it yourself

## Final GDS

## TODO
use smaller memory and register addresses
test the memory controler for openram

