----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 02/22/2021 04:04:13 PM
-- Design Name: 
-- Module Name: data_initialization - Behavioral
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

entity Rom_input_write is
    Port ( clk : in std_logic;
           reset : in std_logic;
           rom_write_en : in std_logic;
           input_write_en: in std_logic;
           data  : in std_logic_vector(13 downto 0);
           op_count: in std_logic_vector(4 downto 0);
           data_in: out std_logic_vector(31 downto 0);
           addr_rom_o: out std_logic_vector(7 downto 0);
           rom_write_done : out std_logic;
           input_write_done: out std_logic;
           CSN_rom: out std_logic ;
           We_o  : out std_logic;
           x1    : out std_logic_vector(7 downto 0);
           x2    : out std_logic_vector(7 downto 0);
           x3    : out std_logic_vector(7 downto 0);
           x4    : out std_logic_vector(7 downto 0);
           x5    : out std_logic_vector(7 downto 0);
           x6    : out std_logic_vector(7 downto 0)

          );
end Rom_input_write;

architecture Behavioral of Rom_input_write is

type state_type is(initial_idle,initial,input_idle,input);
signal counter_initial,counter_initial_n : std_logic_vector(3 downto 0);
signal counter_input,counter_input_n : std_logic_vector(4 downto 0);
signal current_state, next_state: state_type;
signal c_state,n_state          : state_type;
signal addr_rom,addr_rom_n  : std_logic_vector(7 downto 0);
signal  We                   : std_logic;
signal  input_reg0, input_reg0_n            : std_logic_vector(7 downto 0);
signal  input_reg1, input_reg1_n            : std_logic_vector(7 downto 0);
signal  input_reg2, input_reg2_n            : std_logic_vector(7 downto 0);
signal  input_reg3, input_reg3_n            : std_logic_vector(7 downto 0);
signal  input_reg4, input_reg4_n            : std_logic_vector(7 downto 0);
signal  input_reg5, input_reg5_n            : std_logic_vector(7 downto 0);
signal  input_reg6, input_reg6_n            : std_logic_vector(7 downto 0);
signal  input_reg7, input_reg7_n            : std_logic_vector(7 downto 0);
signal  input_reg8, input_reg8_n            : std_logic_vector(7 downto 0);
signal  input_reg9, input_reg9_n            : std_logic_vector(7 downto 0);
signal  input_reg10,input_reg10_n           : std_logic_vector(7 downto 0);
signal  input_reg11,input_reg11_n           : std_logic_vector(7 downto 0);
signal  input_reg12,input_reg12_n           : std_logic_vector(7 downto 0);
signal  input_reg13,input_reg13_n           : std_logic_vector(7 downto 0);
signal  input_reg14,input_reg14_n           : std_logic_vector(7 downto 0);
signal  input_reg15,input_reg15_n           : std_logic_vector(7 downto 0);
signal  input_reg16,input_reg16_n           : std_logic_vector(7 downto 0);
signal  input_reg17,input_reg17_n           : std_logic_vector(7 downto 0);
signal  input_reg18,input_reg18_n           : std_logic_vector(7 downto 0);
signal  input_reg19,input_reg19_n           : std_logic_vector(7 downto 0);
signal  input_reg20,input_reg20_n           : std_logic_vector(7 downto 0);
signal  input_reg21,input_reg21_n           : std_logic_vector(7 downto 0);
signal  input_reg22,input_reg22_n           : std_logic_vector(7 downto 0);
signal  input_reg23,input_reg23_n           : std_logic_vector(7 downto 0);
begin

    data_initial_seq: process(clk,reset)
    begin
        if rising_edge(clk) then
            if reset='1' then
                current_state<=initial_idle;
                c_state      <= input_idle;
                counter_initial <= (others => '0');
                counter_input <= (others => '0');
                addr_rom <= (others => '0');
            else 
                current_state<=next_state;
                c_state <= n_state;
                counter_initial <= counter_initial_n;
                counter_input  <= counter_input_n;
                addr_rom <= addr_rom_n;
                input_reg0  <= input_reg0_n;
                input_reg1  <= input_reg1_n;
                input_reg2  <= input_reg2_n;
                input_reg3  <= input_reg3_n;
                input_reg4  <= input_reg4_n;
                input_reg5  <= input_reg5_n;
                input_reg6  <= input_reg6_n;
                input_reg7  <= input_reg7_n;
                input_reg8  <= input_reg8_n;
                input_reg9  <= input_reg9_n;
                input_reg10 <= input_reg10_n;
                input_reg11 <= input_reg11_n;
                input_reg12 <= input_reg12_n;
                input_reg13 <= input_reg13_n;
                input_reg14 <= input_reg14_n;
                input_reg15 <= input_reg15_n;
                input_reg16 <= input_reg16_n;
                input_reg17 <= input_reg17_n;
                input_reg18 <= input_reg18_n;
                input_reg19 <= input_reg19_n;
                input_reg20 <= input_reg20_n;
                input_reg21 <= input_reg21_n;
                input_reg22 <= input_reg22_n;
                input_reg23 <= input_reg23_n;
            end if;
        end if;
    end process;
    
    rom_initial_com: process(current_state,rom_write_en,counter_initial,addr_rom)
    begin
        counter_initial_n <= counter_initial;
        next_state <= current_state;
        addr_rom_n <= addr_rom;
        case current_state is
            when initial_idle =>
                if rom_write_en = '1' then
                    next_state <= initial;
                else    
                    next_state <= initial_idle;
                end if;    
             when initial =>
                if addr_rom = 11 then
                    addr_rom_n <= (others => '0');
                else
                    addr_rom_n <= addr_rom + 1;
                end if;
                if counter_initial = 12 then 
                    next_state <= initial_idle;
                    counter_initial_n <= std_logic_vector(to_unsigned(12,4));
                else
                    next_state <= initial;
                    counter_initial_n <= counter_initial + 1;
                end if;
             when others =>
                next_state <= initial_idle;
             end case;
         end process;  
         
    input_initial_com: process(c_state,input_write_en,counter_input,data,input_reg0,input_reg1,input_reg2,input_reg3,input_reg4,input_reg5,input_reg6,input_reg7,input_reg8,input_reg9,input_reg10,input_reg11,input_reg12,input_reg13,input_reg14,input_reg15,input_reg16,input_reg17,input_reg18,input_reg19,input_reg20,input_reg21,input_reg22,input_reg23)
    begin
        input_write_done <= '0';
        counter_input_n <= counter_input;
        n_state <= c_state;
        input_reg0_n     <= input_reg0;
        input_reg1_n     <= input_reg1;
        input_reg2_n     <= input_reg2;
        input_reg3_n     <= input_reg3;
        input_reg4_n     <= input_reg4;
        input_reg5_n     <= input_reg5;
        input_reg6_n     <= input_reg6;
        input_reg7_n     <= input_reg7;
        input_reg8_n     <= input_reg8;
        input_reg9_n     <= input_reg9;
        input_reg10_n    <= input_reg10;
        input_reg11_n    <= input_reg11;
        input_reg12_n    <= input_reg12;
        input_reg13_n    <= input_reg13;
        input_reg14_n    <= input_reg14;
        input_reg15_n    <= input_reg15;
        input_reg16_n    <= input_reg16;
        input_reg17_n    <= input_reg17;
        input_reg18_n    <= input_reg18;
        input_reg19_n    <= input_reg19;
        input_reg20_n    <= input_reg20;
        input_reg21_n    <= input_reg21;
        input_reg22_n    <= input_reg22;
        input_reg23_n    <= input_reg23;
        case c_state is
            when input_idle =>   
                if input_write_en = '1' then
                    n_state <= input;
                else    
                    n_state <= input_idle;
                end if;    
             when input =>
                counter_input_n <= counter_input + 1;
                if counter_input = 0 then
                    input_reg0_n <= data(7 downto 0);
                elsif counter_input = 1 then
                    input_reg1_n <= data(7 downto 0);
                elsif counter_input = 2 then
                    input_reg2_n <= data(7 downto 0);   
                elsif counter_input = 3 then
                    input_reg3_n <= data(7 downto 0);
                elsif counter_input = 4 then
                    input_reg4_n <= data(7 downto 0);   
                elsif counter_input = 5 then
                    input_reg5_n <= data(7 downto 0);
                elsif counter_input = 6 then
                    input_reg6_n <= data(7 downto 0);      
                elsif counter_input = 7 then
                    input_reg7_n <= data(7 downto 0);
                elsif counter_input = 8 then
                    input_reg8_n <= data(7 downto 0);  
                elsif counter_input = 9 then
                    input_reg9_n <= data(7 downto 0);
                elsif counter_input = 10 then
                    input_reg10_n <= data(7 downto 0);
                  elsif counter_input = 11 then
                    input_reg11_n <= data(7 downto 0);
                elsif counter_input = 12 then
                    input_reg12_n <= data(7 downto 0);  
                elsif counter_input = 13 then
                    input_reg13_n <= data(7 downto 0);
                elsif counter_input = 14 then
                    input_reg14_n <= data(7 downto 0); 
                elsif counter_input = 15 then
                    input_reg15_n <= data(7 downto 0);
                elsif counter_input = 16 then
                    input_reg16_n <= data(7 downto 0); 
                elsif counter_input = 17 then
                    input_reg17_n <= data(7 downto 0);
                elsif counter_input = 18 then
                    input_reg18_n <= data(7 downto 0);   
                elsif counter_input = 19 then
                    input_reg19_n <= data(7 downto 0);
                elsif counter_input = 20 then
                    input_reg20_n <= data(7 downto 0);
                  elsif counter_input = 21 then
                    input_reg21_n <= data(7 downto 0);
                elsif counter_input = 22 then
                    input_reg22_n <= data(7 downto 0);
                else 
                    input_reg23_n <= data(7 downto 0);
                    n_state <= input_idle;     
                    counter_input_n <= (others => '0');
                    input_write_done <= '1';    
                end if;
             when others =>
                n_state <= input_idle;
             end case;
         end process;  
--------------------input matrix-----------------------------------------------------
x1 <= input_reg0 when op_count < 3 else
      input_reg6 when op_count < 6 else
      input_reg12 when op_count < 9 else
      input_reg18 when op_count < 12 else
      (others => '0');
x2 <= input_reg1 when op_count < 3  else
      input_reg7 when op_count < 6  else
      input_reg13 when op_count < 9  else
      input_reg19 when op_count < 12 else
      (others => '0');
x3 <= input_reg2 when op_count < 3   else
      input_reg8 when op_count < 6   else
      input_reg14 when op_count < 9  else
      input_reg20 when op_count < 12 else
      (others => '0');
x4 <= input_reg3 when op_count < 3   else
      input_reg9 when op_count < 6   else
      input_reg15 when op_count < 9  else
      input_reg21 when op_count < 12 else
      (others => '0');
x5 <= input_reg4  when op_count < 3  else
      input_reg10 when op_count < 6    else
      input_reg16 when op_count < 9  else
      input_reg22 when op_count < 12 else
      (others => '0');
x6 <= input_reg5 when op_count < 3   else
      input_reg11 when op_count < 6  else
      input_reg17 when op_count < 9  else
      input_reg23 when op_count < 12 else
      (others => '0');     
-------------signal connection--------------------------------------------------------
We_o <= '1' when counter_initial = 12 else '0' ;
addr_rom_o <= addr_rom;
data_in <= "000000000000000000"&data;
CSN_rom <= '0';
rom_write_done <= '1' when counter_initial = 12 else '0';
end Behavioral;
