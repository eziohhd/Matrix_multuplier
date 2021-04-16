----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 02/14/2021 09:05:27 PM
-- Design Name: 
-- Module Name: STORE - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


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

entity STORE is
    Port ( 
        clk              : in std_logic;
        reset            : in std_logic;
        store_en         : in std_logic;
        p_in             : in std_logic_vector(17 downto 0);--the elements of the result matrix
        store_done       : out std_logic;
        dataRAM          : out std_logic_vector(17 downto 0);
        op_max           : out std_logic_vector(17 downto 0)
            );
end STORE;

architecture Behavioral of STORE is

component SRAM_SP_WRAPPER
  port (
    ClkxCI  : in  std_logic;
    CSxSI   : in  std_logic;            -- Active Low
    WExSI   : in  std_logic;            --Active Low
    AddrxDI : in  std_logic_vector (7 downto 0);
    RYxSO   : out std_logic;
    DataxDI : in  std_logic_vector (31 downto 0);
    DataxDO : out std_logic_vector (31 downto 0)
    );
end component;

component FF 
  generic(N:integer:=1);
  port(   D  :  in std_logic_vector(N-1 downto 0);
          Q  : out std_logic_vector(N-1 downto 0);
        clk  :  in std_logic;
        reset:  in std_logic
      );
end component;

-----------------------signals-------------------------------------------
type state_type is (store_idle, store);
signal current_state,next_state  : state_type;
signal addr_ram,addr_ram_n       : std_logic_vector(7 downto 0);
signal data_ram                  : std_logic_vector(31 downto 0);
signal store_done_temp           : std_logic;
signal CSN_ram, RY_ram           : std_logic ;
signal data_out                  : std_logic_vector(31 downto 0);
signal result,result_n           : std_logic_vector(17 downto 0); 
signal result_max_n  : std_logic_vector(17 downto 0);   
signal result_max  : std_logic_vector(17 downto 0);             
begin

Ram: SRAM_SP_WRAPPER
port map(
    ClkxCI             => clk           ,
    CSxSI              => CSN_ram       , -- Active Low
    WExSI              => '0'           , -- Active Low
    AddrxDI            => addr_ram      ,
    RYxSO              => RY_ram        ,
    DataxDI            => data_ram    ,
    DataxDO            => data_out 
    );

result_m: FF 
  generic map(N => 18)
  port map(   D     =>result_max_n,
              Q     =>result_max,
            clk     =>clk,
            reset   =>reset
      );
      
result_ff: FF 
  generic map(N => 18)
  port map(   D     =>result_n,
              Q     =>result,
            clk     =>clk,
            reset   =>reset
      );

store_seq : process(clk,reset)
    begin
        if reset = '1' then
            current_state <= store_idle;
            addr_ram      <= (others => '0');
            --result        <= (others => '0');
            --result_max    <= (others => '0');
        elsif rising_edge(clk) then
            current_state <= next_state;
            addr_ram  <= addr_ram_n;   
           -- result    <= result_n;    
            --result_max <= result_max_n;     
        end if;
    end process;

store_com : process(current_state,store_en,addr_ram)
    begin
        addr_ram_n <= addr_ram;
        store_done <= '0';
        store_done_temp <= '0';
        data_ram <= (others => '0');
        case current_state is 
            when store_idle =>
                if store_en = '1' then
                    next_state <= store;
                else
                    next_state <= store_idle;
                end if;
            when store =>
                data_ram   <= std_logic_vector(to_unsigned(0,14)) & p_in;
                addr_ram_n <= addr_ram + 1;
                store_done_temp <= '1';
                store_done <= '1';
                next_state <= store_idle;
        end case;
    end process;     

result_n <= p_in when CSN_ram = '0' else result;
op_max <= result_max;
dataRAM <= result;
result_max_n <= result when result_max < result else result_max;
CSN_ram <= not (store_en and not store_done_temp);             
end Behavioral;
