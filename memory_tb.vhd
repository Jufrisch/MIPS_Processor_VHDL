library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.alu_lib.all;

entity memory_tb is
end memory_tb;

architecture TB of memory_tb is
	signal done       : std_logic := '0';
	signal clk        : std_logic := '0';
	signal rst        : std_logic := '1';
	signal address    : std_logic_vector(31 downto 0) := (others => '0');
	signal data       : std_logic_vector(31 downto 0) := (others => '0');
	signal Wr_Data       : std_logic_vector(31 downto 0) := (others => '0');
	signal MemRead    : std_logic := '0';
	signal MemWrite   : std_logic := '0';
	signal Inport0En : std_logic := '0';
	signal Inport1En : std_logic := '0';
	signal InPort     : std_logic_vector(31 downto 0) := (others => '0');
	signal OutPort    : std_logic_vector(31 downto 0) := (others => '0');
begin --TB

    clk <= (not clk) and (not done) after 10 ns;

	UUT: entity work.memory
		port map (
			clk        => clk,
			rst        => rst,
			address    => address,
			Rd_Data       => data,
			Wr_Data       => Wr_Data,
			MemRead    => MemRead,
			MemWrite   => MemWrite,
			Inport1En => Inport1En,
			Inport0En => Inport0En,
			InPort     => InPort,
			OutPort    => OutPort
		);

	process
	begin

		done <= '0';
		rst   <= '1';
		for i in 0 to 9 loop
			wait for 40 ns;
		end loop;
		rst <= '0';

		-- load both in ports with 0
		InPort <= x"00000000";
		Inport1En <= '1';
		wait for 40 ns;
		Inport1En <= '0';
		Inport0En <= '1';
		wait for 40 ns;
		Inport0En <= '0';

		-- Write 0x0A0A0A0A to byte address 0x00000000
		MemWrite <= '1';
		Wr_Data <= x"0A0A0A0A";
		address <= x"00000000";
		wait for 40 ns;
		MemWrite <= '0';

		-- Write 0xF0F0F0F0 to byte address 0x00000004
		MemWrite <= '1';
		Wr_Data <= x"F0F0F0F0";
		address <= x"00000004";
		wait for 40 ns;
		MemWrite <= '0';

		wait for 40 ns;

		-- Read from byte address 0x00000000 (should show 0x0A0A0A0A on read data output)
		MemRead <= '1';
		address <= x"00000000";
		wait for 40 ns;
		MemRead <= '0';

		-- Read from byte address 0x00000001 (should show 0x0A0A0A0A on read data output)
		MemRead <= '1';
		address <= x"00000001";
		wait for 40 ns;
		MemRead <= '0';

		-- Read from byte address 0x00000004 (should show 0xF0F0F0F0 on read data output)
		MemRead <= '1';
		address <= x"00000004";
		wait for 40 ns;
		MemRead <= '0';

		-- Read from byte address 0x00000005 (should show 0xF0F0F0F0 on read data output)
		MemRead <= '1';
		address <= x"00000005";
		wait for 40 ns;
		MemRead <= '0';

		-- Write 0x00001111 to the outport (should see value appear on outport)
		MemWrite <= '1';
		Wr_Data <= x"00001111";
		address <= x"0000FFFC";
		wait for 40 ns;
		MemWrite <= '0';

		-- Load 0x00010000 into inport 0
		InPort <= x"00010000";
		Inport0En <= '1';
		wait for 40 ns;
		Inport0En <= '0';

		-- Load 0x00000001 into inport 1
		InPort <= x"00000001";
		Inport1En <= '1';
		wait for 40 ns;
		Inport1En <= '0';

		-- Read from inport 0 (should show 0x00010000 on read data output)
		MemRead <= '1';
		address <= x"0000FFF8";
		wait for 40 ns;
		MemRead <= '0';

		-- Read from inport 1 (should show 0x00000001 on read data output)
		MemRead <= '1';
		address <= x"0000FFFC";
		wait for 40 ns;
		MemRead <= '0';

		wait for 15 ns;
		done <= '1';
		report "Done" severity note;
		wait;
		
	end process;
end TB;