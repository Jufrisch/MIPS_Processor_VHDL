library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.alu_lib.all;

entity reg_file is 
    port (
        clk           : in std_logic;
        rst           : in std_logic;
        Rd_Reg1      : in std_logic_vector(4 downto 0);
        Rd_Reg2      : in std_logic_vector(4 downto 0);
        Rd_Data1     : out std_logic_vector(31 downto 0);
        Rd_Data2     : out std_logic_vector(31 downto 0);
        Wr_Reg : in std_logic_vector(4 downto 0);
        Wr_Data     : in std_logic_vector(31 downto 0);
        Wr_Reg_En      : in std_logic; 
        JumpAndLink   : in std_logic 
    );
end reg_file;

architecture async_read of reg_file is
    type reg_array is array(0 to 31) of std_logic_vector(31 downto 0);
    signal regs : reg_array; 
begin 
    process (clk, rst) is
    begin 
        if (rst = '1') then
            for i in regs'range loop
                regs(i) <= (others => '0');
            end loop;
        elsif (rising_edge(clk)) then
            if (Wr_Reg_En = '1') then
                if (JumpAndLink = '1') then
                    regs(31) <= Wr_Data;
                else
                    regs(to_integer(unsigned(Wr_Reg))) <= Wr_Data;
                end if;
            end if;
        end if;
    end process;
    Rd_Data1 <= regs(to_integer(unsigned(Rd_Reg1)));
    Rd_Data2 <= regs(to_integer(unsigned(Rd_Reg2)));
end async_read;