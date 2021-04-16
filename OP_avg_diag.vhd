----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 2021/03/03 22:47:49
-- Design Name: 
-- Module Name: OP_avg_diag - Behavioral
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

entity OP_avg_diag is
Port (
       clk              : in std_logic;
       reset            : in std_logic;
       start            : in std_logic;
       op_avg_en        : in std_logic;
       ready            : in std_logic;
       p_in             : in std_logic_vector(17 downto 0);--the elements of the result matrix
       p_avg_diag       : out  std_logic_vector(17 downto 0) 
       );
end OP_avg_diag;

architecture Behavioral of OP_avg_diag is
type state_type is (op_avg_idle, op_avg_diag);
signal  current_state,next_state                    : state_type;
signal  op_avg_count, op_avg_count_next             : std_logic_vector(1 downto 0);
signal  p_avg_next, p_avg_reg                       : std_logic_vector(17 downto 0);

begin
op_avg_seq : process(clk,reset)
    begin
        if reset = '1' then
            p_avg_reg     <= (others => '0');
            current_state <= op_avg_idle;
            op_avg_count  <= (others => '0');
        elsif rising_edge(clk) then
            current_state <= next_state;   
            p_avg_reg     <= p_avg_next; 
            op_avg_count  <= op_avg_count_next;   
        end if;
    end process;
    
    process(current_state,op_avg_en,start,op_avg_count,p_in,p_avg_reg,ready)
    begin
    --set default
        op_avg_count_next<=op_avg_count;
         p_avg_next<=p_avg_reg;
         next_state<=current_state;
         case current_state is
            when op_avg_idle =>      
                if ready = '1' then
	           p_avg_next <= (others => '0'); 
                else
                   p_avg_next<=p_avg_reg;
                end if;              
                if op_avg_en = '1' then
                    next_state <= op_avg_diag;
                else
                    next_state <= op_avg_idle;
                end if;
                  
            when op_avg_diag =>
--                if start<='1' then 
--                    p_avg_next <= (others => '0');                 
--                else
                    p_avg_next <= std_logic_vector(unsigned(p_avg_reg) + unsigned(p_in));
--                end if;
--                if op_avg_count = "100" then
--                    op_avg_count <= (others => '0');
--                else
                    op_avg_count_next <= op_avg_count + 1;
--                end if;
                next_state <= op_avg_idle;
        end case;
    end process;
    
    --combinational--
    p_avg_diag <=  std_logic_vector(unsigned(p_avg_reg)/4) when op_avg_count = 0 else (others => '0');
end Behavioral;

