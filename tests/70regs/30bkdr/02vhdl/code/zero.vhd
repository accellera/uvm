

-- VHDL Model Created from SGE Symbol zero.sym -- Oct 21 13:51:52 1992

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;

entity ZERO is
      Port (    ZERO : Out   std_logic_vector(3 downto 0) );
end ZERO;

architecture BEHAVIORAL of ZERO is
signal a:std_logic;
signal d:std_logic;
signal b:std_logic_vector(15 downto 0);
signal c:std_logic_vector(3 downto 0);
begin

   a <= '0';

end BEHAVIORAL;

configuration CFG_ZERO_BEHAVIORAL of ZERO is
   for BEHAVIORAL

   end for;

end CFG_ZERO_BEHAVIORAL;
