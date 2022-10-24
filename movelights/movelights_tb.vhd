-- movelights :test bench for rotate and load LEDs
-- Vaishnavi Acharya , 11-MAY-2020

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;

ENTITY movelights_tb is
END movelights_tb;

ARCHITECTURE behavioural of movelights_tb is

COMPONENT movelights is
   PORT( clk : in std_logic;
         btnl : in std_logic;      --rotate left
         btnr : in std_logic;      --rotate right
         btnc : in std_logic;      --stop rotation
         btnd : in std_logic;      --load pattern from switches
         switch : in std_logic_vector(7 downto 0);
         led : out std_logic_vector(7 downto 0));
END COMPONENT movelights;

SIGNAL clk :  std_logic := '0';
SIGNAL btnl :  std_logic := '0';      --rotate left
SIGNAL btnr :  std_logic := '0';      --rotate right
SIGNAL btnc :  std_logic := '0';      --stop rotation
SIGNAL btnd :  std_logic := '0';      --load pattern from switches
SIGNAL switch :  std_logic_vector(7 downto 0) := x"81";
SIGNAL led :  std_logic_vector(7 downto 0):= x"00";


CONSTANT  clk_period: time := 10 ns;


BEGIN


     uut: movelights
     PORT MAP(clk  =>   clk ,
			  btnl =>   btnl,
			  btnr =>   btnr,
			  btnc =>   btnc,
			  btnd =>   btnd,
			  switch => switch,
              led =>    led );
   
      clk_p: PROCESS
      BEGIN
           clk <='0';
           wait for clk_period/2;
           clk <='1';
           wait for clk_period/2;
      END PROCESS clk_p;
      
      stim_p: PROCESS
      BEGIN
           wait for clk_period *4;
           btnd <= '1';
           wait for clk_period;
           btnd <= '0';
           wait for clk_period *4;
           btnl <= '1';
           wait for clk_period;
           btnl <= '0';
           wait for clk_period *50;
           btnr <= '1';
           wait for clk_period;
           btnr <= '0';
           wait for clk_period *50;
           btnc <= '1';
           wait for clk_period;
           btnc <= '0';
           switch <= x"ED";
           wait for clk_period *20;
           btnd <= '1';
           wait for clk_period;
           btnd <= '0';
           wait for clk_period;
           report " => movelight test bench finished.";
           wait;
           
      END PROCESS stim_p;
              
   
END behavioural;

         
        