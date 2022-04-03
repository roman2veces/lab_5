----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 03/28/2022 03:58:14 PM
-- Design Name: 
-- Module Name: DigiLock - Behavioral
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

entity DigiLock is
    Port ( 
        clk: in std_logic;
        reset: in std_logic;
        A: in std_logic;
        B: in std_logic;
        C: in std_logic;
       -- SEG_0: out std_logic_vector(3 downto 0);
      --  SEG_1: out std_logic_vector(3 downto 0);
      --  SEG_2: out std_logic_vector(3 downto 0);
      --  SEG_3: out std_logic_vector(3 downto 0)
        SEG0: out std_logic_vector(3 downto 0);
        SEG1: out std_logic_vector(3 downto 0);
        SEG2: out std_logic_vector(3 downto 0);
        SEG3: out std_logic_vector(3 downto 0)
    );
end DigiLock;

architecture Behavioral of DigiLock is

    type Etat is (Init, waiting, E0, E1, E2, Ouvert, Alarme, Alarm_0);
    --type Alarm_state is (Alarm_init, alarm_i0, alarm_i1);
    signal etat_present: Etat := Init;
    signal etat_prochain: Etat := Init;
    signal unique_A :std_logic;
    signal unique_B :std_logic;
    signal unique_C :std_logic;
    
    component pulse_generator is 
        Port ( 
            clk: in std_logic;
            reset: in std_logic;
            input: in std_logic;
            output: out std_logic
        );
    end component;
        
    COMPONENT DEBOUNCE IS
        GENERIC(
            counter_size  :  INTEGER := 19); --counter size (19 bits gives 10.5ms with 50MHz clock)
        PORT(
            clk     : IN  STD_LOGIC;  --input clock
            button  : IN  STD_LOGIC;  --input signal to be debounced
            result  : OUT STD_LOGIC); --debounced signal
    END COMPONENT;
    
    --signal debounced_A: std_logic;
    --signal debounced_B: std_logic;
    --signal debounced_C: std_logic;
    signal debounce_reset: std_logic;
    signal pressed_value: std_logic_vector(3 downto 0) := "0000";   

begin
    --U1: DEBOUNCE port map(clk => clk, button => A, result => debounced_A);
    --U2: DEBOUNCE port map(clk => clk, button => B, result => debounced_B);
    --U3: DEBOUNCE port map(clk => clk, button => C, result => debounced_C);
    U1: pulse_generator port map(clk => clk, reset => debounce_reset,  input => A, output => unique_A);
    U2: pulse_generator port map(clk => clk, reset => debounce_reset,  input => B, output => unique_B);
    U3: pulse_generator port map(clk => clk, reset => debounce_reset,  input => C, output => unique_C);
    U4: DEBOUNCE port map(clk => clk, button => reset, result => debounce_reset);
        
    process (clk, debounce_reset)
    begin        
        if debounce_reset = '0' then
            etat_present <= Init;
        elsif rising_edge(clk) then
            etat_present <= etat_prochain;
        end if;
    end process;
    
    process (unique_A, unique_B, unique_C)
    begin 
        if unique_A = '1' then
            pressed_value <= "0001";
        elsif unique_B = '1' then
            pressed_value <= "0010";
        elsif unique_C = '1' then 
            pressed_value <= "0011";
        else 
            pressed_value <= "0000";
        end if;
    end process;
    
    process (pressed_value) 
        variable entree_0: std_logic_vector(3 downto 0);
        variable entree_1: std_logic_vector(3 downto 0);
        variable entree_2: std_logic_vector(3 downto 0);
        variable entree_3: std_logic_vector(3 downto 0);
        variable compteur: integer RANGE 0 TO 4 := 0;
    begin 
        
        case etat_present is 
            when Init => 
                SEG0 <= "0100"; -- 0100 = 4 = L
                SEG1 <= "0000"; -- 0000 = 0 = -
                SEG2 <= "0000";
                SEG3 <= "0000"; 
                etat_prochain <= waiting; 
            
            when waiting =>        
                if pressed_value /= "0000" then
                    entree_0 := pressed_value;
                    SEG0 <= pressed_value;
                    etat_prochain <= E0;
                end if;
          
            when E0 => 
                if pressed_value /= "0000" then    
                    entree_1 := pressed_value;
                    SEG1 <= pressed_value;
                    etat_prochain <= E1;
                end if;
                
            when E1 =>
                if pressed_value /= "0000" then
                    entree_2 := pressed_value;
                    SEG2 <= pressed_value;
                    etat_prochain <= E2;
                end if;
                
            when E2 =>
                if pressed_value /= "0000" then
                    entree_3 := pressed_value;
                    SEG3 <= pressed_value;
                    
                    if entree_0 = "0011" and entree_1 = "0001" and entree_2 = "0011" and entree_3 = "0010" then -- CODE = 0011000100110010 = CACB
                        SEG0 <= "0101"; -- 0101 = 5 = O
                        SEG1 <= "0101";
                        SEG2 <= "0101";
                        SEG3 <= "0101";
                        etat_prochain <= Ouvert;
                    elsif compteur = 2 then  -- car il commence a zero
                        SEG0 <= "0000";
                        SEG1 <= "0000";
                        SEG2 <= "0100"; -- 0100 = 4 = L
                        SEG3 <= "0001"; -- 0001 = 1 = A 
                        compteur := 0;
                        etat_prochain <= Alarme;
                    else 
                        compteur := compteur + 1;
                        SEG0 <= "0100"; -- 0100 = 4 = L
                        SEG1 <= "0000"; -- 0000 = 0 = -
                        SEG2 <= "0000";
                        SEG3 <= "0000";
                        etat_prochain <= waiting;
                    end if;                       
                end if;
                
            when Ouvert =>
                if unique_A = '1' or unique_B = '1' or unique_C = '1' then
                    etat_prochain <= waiting;
                end if;
                            
            when Alarme => 
                if pressed_value = "0011" then  
                    etat_prochain <= Alarm_0;
                end if;
                           
            when Alarm_0 => 
                if pressed_value = "0010" then
                    SEG0 <= "0100"; -- 0100 = 4 = L
                    SEG1 <= "0000"; -- 0000 = 0 = -
                    SEG2 <= "0000";
                    SEG3 <= "0000";
                    etat_prochain <= waiting;
                elsif pressed_value = "0001" then
                    etat_prochain <= Alarme;
                end if;
                                
            end case;      
    end process;    
end Behavioral;
