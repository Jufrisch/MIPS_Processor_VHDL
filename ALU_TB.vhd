library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.ALU_LIB.all;

entity ALU_TB is
end ALU_TB;

architecture TB of ALU_TB is
	constant WIDTH  : positive := 32;
	signal INPUT1     : std_logic_vector(WIDTH-1 downto 0) := (others=>'0');
	signal INPUT2     : std_logic_vector(WIDTH-1 downto 0) := (others=>'0');
	signal SHIFT_N    : std_logic_vector(4 downto 0) := (others=>'0');
	signal SEL   	  : std_logic_vector(SEL_SIZE-1 downto 0) := (others=>'0');
	signal RESULT     : std_logic_vector(WIDTH-1 downto 0);
	signal RESULT_Hi  : Std_logic_vector(WIDTH-1 downto 0);
	signal BRANCH     : std_logic := '0';
	
	
begin
	UUT: entity work.ALU
		generic map ( WIDTH => WIDTH )
		port map (
			INPUT2   => INPUT2,
			INPUT1   => INPUT1,
			SHIFT_N => SHIFT_N,
			SEL 		=> SEL,
			RESULT   => RESULT,
			RESULT_Hi => RESULT_Hi,
			BRANCH   =>BRANCH
			);
	process
	begin 


		SEL <= ADD_UNSIGNED;
		INPUT1 <= std_logic_vector(to_unsigned(10, WIDTH));
		INPUT2 <= std_logic_vector(to_unsigned(15, WIDTH));
		wait for 10 ns;
		assert(RESULT = std_logic_vector(to_unsigned(25, WIDTH))) report "ADD_UNSIGNED RESULT incorrect" severity failure;
		assert(RESULT_Hi = std_logic_vector(to_unsigned(0, WIDTH))) report "ADD_UNSIGNED RESULT_Hi incorrect" severity failure;
		assert(BRANCH = '0') report "ADD_UNSIGNED BRANCH incorrect" severity failure;

		SEL <= SUB_UNSIGNED;
		INPUT1 <= std_logic_vector(to_unsigned(25, WIDTH));
		INPUT2 <= std_logic_vector(to_unsigned(10, WIDTH));
		wait for 10 ns;
		assert(RESULT = std_logic_vector(to_unsigned(15, WIDTH))) report "SUB_UNSIGNED RESULT incorrect" severity failure;
		assert(RESULT_Hi = std_logic_vector(to_unsigned(0, WIDTH))) report "SUB_UNSIGNED RESULT_Hi incorrect" severity failure;
		assert(BRANCH = '0') report "SUB_UNSIGNED BRANCH incorrect" severity failure;

		SEL <= MULT_SIGNED;
		INPUT1 <= std_logic_vector(to_signed(10, WIDTH));
		INPUT2 <= std_logic_vector(to_signed(-4, WIDTH));
		wait for 10 ns;
		assert(RESULT_Hi&RESULT = std_logic_vector(to_signed(-40, WIDTH*2))) report "MULT_SIGNED RESULT&RESULT_Hi incorrect" severity failure;
		assert(BRANCH = '0') report "MULT_SIGNED BRANCH incorrect" severity failure;

		SEL <= MULT_UNSIGNED;
		INPUT1 <= std_logic_vector(to_unsigned(65536, WIDTH));
		INPUT2 <= std_logic_vector(to_unsigned(131072, WIDTH));
		wait for 10 ns;
		assert(RESULT_Hi&RESULT = "0000000000000000000000000000001000000000000000000000000000000000") report "MULT_UNSIGNED RESULT & RESULT_Hi incorrect" severity failure;
		assert(BRANCH = '0') report "MULT_UNSIGNED BRANCH incorrect" severity failure;

		SEL <= AND_OP;
		INPUT1 <= std_logic_vector(to_unsigned(65535, WIDTH));
		INPUT2 <= "11111111111111110001001000110100";  
		wait for 10 ns;
		assert(RESULT = std_logic_vector(to_unsigned(4660, WIDTH))) report "AND_OP RESULT incorrect" severity failure;
		assert(RESULT_Hi = std_logic_vector(to_unsigned(0,WIDTH))) report "AND_OP RESULT_Hi incorrect" severity failure;
		assert(BRANCH = '0') report "AND_OP BRANCH incorrect" severity failure;

		SEL <= SHR_L;
		SHIFT_N <= std_logic_vector(to_unsigned(4,5));
		INPUT2 <= std_logic_vector(to_unsigned(15, WIDTH));
		wait for 10 ns;
		assert(RESULT = std_logic_vector(SHIFT_RIGHT(to_unsigned(15, WIDTH),4))) report "SHR_L RESULT incorrect" severity failure;
		assert(RESULT_Hi = std_logic_vector(to_unsigned(0, WIDTH))) report "SHR_L RESULT_Hi incorrect" severity failure;
		assert(BRANCH = '0') report "SHR_L BRANCH incorrect" severity failure;

		SEL <= SHR_A;
		SHIFT_N <= std_logic_vector(to_unsigned(1,5));
		INPUT2 <=  "11110000000000000000000000001000";                            
		wait for 10 ns;  
		assert(RESULT = "11111000000000000000000000000100") report "SHR_A RESULT incorrect" severity failure;
		assert(RESULT_Hi = std_logic_vector(to_unsigned(0, WIDTH))) report "SHR_A RESULT_Hi incorrect" severity failure;
		assert(BRANCH = '0') report "SHR_A BRANCH incorrect" severity failure;
		
		SEL <= SHR_A;
		SHIFT_N <= std_logic_vector(to_unsigned(1,5));
		INPUT2 <= std_logic_vector(to_unsigned(8, WIDTH));
		wait for 10 ns;
		assert(RESULT = std_logic_vector(SHIFT_RIGHT(to_signed(8, WIDTH), 1))) report "SHR_A RESULT incorrect" severity failure;
		assert(RESULT_Hi = std_logic_vector(to_unsigned(0, WIDTH))) report "SHR_A RESULT_Hi incorrect" severity failure;
		assert(BRANCH = '0') report "SHR_A BRANCH incorrect" severity failure;

		SEL <= SLT_SIGNED;
		INPUT1 <= std_logic_vector(to_unsigned(10, WIDTH));
		INPUT2 <= std_logic_vector(to_unsigned(15, WIDTH));
		wait for 10 ns;
		assert(RESULT = std_logic_vector(to_signed(1, WIDTH))) report "SLT_SIGNED RESULT incorrect" severity failure;
		assert(RESULT_Hi = std_logic_vector(to_signed(0, WIDTH))) report "SLT_SIGNED RESULT_Hi incorrect" severity failure;
		assert(BRANCH = '0') report "SLT_SIGNED BRANCH incorrect" severity failure;
		
		SEL <= SLT_SIGNED;
		INPUT1 <= std_logic_vector(to_unsigned(15, WIDTH));
		INPUT2 <= std_logic_vector(to_unsigned(10, WIDTH));
		wait for 10 ns;
		assert(RESULT = std_logic_vector(to_signed(0, WIDTH))) report "SLT_SIGNED RESULT incorrect" severity failure;
		assert(RESULT_Hi = std_logic_vector(to_signed(0, WIDTH))) report "SLT_SIGNED RESULT_Hi incorrect" severity failure;
		assert(BRANCH = '0') report "SLT_SIGNED BRANCH incorrect" severity failure;

		SEL <= B_LT_EQ;
		INPUT1 <= std_logic_vector(to_unsigned(5, WIDTH));
		wait for 10 ns;
		assert(BRANCH = '0') report "B_LT_EQ BRANCH incorrect" severity failure;
		assert(RESULT_Hi = std_logic_vector(to_unsigned(0, WIDTH))) report "B_LT_EQ RESULT_Hi incorrect" severity failure;
		assert(RESULT = std_logic_vector(to_unsigned(0, WIDTH))) report "B_LT_EQ RESULT incorrect" severity failure;

		SEL <= B_GT;
		INPUT1 <= std_logic_vector(to_unsigned(5, WIDTH));
		wait for 10 ns;
		assert(BRANCH = '1') report "B_GT BRANCH incorrect" severity failure;
		assert(RESULT_Hi = std_logic_vector(to_unsigned(0, WIDTH))) report "B_GT RESULT_Hi incorrect" severity failure;
		assert(RESULT = std_logic_vector(to_unsigned(0, WIDTH))) report "B_GT RESULT incorrect" severity failure;
		
		wait for 10 ns;
		
		report "ALL DONE YO";
		wait;
	end process;

end TB;