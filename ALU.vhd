library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.ALU_LIB.all;

entity alu is
    generic (
        WIDTH : positive := 32
    );
    port (
        INPUT1     : in std_logic_vector(WIDTH-1 downto 0);
        INPUT2     : in std_logic_vector(WIDTH-1 downto 0);
        SHIFT_N   : in std_logic_vector(4 downto 0);
        SEL   		 : in std_logic_vector(SEL_SIZE-1 downto 0);
        RESULT     : out std_logic_vector(WIDTH-1 downto 0);
        RESULT_Hi   : out std_logic_vector(WIDTH-1 downto 0);
        BRANCH     : out std_logic
    );
end alu;

architecture BHV of alu is 
begin
    process(INPUT1, INPUT2, SHIFT_N, SEL)
        variable TEMP_MULT : std_logic_vector(WIDTH*2-1 downto 0);
    begin
        BRANCH <= '0';
        RESULT_Hi <= (others => '0');
        case SEL is
            when ADD_UNSIGNED => --add unsigned
                RESULT <= std_logic_vector(unsigned(INPUT1) + unsigned(INPUT2));

            when SUB_UNSIGNED => --subtract unsigned
                RESULT <= std_logic_vector(unsigned(INPUT1) - unsigned(INPUT2));

            when MULT_SIGNED => --multiply signed
                TEMP_MULT := std_logic_vector(signed(INPUT1) * signed(INPUT2));
                RESULT <= TEMP_MULT(width-1 downto 0);
                RESULT_Hi <= TEMP_MULT(width*2-1 downto width);

            when MULT_UNSIGNED => --multiply unsigned
                TEMP_MULT := std_logic_vector(unsigned(INPUT1) * unsigned(INPUT2));
                RESULT <= TEMP_MULT(width-1 downto 0);
                RESULT_Hi <= TEMP_MULT(width*2-1 downto width);

            when AND_OP => --and operation
                RESULT <= INPUT1 and INPUT2;

            when SHR_L => --shift right logical
                RESULT <= std_logic_vector(SHIFT_RIGHT(unsigned(INPUT2), to_integer(unsigned(SHIFT_N))));

            when SHR_A => --shift right arithmetic
                RESULT <= std_logic_vector(SHIFT_RIGHT(signed(INPUT2), to_integer(unsigned(SHIFT_N))));

            when SLT_SIGNED => --set less than, unsigned
                if (signed(INPUT1) < signed(INPUT2)) then
                    RESULT <= std_logic_vector(to_unsigned(1, WIDTH));
                else
                    RESULT <= (others => '0');
                end if;

            when B_LT_EQ => --branch if less than or equal to 0
                if (signed(INPUT1) <= 0) then
                  BRANCH <= '1';
                else
                  BRANCH <= '0';
                end if;
                RESULT <= (others => '0');

            when B_GT => --branch if greater than 0
                if (signed(INPUT1) > 0) then
                  BRANCH <= '1';
                else
                  BRANCH <= '0';
                end if;
                RESULT <= (others => '0');

            when OR_OP     => --or
                Result <= INPUT1 or INPUT2;

            when XOR_OP    => --xor
                Result <= INPUT1 xor INPUT2;

            when SHL  => --shift left
                RESULT <= std_logic_vector(SHIFT_LEFT(unsigned(INPUT2), to_integer(unsigned(SHIFT_N))));

            when SLT_UNSIGNED  => --set less than unsigned
                if (unsigned(INPUT1) < unsigned(INPUT2)) then
                    RESULT <= std_logic_vector(to_unsigned(1, width));
                else
                    RESULT <= (others => '0');
                end if;

            when B_EQ => --branch if equal to
                if (signed(INPUT1) = signed(INPUT2)) then
                    BRANCH <= '1';
                else
                    BRANCH <= '0';
                end if;
                RESULT <= (others => '0');

            when B_NE => --branch if not equal to
                if (signed(INPUT1) = signed(INPUT2)) then
                    BRANCH <= '0';
                else
                    BRANCH <= '1';
                end if;
                RESULT <= (others => '0');
            
            when B_LT => --branch if less than 0
                if (signed(INPUT1) < 0) then
                    BRANCH <= '1';
                else
                    BRANCH <= '0';
                end if;
                RESULT <= (others => '0');
                
            when B_GT_EQ   => --branch if greater than or equal to 0
                if (signed(INPUT1) >= 0) then
                    Branch <= '1';
                else
                    Branch <= '0';
                end if;
                Result <= (others => '0');
        
            when others => --for undefined operations
                RESULT <= (others => '0');

        end case;
    end process;
end BHV;
