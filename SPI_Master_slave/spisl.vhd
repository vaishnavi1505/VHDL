-- SPI SLAVE PROTOCOL 
-- spisl, Vaishnavi Acharya, 14-June-2020

Library IEEE;
use IEEE.STD_LOGIC_1164.all;


ENTITY spisl is
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
END spisl;

ARCHITECTURE behavioural of spisl is

TYPE State_type is (Idle, csStart, startH_s, startH, startL_s, startL,
                    clkH_s, clkH, clkL_s, clkL, leadout);
SIGNAL slp_state,sln_state : State_type;
SIGNAL sdo_buf, sdi_buf : STD_LOGIC_VECTOR(USPI_SIZE -1 downto 0);
SIGNAL slcount : integer Range 0 to USPI_SIZE -1;


BEGIN

	slrecvData <= sdi_buf;

	-- SPI LOGIC
	
	--Sequential Logic
	slseq : PROCESS(bclk,resetn,sln_state,slcount)
	BEGIN
		IF rising_edge(bclk) THEN
			IF resetn= '0' THEN
				slp_state <= Idle;
				slcount <= USPI_SIZE -1;
				slsdo <= '0';
			ELSE
				IF sln_state = csStart THEN
					sdo_buf <= slsndData;
					slcount <= USPI_SIZE -1;
					
				ELSIF sln_state = startH_s THEN
					slsdo <= sdo_buf(USPI_SIZE-1);					
				ELSIF sln_state = startL_s THEN
					sdi_buf <= sdi_buf(USPI_SIZE-2 downto 0) & slsdi;					
					sdo_buf <= sdo_buf(USPI_SIZE-2 downto 0) & '-';					           
				ELSIF sln_state = clkH_s THEN
					slsdo <= sdo_buf(USPI_SIZE-1);
					slcount <=slcount -1;
				ELSIF sln_state = clkL_s THEN
					sdi_buf <= sdi_buf(USPI_SIZE-2 downto 0) & slsdi;					
					sdo_buf <= sdo_buf(USPI_SIZE-2 downto 0) &  '-';
			    ELSIF sln_state = Idle THEN
			    	slsdo <= '0';					           
				END IF;
				slp_state <= sln_state;
			END IF;
		END IF;
	END PROCESS slseq;
	

	--Combinational Logic
	slcomb : PROCESS(slp_state, slscsq, slsclk, slcount)
	BEGIN
		--defaults
		sln_state <= slp_state;
		done <= '0';
		
		CASE slp_state is
		
			WHEN Idle =>
				done <='1';
				IF slscsq = '0' THEN
					sln_state <= csStart;
				END IF;
				
			WHEN csStart =>
				IF slsclk='1' THEN
					sln_state <= startH_s;
				END IF;		
				
			WHEN startH_s => 
				sln_state <= startH;
				
			WHEN startH =>
				IF slsclk='0' THEN
					sln_state <= startL_s;
				END IF;
				
			WHEN startL_s =>
				sln_state <= startL;
				
			WHEN startL =>
				IF slsclk='1' THEN
					sln_state <= clkH_s;
				END IF;	
				
            WHEN clkH_s =>
            	sln_state <= clkH;
            	
            WHEN clkH=>
            	IF slsclk='0' THEN
					sln_state <= clkL_s;
				END IF;
				
            WHEN clkL_s=>
            	sln_state <= clkL;
            	
            WHEN clkL=>
            	IF slcount = 0 THEN
            		sln_state <= leadout;
            	ELSIF slsclk='1' THEN
					sln_state <= clkH_s;
				END IF;
            
            WHEN leadout =>
            	IF slscsq = '0' THEN
					sln_state <= Idle;
				END IF;				
		END CASE;	
	END PROCESS slcomb;	
END behavioural;
	