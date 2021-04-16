----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 02/14/2021 09:05:58 PM
-- Design Name: 
-- Module Name: OP - Behavioral
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

entity OP is
    Port (
         clk              : in std_logic;
         reset            : in std_logic;
         op_en            : in std_logic;
         a1               : in std_logic_vector(6 downto 0);--the coefficient matrix elements
         a2               : in std_logic_vector(6 downto 0);
         a3               : in std_logic_vector(6 downto 0);
         a4               : in std_logic_vector(6 downto 0);
         a5               : in std_logic_vector(6 downto 0);
         a6               : in std_logic_vector(6 downto 0);
         x1               : in std_logic_vector(7 downto 0);--the input matrix elements
         x2               : in std_logic_vector(7 downto 0);
         x3               : in std_logic_vector(7 downto 0);
         x4               : in std_logic_vector(7 downto 0);
         x5               : in std_logic_vector(7 downto 0);
         x6               : in std_logic_vector(7 downto 0);
         p_o              : out std_logic_vector(17 downto 0);
         first_op_done    : out std_logic;
         column_done      : out std_logic;
         op_done          : out std_logic;
         op_finish        : out std_logic;
         op_count_out     : out std_logic_vector(4 downto 0)   
         );
end OP;

architecture Behavioral of OP is
------------------signals-------------------------------------------------
type state_type is (op_idle, op1, op2, op3);
signal  current_state,next_state            : state_type;
signal  op_count, op_count_next             : std_logic_vector(4 downto 0);
signal  column_count, column_count_next     : std_logic_vector(2 downto 0);
signal  p,p_n                               : std_logic_vector(17 downto 0); 
signal a_1,a_2                              : std_logic_vector(6 downto 0);         
signal x_1,x_2                              : std_logic_vector(7 downto 0);
                  

--------------------------------------------------------------------------
begin

op_seq : process(clk,reset)
    begin
        if reset = '1' then
            p             <= (others => '0');
            current_state <= op_idle;
            op_count      <= (others => '0');
            column_count  <= (others => '0');
        elsif rising_edge(clk) then
            current_state <= next_state;   
            p             <= p_n; 
            op_count      <= op_count_next;
            column_count  <= column_count_next;   
        end if;
    end process;
    
op_com : process(current_state,op_en,p,a1,a2,a3,a4,a5,a6,x1,x2,x3,x4,x5,x6,column_count)
    begin
        p_o <= p;--data out
        first_op_done <= '0';
        op_count_next <= op_count;
        next_state <= current_state;
        column_count_next <= column_count;
        op_done <= '0';
        column_done <= '0';
        op_finish <= '0';
        x_1 <= (others => '0');
        x_2 <= (others => '0');
        a_1 <= (others => '0');
        a_2 <= (others => '0');
        case current_state is
            when op_idle =>            
                if op_en = '1' then
                    next_state <= op1;
                else
                    next_state <= op_idle;
                end if;
            when op1 =>
                x_1<=x1;
                x_2<=x2;
                a_1<=a1;
                a_2<=a2;
                op_count_next <= op_count + 1;
                next_state <= op2;
                first_op_done <= '1';

            when op2 =>
                x_1<=x3;
                x_2<=x4;
                a_1<=a3;
                a_2<=a4;
                op_count_next <= op_count + 1;
                next_state <= op3;

            when op3 =>
                x_1<=x5;
                x_2<=x6;
                a_1<=a5;
                a_2<=a6;
                op_done <= '1';
                if op_count = 11 then
                    op_count_next <= (others => '0');
                    column_done <= '1';
                    column_count_next <= column_count + 1;
                    next_state <= op_idle;
                    if column_count = 3 then
                        column_count_next <= (others => '0');
                        op_finish <= '1';
                    else                        
                        next_state <= op_idle;
                    end if;
                else
                    op_count_next <= op_count + 1;
                    next_state <= op_idle;
                    op_done <= '1';
                end if;              
        end case;
    end process;
-----op_count_Signal-------------------------------------
    with current_state select p_n <= 
    (others => '0')       when op_idle,
    p + x_1*a_1 + x_2*a_2 when others;
op_count_out <= op_count;
end Behavioral;
