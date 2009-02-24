-- $Revision$
-- $Date$
-- $Author$
-- $Source$



library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity sync is
  port(
    reset : in std_logic;
    clk_rx : in std_logic;
    clk_tx : in std_logic;
    sync_rx : in std_logic;
    sync_tx : out std_logic;
    ack : out std_logic
    );
end sync;

  architecture behv of sync is

-- tx side
signal f0_d : std_logic_vector(2 downto 0);
signal f0_q : std_logic_vector(2 downto 0);

-- rx side
signal f1_d : std_logic_vector(2 downto 0);
signal f1_q : std_logic_vector(2 downto 0);

signal int0 : std_logic;
signal int1 : std_logic;

  begin

sync_tx <= f0_q(1) and not(f0_q(2));
int0 <= f1_q(0);
int1 <= not(f1_q(1));
ack <= not(int1);
            
 async : process(reset, f0_q, f1_q, sync_rx, int0, int1)
     begin
       if (reset = '1') then
            f0_d <= (others => '0');
            f1_d <= (others => '0');
        else
         f0_d(0) <= f1_q(0);
         f1_d(0) <= ((sync_rx or int0) and int1);
         f0_d(2 downto 1) <= f0_q(1 downto 0);
         f1_d(2) <= f0_q(2);
         f1_d(1) <= f1_q(2);
        end if;
  end process;

    
 syncro_tx : process(clk_tx)
   begin
   if rising_edge(clk_tx) then
     f0_q <= f0_d;
   end if;
  end process;

 syncro_rx : process(clk_rx)
   begin
   if rising_edge(clk_rx) then
     f1_q <= f1_d;
   end if;
 end process;


 end behv;
