-- SPI MASTER (transmit/receive)
-- spims, Vaishnavi Acharya, 14-June-2020

Library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;

ENTITY spims_tb is
	
END spims_tb;

ARCHITECTURE behavioural of spims_tb is

COMPONENT spims is
	GENERIC(USPI_SIZE : integer :=16);
	PORT( resetn : in STD_LOGIC;
		  bclk : in STD_LOGIC;
		  start : in STD_LOGIC;
		  done : out STD_LOGIC;
		  scsq : out STD_LOGIC;  --SPI signal
		  sclk : out STD_LOGIC;  --SPI signal
		  sdo : out STD_LOGIC;   --SPI signal
		  sdi : in STD_LOGIC;    --SPI signal
		  sndData : in STD_LOGIC_VECTOR(USPI_SIZE -1 downto 0);
		  recvData : out STD_LOGIC_VECTOR(USPI_SIZE -1 downto 0));
END COMPONENT spims;


CONSTANT SPI_NBITS : integer := 8;
SIGNAL resetn :  STD_LOGIC := '1';
SIGNAL bclk :  STD_LOGIC := '0';
SIGNAL start :  STD_LOGIC := '0';
SIGNAL done :  STD_LOGIC := '0';
SIGNAL scsq :  STD_LOGIC := '0';  
SIGNAL sclk :  STD_LOGIC := '0';  
SIGNAL S_out :  STD_LOGIC := '0';   
SIGNAL S_in :  STD_LOGIC := '0';    
SIGNAL sndData :  STD_LOGIC_VECTOR(SPI_NBITS-1 downto 0) := x"5A";
SIGNAL recvData :  STD_LOGIC_VECTOR(SPI_NBITS-1 downto 0);

CONSTANT clk_period : time := 10 ns;


BEGIN

	uut: spims
		GENERIC MAP ( USPI_SIZE => SPI_NBITS)
		PORT MAP ( resetn => resetn,
				   bclk => bclk,
				   start => start,
				   done => done,
				   scsq => scsq,
				   sclk => sclk,
				   sdo => S_out,
				   sdi => S_in,
				   sndData => sndData,
				   recvData => recvData);
				   
		clk_p : PROCESS
		BEGIN
			bclk <= '0';
			WAIT FOR clk_period/2;
			bclk <= '1';
			WAIT FOR clk_period/2;
		END PROCESS clk_p;
		
		S_in <=  S_out;
		
		stim_p : PROCESS
		BEGIN
			WAIT FOR clk_period;
			resetn <= '0';
			WAIT FOR clk_period;
			resetn <= '1';
			WAIT FOR clk_period*8;
			start <= '1';
			WAIT FOR clk_period*4;
			start <= '0';
			WAIT FOR clk_period*10;
			report "spims simulation done";
			wait;
		END PROCESS stim_p;

	
END behavioural;
	