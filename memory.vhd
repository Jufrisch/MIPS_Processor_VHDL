library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.ALU_LIB.all;

entity memory is
    port (
        clk          : in std_logic;
        rst          : in std_logic;
        address      : in  std_logic_vector(31 downto 0);
        Rd_Data         : out std_logic_vector(31 downto 0);
        Wr_Data         : in  std_logic_vector(31 downto 0);
        MemRead      : in std_logic;
        MemWrite     : in std_logic;
        Inport1En    : in  std_logic;
        Inport0En    : in  std_logic;
        InPort       : in  std_logic_vector(31 downto 0);
        OutPort      : out std_logic_vector(31 downto 0)
    );
end memory;

architecture bhv of memory is
    signal OutportWrEn : std_logic;
    signal Ram_en     : std_logic;
    signal InPort0    : std_logic_vector(31 downto 0);
    signal InPort1    : std_logic_vector(31 downto 0);
    signal Ram_Out     : std_logic_vector(31 downto 0);
    signal OutSel     : std_logic_vector(1 downto 0);

begin

	process(address, MemWrite)
	begin
		OutportWrEn <= '0';
		Ram_en <= '0';
		if (MemWrite = '1') then
			if (address = x"0000FFFC") then --outport address
				OutportWrEn <= '1';
			else
				Ram_en <= '1';
			end if; 
	   end if;
	end process;

	process (clk,rst)
	begin
		if (rst = '1') then
			OutSel <= "11";
		elsif (rising_edge(clk)) then 
			if (MemRead = '1') then
				if (address = x"0000FFF8") then --inport0 address
					OutSel <= "00";
				elsif (address = x"0000FFFC") then --inport1 address
					OutSel <= "01";
				else 
					OutSel <= "10";
				end if;
			end if;
		end if;
	end process;

	OUT_MUX: entity work.mux_4x1
		generic map (WIDTH => 32)
		port map (
			sel    => OutSel,
			in0    => InPort0,
			in1    => InPort1,
			in2    => Ram_Out,
			in3    => (others => '0'),
			output => Rd_Data
		);

	IN_PORT_0: entity work.reg
		generic map (WIDTH => 32)
		port map (
			clk    => clk,
			rst    => '0',
			en     => Inport0En,
			input  => InPort,
			output => InPort0
		);

	IN_PORT_1: entity work.reg
		generic map (WIDTH => 32)
		port map (
			clk    => clk,
			rst    => '0',
			en     => Inport1En,
			input  => InPort,
			output => InPort1
		);

	OUT_PORT: entity work.reg
		generic map (WIDTH => 32)
		port map (
			clk    => clk,
			rst    => rst,
			en     => OutportWrEn,
			input  => Wr_Data,
			output => OutPort
		);
		
	RAM: entity work.ram
		port map (
			address	=> address(9 downto 2),
			clock   => clk,
			data	=> Wr_Data,
			wren	=> Ram_en,
			q		=> Ram_Out
		);



end bhv;