library ieee;
use ieee.std_logic_1164.all;
entity dut is
  
end dut;

architecture arch of dut is
  signal w,w_nodrv : natural range 0 to 255;
  signal q : natural range 0 to 255 := 15;
  signal d : natural range 0 to 255 := 240;
begin  -- arch

  w <= q;

  process
  begin
    loop
    q <= d;
    wait for 100 ns;
  end loop;
end process;

end arch;
