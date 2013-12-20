library ieee;
use ieee.std_logic_1164.all;
entity dut is
  
end dut;

architecture arch of dut is
  signal w,w_nodrv : std_ulogic_vector(7 downto 0);
  signal q : std_ulogic_vector(7 downto 0) := X"0f";
  signal d : std_ulogic_vector(7 downto 0) := X"f0";
begin  -- arch

  w <= q;

  process
  begin
    loop
      wait for 100 ns;
      q <= d;
    end loop;
  end process;

end arch;
