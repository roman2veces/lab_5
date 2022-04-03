----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 21.03.2022 15:32:52
-- Design Name: 
-- Module Name: disp7seg - Behavioral
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

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

ENTITY DISP_7_SEG_LAB4 IS
    PORT (
        CLK :       IN STD_LOGIC;
        RST : IN STD_LOGIC;
        A: IN STD_LOGIC;
        B: IN STD_LOGIC;
        C: IN STD_LOGIC;
     --   SEG_0 :     IN STD_LOGIC_VECTOR(3 downto 0);
     -- SEG_1 :     IN STD_LOGIC_VECTOR(3 downto 0);
     --   SEG_2 :     IN STD_LOGIC_VECTOR(3 downto 0);
     --   SEG_3 :     IN STD_LOGIC_VECTOR(3 downto 0);
        AN :        OUT STD_LOGIC_VECTOR(7 downto 0);
        SEVEN_SEG : OUT STD_LOGIC_VECTOR(7 downto 0)
    );
END DISP_7_SEG_LAB4;

ARCHITECTURE BEHAVE OF DISP_7_SEG_LAB4 IS

SIGNAL TICK : STD_LOGIC;

COMPONENT DigiLock is
    Port ( 
        clk: in std_logic;
        reset: in std_logic;
        A: in std_logic;
        B: in std_logic;
        C: in std_logic;
        SEG0: out std_logic_vector(3 downto 0);
        SEG1: out std_logic_vector(3 downto 0);
        SEG2: out std_logic_vector(3 downto 0);
        SEG3: out std_logic_vector(3 downto 0)
    );
end COMPONENT;

    signal SEG_0 : STD_LOGIC_VECTOR(3 downto 0);
    signal SEG_1 : STD_LOGIC_VECTOR(3 downto 0);
    signal SEG_2 : STD_LOGIC_VECTOR(3 downto 0);
    signal SEG_3 : STD_LOGIC_VECTOR(3 downto 0);

BEGIN
    U1: DigiLock port map(
        clk => clk, 
        reset => RST, 
        A => A, 
        B => B, 
        C => C, 
        SEG0 => SEG_0,
        SEG1 => SEG_1,
        SEG2 => SEG_2,
        SEG3 => SEG_3 
    );
   
	-- Frequency divider
	PROCESS(CLK)
	VARIABLE DIC_CNT : UNSIGNED(16 downto 0);
	BEGIN
		IF rising_edge(CLK) THEN
			DIC_CNT := DIC_CNT + 1;
		END IF;
            TICK <= DIC_CNT(DIC_CNT'LEFT);
	END PROCESS;

	PROCESS (TICK, SEG_0, SEG_1, SEG_2, SEG_3)
	   variable DISPLAY: INTEGER RANGE 0 TO 3 := 0;
	   variable SEL_SEG : STD_LOGIC_VECTOR(3 DOWNTO 0);
	BEGIN
		IF RISING_EDGE(TICK) THEN
			IF DISPLAY = 0 THEN
				SEL_SEG := SEG_0;
				AN <= x"FE";
				DISPLAY := DISPLAY + 1;
			ELSIF DISPLAY = 1 THEN
				SEL_SEG := SEG_1;
				AN <= x"FD";
				DISPLAY := DISPLAY + 1;
			ELSIF DISPLAY = 2 THEN
				SEL_SEG := SEG_2;
				AN <= x"FB";
				DISPLAY := DISPLAY + 1;
			ELSE
				SEL_SEG := SEG_3;
				AN <= x"F7";
				DISPLAY := 0;
			END IF;
			
			CASE SEL_SEG IS
				WHEN "0000" => SEVEN_SEG <= "10111111";
				WHEN "0001" => SEVEN_SEG <= "10001000";
				WHEN "0010" => SEVEN_SEG <= "10000011";
				WHEN "0011" => SEVEN_SEG <= "10100111";
				WHEN "0100" => SEVEN_SEG <= "11000111";
				WHEN "0101" => SEVEN_SEG <= "10100011";
				WHEN "0110" => SEVEN_SEG <= "11100011";
				WHEN "0111" => SEVEN_SEG <= "10000110";
				WHEN "1000" => SEVEN_SEG <= "10101111";
				WHEN OTHERS => SEVEN_SEG <= "11111111";
			END CASE;
		END IF;
	END PROCESS;

END ARCHITECTURE BEHAVE;
