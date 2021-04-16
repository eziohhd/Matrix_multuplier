----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 02/10/2021 12:44:55 AM
-- Design Name: 
-- Module Name: tb_matrix_mul - Behavioral
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

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity tb_matrix_mul is
end tb_matrix_mul;

architecture Behavioral of tb_matrix_mul is
component Top 
    port(
         clk              : in std_logic;
         reset            : in std_logic;
         start            : in std_logic;
         dataInput        : in std_logic_vector(13 downto 0);
         dataOutput       : out std_logic_vector(17 downto 0);
         ready_o          : out std_logic;
         input_write_en_o : out std_logic; 
         rom_write_en_o   : out std_logic
        );
end component;
component input_gen is
    generic (
        FILE_NAME: string ;
        INPUT_WIDTH: positive
        ); 
    Port (
        clk: in std_logic;
        reset: in std_logic;
        input_write_en: in std_logic;
        input_sample: out std_logic_vector(INPUT_WIDTH-1 downto 0)
        );
end component;
   signal reset,ready       : std_logic;
   signal clk               : std_logic := '1';
   signal start             : std_logic ;
   signal dataOutput        : std_logic_vector(17 downto 0);
   signal bitstream         : std_logic_vector(13 downto 0);
   signal bitstream_inp     : std_logic_vector(7 downto 0);
   signal bitstream_coe     : std_logic_vector(13 downto 0);
   signal input_write_en    : std_logic; 
   signal rom_write_en      : std_logic;
   constant period1         : time := 5ns;

   
begin
     bitstream <= "000000"&bitstream_inp when input_write_en = '1' else
                  bitstream_coe when rom_write_en = '1' else
                  (others => '0');
     dut:Top
     port map(
             clk              => clk  , 
             reset            => reset, 
             start            => start,
             dataInput        => bitstream,
             dataOutput       => dataOutput,
             ready_o          => ready,
             input_write_en_o => input_write_en,
             rom_write_en_o   => rom_write_en
    );                
           

    input_matrix: input_gen 
    generic map(
        FILE_NAME => "/h/d9/h/ha3077hu-s/Desktop/newicp/matrix_with_mean_max/input_matrix.txt" ,
        INPUT_WIDTH => 8
        )
    Port map(
        clk     => clk,
        reset   => reset,
        input_write_en => input_write_en,
        input_sample => bitstream_inp
        );
    input_coefficient: input_gen 
    generic map(
        FILE_NAME => "/h/d9/h/ha3077hu-s/Desktop/newicp/matrix_with_mean_max/coefficient.txt",
        INPUT_WIDTH => 14
        )
    Port map(
        clk     => clk,
        reset   => reset,
        input_write_en => rom_write_en,
        input_sample => bitstream_coe
        );
     reset <= '1' ,
               '0' after    4*period1;
     start <= '0',
               '1' after    100*period1,
               '0' after    102*period1,
               '1' after    320*period1,
               '0' after    322*period1,
               '1' after    540*period1,
               '0' after    542*period1,
               '1' after    760*period1,
               '0' after    762*period1,
               '1' after    980*period1,
               '0' after    982*period1,
               '1' after    1200*period1,
               '0' after    1202*period1;
--     data_temp <="00000100000001",
--                 "00001000000011" after 6*period1,
--                 "00001100000101" after 8*period1,
--                 "00010000000111" after 10*period1,
--                 "00010100001001" after 12*period1,
--                 "00011000001011" after 14*period1,
--                 "00011100001101" after 16*period1,
--                 "00100000001111" after 18*period1,
--                 "00100100010001" after 20*period1,
--                 "00101000010011" after 22*period1,
--                 "00101100010101" after 24*period1,
--                 "00110000010111" after 26*period1;         
     clk <= not (clk) after 1*period1;
end Behavioral;
