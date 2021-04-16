----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 02/10/2021 02:49:03 PM
-- Design Name: 
-- Module Name: Top - Behavioral
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
entity Top is
    port(
         clk     : in std_logic;
         reset   : in std_logic;
         start   : in std_logic;
         dataInput:in std_logic_vector(13 downto 0);
         dataOutput : out std_logic_vector(17 downto 0);
         ready_o    : out std_logic;
         input_write_en_o : out std_logic; 
         rom_write_en_o   : out std_logic
        );
end Top;
architecture Behavioral of Top is
  component CPAD_S_74x50u_IN            --input PAD

    port (
      COREIO : out std_logic;
      PADIO  : in  std_logic);
  end component;

  component CPAD_S_74x50u_OUT           --output PAD
    port (
      COREIO : in  std_logic;
      PADIO  : out std_logic);
  end component;

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
component Rom_input_write is
    Port ( clk                : in std_logic;
           reset              : in std_logic;
           rom_write_en       : in std_logic;
           data               : in std_logic_vector(13 downto 0);
           op_count           : in std_logic_vector(4 downto 0);
           input_write_en     : in std_logic;
           data_in            : out std_logic_vector(31 downto 0);
           addr_rom_o         : out std_logic_vector(7 downto 0);
           rom_write_done     : out std_logic;
           input_write_done   : out std_logic;
           CSN_rom            : out std_logic ;
           We_o               : out std_logic;
           x1                 : out std_logic_vector(7 downto 0);
           x2                 : out std_logic_vector(7 downto 0);
           x3                 : out std_logic_vector(7 downto 0);
           x4                 : out std_logic_vector(7 downto 0);
           x5                 : out std_logic_vector(7 downto 0);
           x6                 : out std_logic_vector(7 downto 0)
          );
end component;
component MM_controller 
  Port (
        clk              : in std_logic;
        reset            : in std_logic;
        start            : in std_logic;
        rom_write_done   : in std_logic;
        input_write_done : in std_logic;
        store_done       : in std_logic;
        op_done          : in std_logic;
        load_done        : in std_logic;
        first_load_done  : in std_logic;
        first_op_done    : in std_logic;
        column_done      : in std_logic;
        op_finish        : in std_logic;
        rom_write_en     : out std_logic;
        input_write_en   : out std_logic;
        show_max_en      : out std_logic;
        show_avg_en      : out std_logic;
        load_en          : out std_logic;
        op_en            : out std_logic;
        op_avg_en        : out std_logic;
        store_en         : out std_logic;
        ready            : out std_logic
        );
end component;

component LOAD
    Port ( 
         clk              : in std_logic;
         reset            : in std_logic;
         load_en          : in std_logic;
         column_done      : in std_logic;
         data_rom         : in  std_logic_vector(31 downto 0); 
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
end component;     
component STORE
    Port ( 
        clk              : in std_logic;
        reset            : in std_logic;
        store_en         : in std_logic;
        p_in             : in std_logic_vector(17 downto 0);--the elements of the result matrix
        store_done       : out std_logic;
        dataRAM          : out std_logic_vector(17 downto 0);
        op_max           : out std_logic_vector(17 downto 0)
            );
end component;  
component OP 
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
end component;


component OP_avg_diag is
Port (
       clk              : in std_logic;
       reset            : in std_logic;
       start            : in std_logic;
       op_avg_en        : in std_logic;
       ready            : in std_logic;
       p_in             : in std_logic_vector(17 downto 0);--the elements of the result matrix
       p_avg_diag       : out  std_logic_vector(17 downto 0) 
       );
end component;
----------signal--------------------------------------------------------------------------       
signal  load_en,op_en,store_en,ready       : std_logic;
signal  op_max_en,op_avg_en          : std_logic;
signal  column_count                 : std_logic_vector(1 downto 0);
signal  a1,a2,a3,a4,a5,a6            : std_logic_vector(6 downto 0);  
signal  p                            : std_logic_vector(17 downto 0);
signal store_done, op_done, load_done: std_logic;
signal first_load_done, first_op_done: std_logic;
signal column_done,op_finish         : std_logic;
signal data_rom                      : std_logic_vector(31 downto 0); 
signal addr_rom                      : std_logic_vector(3 downto 0);
signal RY_rom, CSN_rom               : std_logic;
signal addrxdi                       : std_logic_vector(7 downto 0);
signal We                            : std_logic;
signal data_in                       : std_logic_vector(31 downto 0);
signal addr_rom_o                    : std_logic_vector(7 downto 0);     
signal CSN_data_initial,CSN_load,CSN : std_logic;     
signal op_count                      : std_logic_vector(4 downto 0);
signal rom_write_en                  : std_logic;
signal input_write_en                : std_logic;
signal show_max_en                   : std_logic;
signal show_avg_en                   : std_logic; 
signal rom_write_done                : std_logic;
signal input_write_done              : std_logic;
signal    x1                         :  std_logic_vector(7 downto 0);
signal    x2                         :  std_logic_vector(7 downto 0);
signal    x3                         :  std_logic_vector(7 downto 0);
signal    x4                         :  std_logic_vector(7 downto 0);
signal    x5                         :  std_logic_vector(7 downto 0);
signal    x6                         :  std_logic_vector(7 downto 0);
signal    p_max                      :  std_logic_vector(17 downto 0);
signal   p_avg_diag                  :  std_logic_vector(17 downto 0);
signal   dataRam                     :  std_logic_vector(17 downto 0);
signal clki,reseti                   : std_logic;  
signal starti                        : std_logic;  
signal dataInputi                    : std_logic_vector(13 downto 0);
signal dataOutputi                   : std_logic_vector(17 downto 0);
signal ready_oi                      : std_logic;
signal input_write_en_oi,  rom_write_en_oi:  std_logic; 
                   
-------------------------------------------------------------------------------------------                     
begin
-----------------------signals----------------------------------------------------------------
ready_oi <= ready;
dataOutputi <= p_max when show_max_en ='1' else
              p_avg_diag when show_avg_en = '1' else
              dataRam;
CSN_rom <= CSN_data_initial when rom_write_done = '0' else
           CSN_load;
addrxdi <= addr_rom_o when rom_write_done = '0' else
           "0000"&addr_rom;
-------------------------------------------------------------------------------------------------
romandinput_write:Rom_input_write
port map(
        clk               => clki         ,
        reset             => reseti       ,
        rom_write_en      => rom_write_en,  
        input_write_en    => input_write_en,
        data              => dataInputi     ,
        op_count          => op_count , 
        data_in           => data_in     ,
        addr_rom_o        => addr_rom_o  ,
        rom_write_done    => rom_write_done,
        input_write_done  => input_write_done,
        CSN_rom           => CSN_data_initial,
        We_o              => We,              
        x1                => x1,
        x2                => x2,
        x3                => x3,
        x4                => x4,
        x5                => x5,
        x6                => x6
        );

Rom:SRAM_SP_WRAPPER
port map(
    ClkxCI              => clki          ,
    CSxSI               => CSN_rom       , -- Active Low
    WExSI               => We            , -- Active Low
    AddrxDI             => addrxdi       ,
    RYxSO               => RY_rom        ,
    DataxDI             => data_in       ,
    DataxDO             => data_rom
    );
controller_part:MM_controller
port map(

        clk             => clki            ,  
        reset           => reseti          ,  
        start           => starti          ,  
        rom_write_done  => rom_write_done ,
        input_write_done=> input_write_done,
        store_done      => store_done     ,
        op_done         => op_done        ,
        load_done       => load_done      ,
        first_load_done => first_load_done,
        first_op_done   => first_op_done  ,
        column_done     => column_done    ,
        op_finish       => op_finish      ,
        rom_write_en    => rom_write_en  ,
        input_write_en  => input_write_en,
        load_en         => load_en        , 
        op_en           => op_en          , 
        op_avg_en       => op_avg_en      , 
        show_max_en     => show_max_en    ,
        show_avg_en     => show_avg_en    ,
        store_en        => store_en       , 
        ready           => ready            
      
            );
load_part:LOAD
port map(
        
        clk             => clki             ,
        reset           => reseti           ,
        load_en         => load_en         ,
        column_done     => column_done     ,
        data_rom        => data_rom        ,
        first_load_done => first_load_done ,
        load_done       => load_done       ,
        CSN             => CSN_load        ,
        a1_o            => a1              ,
        a2_o            => a2              ,
        a3_o            => a3              ,
        a4_o            => a4              ,
        a5_o            => a5              ,
        a6_o            => a6              ,
        addr_rom_o      => addr_rom        
            );
op_part:OP
port map(       
        clk             =>   clki          ,
        reset           =>   reseti        ,
        op_en           =>   op_en        ,
        a1              =>   a1           ,
        a2              =>   a2           ,
        a3              =>   a3           ,
        a4              =>   a4           ,
        a5              =>   a5           ,
        a6              =>   a6           ,
        x1              =>   x1           ,
        x2              =>   x2           ,
        x3              =>   x3           ,
        x4              =>   x4           ,
        x5              =>   x5           ,
        x6              =>   x6           ,
        p_o             =>   p            ,
        first_op_done   =>   first_op_done,
        column_done     =>   column_done  ,
        op_done         =>   op_done      ,
        op_finish       =>   op_finish    , 
        op_count_out    =>   op_count
   
         );
store_part:STORE
port map(
         clk            =>  clki         ,
         reset          =>  reseti        ,
         store_en       =>  store_en     ,
         p_in           =>  p         ,
         store_done     =>  store_done ,
         dataRAM        =>  dataRam   ,
         op_max         =>  p_max   
         );     

        
        
 op_avg_diag_part:OP_avg_diag
 Port map(
        clk             =>  clki     ,
        reset           =>  reseti   ,
        start           =>  starti   ,
        op_avg_en       =>  op_avg_en,
        ready           =>  ready   ,
        p_in            =>  p       ,
        p_avg_diag      =>  p_avg_diag   
        );
-----------en signal-------------------------------------------------
input_write_en_oi <= input_write_en;
rom_write_en_oi   <= rom_write_en;
--pad map---------------------------------------------------------------------------------
  clkpad : CPAD_S_74x50u_IN
    port map (
      COREIO => clki,
      PADIO  => clk
      );
  resetpad : CPAD_S_74x50u_IN
    port map (
      COREIO => reseti,
      PADIO  => reset
      );   
   startpad : CPAD_S_74x50u_IN
    port map (
      COREIO => starti,
      PADIO  => start
      );
  InPads : for i in 0 to 13 generate
    InPad : CPAD_S_74x50u_IN
      port map (
        COREIO => dataInputi(i),
        PADIO  => dataInput(i)
        );
  end generate InPads;
  input_enpad : CPAD_S_74x50u_OUT
    port map (
      COREIO => input_write_en_oi,
      PADIO  => input_write_en_o
      );
   rom_enpad : CPAD_S_74x50u_OUT
    port map (
      COREIO => rom_write_en_oi,
      PADIO  => rom_write_en_o
      );
   readypad : CPAD_S_74x50u_OUT
    port map (
      COREIO => ready_oi,
      PADIO  => ready_o
      );
   OutPads : for i in 0 to 17 generate
    OutPad : CPAD_S_74x50u_OUT
      port map (
        COREIO => dataOutputi(i),
        PADIO  => dataOutput(i)
        );
  end generate OutPads;
   
      
end Behavioral;
