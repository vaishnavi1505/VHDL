-- Movelights :rotate and load LEDs
-- Vaishnavi Acharya , 11-MAY-2020

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;

ENTITY movelights is
   PORT( clk : in std_logic;
         btnl : in std_logic;      --rotate left
         btnr : in std_logic;      --rotate right
         btnc : in std_logic;      --stop rotation
         btnd : in std_logic;      --load pattern from switches
         switch : in std_logic_vector(7 downto 0);
         led : out std_logic_vector(7 downto 0));
END movelights;

ARCHITECTURE behavioural of movelights is

SIGNAL led_reg : std_logic_vector(7 downto 0) := x"03";         --by default LED value will be 00000011 in FPGA
SIGNAL mv_left : std_logic := '0';
SIGNAL mv_right : std_logic := '0';

CONSTANT MAX_COUNT :integer :=3;
SIGNAL sr_pulse : std_logic ;


BEGIN

    led<= led_reg;
    
--- clock division by 3  

    cnt_p: PROCESS(clk)
    VARIABLE cnt: integer RANGE 0 to MAX_COUNT-1 := MAX_COUNT-1;
    
    BEGIN
         if rising_edge(clk) then
            sr_pulse <= '0';
            if cnt=0 then
               cnt := MAX_COUNT - 1;
               sr_pulse <= '1';
            else
               cnt := cnt - 1;
            END IF; 
         END IF;
    END PROCESS cnt_p;
    
--LED logic for buttons

    mv_logic: PROCESS(clk)
    BEGIN
       if rising_edge(clk) then
           if btnl = '1' then
               mv_left <= '1';
               mv_right <= '0';
           elsif btnr = '1' then
               mv_left <= '0';
               mv_right <= '1';
           elsif btnc = '1' then
               mv_left <= '0';
               mv_right <= '0';
           else
               mv_left <= mv_left;
               mv_right <= mv_right;
           end if;
        end if;
    END PROCESS mv_logic;
    
    lr_rot:PROCESS(clk)
    BEGIN
         if rising_edge(clk) then
            if sr_pulse='1' then
				if btnd = '1' then
				   led_reg<= switch;
				elsif mv_left = '1' then
				   ----rotate to the left
				   led_reg <= led_reg(6 downto 0) & led_reg(7);
				elsif mv_right ='1' then
				   ----rotate to the right
				   led_reg <= led_reg(0) & led_reg(7 downto 1);
				else
				   led_reg <= led_reg;
				end if;
			end if;
         end if;    
    END PROCESS lr_rot;
END behavioural;

         
        