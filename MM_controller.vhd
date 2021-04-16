library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;


entity MM_controller is
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
        load_en          : out std_logic;
        op_en            : out std_logic;
        op_avg_en        : out std_logic;
        show_max_en      : out std_logic;
        show_avg_en      : out std_logic;
        store_en         : out std_logic;
        ready            : out std_logic
        );
end MM_controller;

architecture Behavioral of MM_controller is
type state_type is (idle, first_load, loadnop, opnstore, op, storenfirst_load, final_store, rom_write,input_write,show_last_element,show_max,show_avg);
signal current_state, next_state: state_type;
signal load_enable, op_enable, store_enable, rom_write_enable, input_write_enable: std_logic;
--signal store_done, op_done, load_done: std_logic;
--signal first_load_done, first_op_done: std_logic;
--signal column_done,op_finish : std_logic;
--signal op_count, op_count_next: std_logic_vector(1 downto 0);
signal p_count,p_count_next: std_logic_vector(2 downto 0);
--signal load_count, load_count_next: std_logic_vector(1 downto 0);
--signal column_count, column_count_next: std_logic_vector(1 downto 0);
--signal store_count, store_count_next: std_logic;
begin
--states machine
    process(clk,reset)
    begin
        if rising_edge(clk) then
            if reset='1' then
                current_state<=rom_write;
                p_count<=(others=>'0');
            else 
                current_state<=next_state;
                p_count<=p_count_next;
            end if;
        end if;
    end process;
    
--state machine combinational logic control path
    process(current_state,start,first_load_done,load_done,store_done,first_op_done,op_done,column_done,op_finish,rom_write_done,input_write_done)
    begin
    --set default
        ready<='0';
        next_state<=current_state;
    --state machine    
        case current_state is 
             when rom_write=>
                if rom_write_done='1' then
                    next_state<=input_write;
                else
                    next_state<=rom_write;
                end if;
            when input_write=>
                if input_write_done='1' then 
                    next_state<=idle;
                else 
                    next_state<=input_write;
                end if; 
            when idle=>
                if start='1' then
                    next_state<=first_load;
                else
                    next_state<=idle;
                end if;
                ready<='1';
            when first_load=>
                if first_load_done='1' then
                    next_state<=loadnop;
                else
                    next_state<=first_load;                  
                end if;
            when loadnop=>
                if  op_done='1' then
                    next_state<=opnstore;
                else
                    next_state<=loadnop;
                end if;
            when opnstore=>
                if first_op_done='1' and store_done='1' then
                    next_state<=op;
                else
                    next_state<=opnstore;
                end if;
            when op=>
                if op_done='1' then
                    if column_done='1' then
                        if op_finish='1' then
                            next_state<=final_store;
                        else
                            next_state<=storenfirst_load;
                        end if;
                    else 
                        next_state<=opnstore;
                    end if;
                 else
                    next_state<=op;
                 end if;
            when storenfirst_load=>
                if first_load_done='1' and store_done='1' then
                    next_state<=loadnop;
                else
                    next_state<=storenfirst_load;
                end if;
            when final_store=>
                next_state<= show_last_element;
            when show_last_element =>
                next_state<= show_max;
            when show_max=>
                next_state<= show_avg;
            when show_avg =>
                next_state <= input_write;    
        end case;
    end process;
   --state machine combinational data path
    process(current_state)
    begin
    --set default
         load_enable<='0';
        op_enable<='0';
        store_enable<='0';
        rom_write_enable<='0';
        input_write_enable<='0';
        show_max_en <= '0';
        show_avg_en <= '0';
    --state machine    
        case current_state is 
            when rom_write=>
                rom_write_enable<='1';
            when input_write=>
                input_write_enable<='1';
            when idle=>
                load_enable<='0';
                op_enable<='0';
                store_enable<='0';
            when first_load=>
                load_enable<='1';                
            when loadnop=>
--                load_enable<='1';
                op_enable<='1';
            when opnstore=>
                op_enable<='1';
                store_enable<='1';
            when op=>
                op_enable<='1';
            when storenfirst_load=>
                store_enable<='1';
                load_enable<='1';
            when final_store=>
                store_enable<='1';
            when show_last_element =>
                store_enable <= '0';
            when show_max =>
                show_max_en <= '1';
            when show_avg =>
                show_avg_en <= '1';
        end case;
    end process;
    
--result count
p_count_next<=p_count+1 when op_done='1'else
              (others=>'0') when p_count= 5 else
              (others=>'0') when input_write_enable = '1' else
              p_count; 
------------enable signals----------------------------------------------------------------------------
rom_write_en<=rom_write_enable;
input_write_en<=input_write_enable;
load_en<=load_enable;
op_en<=op_enable;
store_en<=store_enable;
op_avg_en<='1' when p_count=std_logic_vector(to_unsigned(0,3)) and op_done='1' else
           '0';

end Behavioral;
