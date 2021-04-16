library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity LOAD is
    Port (
         clk              : in std_logic;
         reset            : in std_logic;
         load_en          : in std_logic;
         data_rom         : in  std_logic_vector(31 downto 0); 
         column_done      : in std_logic;
         first_load_done  : out std_logic;
         load_done        : out std_logic;
         CSN              : out std_logic;
         a1_o             : out std_logic_vector(6 downto 0);--the input matrix elements
         a2_o             : out std_logic_vector(6 downto 0);
         a3_o             : out std_logic_vector(6 downto 0);
         a4_o             : out std_logic_vector(6 downto 0);
         a5_o             : out std_logic_vector(6 downto 0);
         a6_o             : out std_logic_vector(6 downto 0);
         addr_rom_o       : out std_logic_vector(3 downto 0)      
         );
end LOAD;

architecture Behavioral of LOAD is
------------------signals-------------------------------------------------
type state_type is (load_idle, load1, load2, load3);
signal current_state,next_state        : state_type;
signal a1,a2,a3,a4,a5,a6               : std_logic_vector(6 downto 0);
signal a1_n,a2_n,a3_n,a4_n,a5_n,a6_n   : std_logic_vector(6 downto 0);
signal addr_rom,addr_rom_n             : std_logic_vector(3 downto 0);--locate the elements in the coefficent matrix   
component FF 
  generic(N:integer:=1);
  port(   D  :  in std_logic_vector(N-1 downto 0);
          Q  : out std_logic_vector(N-1 downto 0);
        clk  :  in std_logic;
        reset:  in std_logic
      );
end component;             

begin
coefficient1 : FF
  generic map(N => 7)
  port map(
          D  => a1_n,
          Q  => a1,
          clk => clk,
          reset => reset
          );
coefficient2 : FF
  generic map(N => 7)
  port map(
          D  => a2_n,
          Q  => a2,
          clk => clk,
          reset => reset
          );
coefficient3 : FF
  generic map(N => 7)
  port map(
          D  => a3_n,
          Q  => a3,
          clk => clk,
          reset => reset
          );
coefficient4 : FF
  generic map(N => 7)
  port map(
          D  => a4_n,
          Q  => a4,
          clk => clk,
          reset => reset
          );
coefficient5 : FF
  generic map(N => 7)
  port map(
          D  => a5_n,
          Q  => a5,
          clk => clk,
          reset => reset
          );
coefficient6 : FF
  generic map(N => 7)
  port map(
          D  => a6_n,
          Q  => a6,
          clk => clk,
          reset => reset
          );

load_seq : process(clk,reset)
    begin
        if reset = '1' then
            current_state <= load_idle;
            addr_rom      <= (others => '0');
        elsif rising_edge(clk) then
            current_state <= next_state;
            addr_rom  <= addr_rom_n;
        end if;
    end process;
    
load_com : process(current_state,load_en,addr_rom,column_done,a1,a2,a3,a4,a5,a6,data_rom)
    begin
        next_state <= current_state;
        a1_n       <= a1;
        a2_n       <= a2;
        a3_n       <= a3;
        a4_n       <= a4;
        a5_n       <= a5;
        a6_n       <= a6;
        first_load_done <= '0';
        load_done       <= '0';
        addr_rom_n      <= addr_rom; 
        CSN<='0';
        case current_state is
            when load_idle =>
                addr_rom_n <= std_logic_vector(unsigned(addr_rom) + 1);    
                if  load_en = '1'  then --column_done = '1'
                    next_state <= load1;
                else
                    next_state <= load_idle;
                    addr_rom_n <= addr_rom;
                end if;
            when load1 =>
                a1_n <= data_rom(13 downto 7);
                a2_n <= data_rom( 6 downto 0);
                first_load_done <= '1';
                CSN<='0';
                next_state <= load2;
                addr_rom_n <= std_logic_vector(unsigned(addr_rom) + 1);
            when load2 =>
                a3_n <= data_rom(13 downto 7);
                a4_n <= data_rom( 6 downto 0);
                CSN<='0';
                next_state <= load3;
                addr_rom_n <= std_logic_vector(unsigned(addr_rom) + 1);
            when load3 =>
                if addr_rom = 12 then
                addr_rom_n <= (others => '0');
                else 
		addr_rom_n <= addr_rom;
                end if;							
                a5_n <= data_rom(13 downto 7);
                a6_n <= data_rom( 6 downto 0);
                CSN<='0';
                load_done  <= '1';
                next_state <= load_idle;     
   
        end case;
    end process;

----------------------------an out-----------------------------------------
a1_o       <= a1;
a2_o       <= a2;    
a3_o       <= a3;
a4_o       <= a4;
a5_o       <= a5;
a6_o       <= a6;
addr_rom_o <= addr_rom;
end Behavioral;

