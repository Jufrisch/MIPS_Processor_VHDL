library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package ALU_LIB is

    constant SEL_SIZE           : integer := 5;
    constant ADD_UNSIGNED  		: std_logic_vector(4 downto 0) := "00000"; 
    constant SUB_UNSIGNED  		: std_logic_vector(4 downto 0) := "00001"; 
    constant MULT_SIGNED 		: std_logic_vector(4 downto 0) := "00010"; 
    constant MULT_UNSIGNED 		: std_logic_vector(4 downto 0) := "00011"; 
    constant AND_OP    	        : std_logic_vector(4 downto 0) := "00100";
    constant OR_OP     	        : std_logic_vector(4 downto 0) := "00101";
    constant XOR_OP    	        : std_logic_vector(4 downto 0) := "00110";
    constant SHR_L  		    : std_logic_vector(4 downto 0) := "00111";
    constant SHR_A  		    : std_logic_vector(4 downto 0) := "01000";
    constant SHL  		        : std_logic_vector(4 downto 0) := "01001";
    constant SLT_SIGNED  		: std_logic_vector(4 downto 0) := "01010";
    constant SLT_UNSIGNED  		: std_logic_vector(4 downto 0) := "01011";
    constant B_LT_EQ  	        : std_logic_vector(4 downto 0) := "01100"; 
    constant B_GT   	        : std_logic_vector(4 downto 0) := "01101"; 
    constant B_EQ    	        : std_logic_vector(4 downto 0) := "01110"; 
    constant B_NE    	        : std_logic_vector(4 downto 0) := "01111";
    constant B_LT    	        : std_logic_vector(4 downto 0) := "10000";
    constant B_GT_EQ   	        : std_logic_vector(4 downto 0) := "10001";

end ALU_LIB;