-- SPI MASTER (transmit/receive)
-- spims, Vaishnavi Acharya, 14-June-2020

Library IEEE;
use IEEE.STD_LOGIC_1164.all;

ENTITY spims is
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
END spims;

ARCHITECTURE behavioural of spims is

TYPE State_type is (sIdle, sStartx, sStart_L, sClk_H, sClk_L, sStop_H, sStop_L);
SIGNAL p_state,n_state : State_type;
SIGNAL SCLK_i, SCSQ_i, SDO_i : STD_LOGIC;
SIGNAL wr_buf : STD_LOGIC_VECTOR(USPI_SIZE -1 downto 0);
SIGNAL rd_buf : STD_LOGIC_VECTOR(USPI_SIZE -1 downto 0);
SIGNAL count : integer Range 0 to USPI_SIZE -1;
SIGNAL spi_clkp : std_logic ;
CONSTANT CLK_DIV :integer :=3;
SUBTYPE clkdv_type is integer RANGE 0 to CLK_DIV-1;

BEGIN

	recvData <= rd_buf;
	
	
	--- clock division by 3 
	clk_d: PROCESS(bclk)
    VARIABLE clkd_cnt: clkdv_type;
    
    BEGIN
         IF rising_edge(bclk) THEN
            spi_clkp <= '0';
            IF resetn='0' THEN
               clkd_cnt := CLK_DIV - 1;
            ELSIF clkd_cnt=0 THEN
               spi_clkp <= '1';
               clkd_cnt := CLK_DIV - 1;
            ELSE
               clkd_cnt := clkd_cnt - 1;
            END IF; 
         END IF;
    END PROCESS clk_d;
	
	-- SPI LOGIC
	
	--Sequential Logic
	seq_p : PROCESS(bclk,resetn,count,n_state,sndData,SCSQ_i,SCLK_i,SDO_i,
	                spi_clkp)
	BEGIN
		IF rising_edge(bclk) THEN
			IF resetn= '0' THEN
				p_state <= sIdle;
			ELSIF spi_clkp='1' THEN
				p_state <= n_state;
				scsq <= SCSQ_i;
				sclk <= SCLK_i;
				sdo <= SDO_i;
				IF n_state = sStartx THEN
					  wr_buf <= sndData;
					  count <= USPI_SIZE -1;
				ELSIF n_state = sClk_H THEN
					  count <= count - 1;
			    ELSIF n_state = sClk_L THEN
					  wr_buf <= wr_buf(USPI_SIZE-2 downto 0) & '-';
				      rd_buf <= rd_buf(USPI_SIZE-2 downto 0) & sdi;
				ELSIF n_state = sStop_L THEN
					  rd_buf <= rd_buf(USPI_SIZE-2 downto 0) & sdi;			
				END IF;
			END IF;
		END IF;
	END PROCESS seq_p;
	

	--Combinational Logic
	comb_p : PROCESS(p_state, start, count, wr_buf)
	BEGIN
		--defaults
		n_state <= p_state;
		done <= '0';
		SCSQ_i <= '0';
		SCLK_i <= '0';
		SDO_i <= '0';
		CASE p_state is
		
			WHEN sIdle =>
				done <= '1';
				SCSQ_i <= '1';
				IF start= '1' THEN
					n_state <= sStartx;
				END IF;
				
			WHEN sStartx =>
				n_state <= sStart_L;
				
			WHEN sStart_L =>
				SCLK_i <= '1';
				SDO_i <= wr_buf(USPI_SIZE-1);
				n_state <= sClk_H;
				
			WHEN sClk_H =>
				SDO_i <= wr_buf(USPI_SIZE-1);
				n_state <= sClk_L;	
				
			WHEN sClk_L =>
				SCLK_i <= '1';
				SDO_i <= wr_buf(USPI_SIZE-1);
				IF count =0 THEN
					n_state <= sStop_H;
				ELSE
					n_state <= sClk_H;
				END IF;
				
			WHEN sStop_H =>
				SDO_i <= wr_buf(USPI_SIZE-1);
				n_state <= sStop_L;
				
			WHEN sStop_L =>
				SCSQ_i <= '1';
				n_state <= sIdle;				
		END CASE;	
	END PROCESS comb_p;	
END behavioural;
	