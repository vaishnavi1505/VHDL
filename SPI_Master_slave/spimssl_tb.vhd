-- SPI MASTER/SLAVE TEST BENCH
-- spimssl_tb, Vaishnavi Acharya, 14-June-2020

Library IEEE;
use IEEE.STD_LOGIC_1164.all;


ENTITY spimssl_tb is	
END spimssl_tb;

ARCHITECTURE behavioural of spimssl_tb is

COMPONENT spims is
	GENERIC(USPI_SIZE : integer :=16);
	PORT( resetn : in STD_LOGIC;
		  bclk : in STD_LOGIC;
		  start : in STD_LOGIC;
		  done : out STD_LOGIC;
		  scsq : out STD_LOGIC;  
		  sclk : out STD_LOGIC;  
		  sdo : out STD_LOGIC;   
		  sdi : in STD_LOGIC;    
		  sndData : in STD_LOGIC_VECTOR(USPI_SIZE -1 downto 0);
		  recvData : out STD_LOGIC_VECTOR(USPI_SIZE -1 downto 0));
END COMPONENT spims;

COMPONENT spisl is
	GENERIC(USPI_SIZE : integer :=16);
	PORT( resetn : in STD_LOGIC;
		  bclk : in STD_LOGIC;
		  slsclk : in STD_LOGIC;
		  slscsq : in STD_LOGIC; 
		  done : out STD_LOGIC;
		  slsdo : out STD_LOGIC;  
		  slsdi : in STD_LOGIC;  
		  slsndData : in STD_LOGIC_VECTOR(USPI_SIZE -1 downto 0);
		  slrecvData : out STD_LOGIC_VECTOR(USPI_SIZE -1 downto 0));
END COMPONENT spisl;

CONSTANT SPI_BITS : integer := 8;

SIGNAL resetn :  STD_LOGIC := '1';
SIGNAL bclk :  STD_LOGIC := '0';
SIGNAL start :  STD_LOGIC := '0';
SIGNAL scsq :  STD_LOGIC := '0';  
SIGNAL sclk :  STD_LOGIC := '0';  
SIGNAL MOSI :  STD_LOGIC := '0';   
SIGNAL MISO :  STD_LOGIC := '0'; 

SIGNAL done_master :  STD_LOGIC := '0';
SIGNAL done_slave :  STD_LOGIC := '0';

SIGNAL sndData_master :  STD_LOGIC_VECTOR(SPI_BITS-1 downto 0) := x"5A";
SIGNAL recvData_master :  STD_LOGIC_VECTOR(SPI_BITS-1 downto 0) := x"00";
SIGNAL sndData_slave :  STD_LOGIC_VECTOR(SPI_BITS-1 downto 0) := x"F8";
SIGNAL recvData_slave :  STD_LOGIC_VECTOR(SPI_BITS-1 downto 0) := x"00";

CONSTANT clk_period : time := 10 ns;


BEGIN

	uut_m: spims
		GENERIC MAP ( USPI_SIZE => SPI_BITS)
		PORT MAP ( resetn => resetn,
				   bclk => bclk,
				   start => start,
				   done => done_master,
				   scsq => scsq,
				   sclk => sclk,
				   sdo => MOSI,
				   sdi => MISO,
				   sndData => sndData_master,
				   recvData => recvData_master);
				   
	uut_s: spisl
		GENERIC MAP ( USPI_SIZE => SPI_BITS)
		PORT MAP ( resetn => resetn,
				   bclk => bclk,
				   done => done_slave,
				   slscsq => scsq,
				   slsclk => sclk,
				   slsdo => MISO,
				   slsdi => MOSI,
				   slsndData => sndData_slave,
				   slrecvData => recvData_slave);			   
				   
		clk_p : PROCESS
		BEGIN
			bclk <= '0';
			WAIT FOR clk_period/2;
			bclk <= '1';
			WAIT FOR clk_period/2;
		END PROCESS clk_p;
		
		
		
		stim_p : PROCESS
		BEGIN
			WAIT FOR clk_period;
			resetn <= '0';
			WAIT FOR clk_period;
			resetn <= '1';
			WAIT FOR clk_period*4;
			start <= '1';
			WAIT FOR clk_period*4;
			start <= '0';
			WAIT FOR clk_period*10;
			report "spimssl simulation done";
			wait;
		END PROCESS stim_p;

	
END behavioural;
	