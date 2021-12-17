library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.ALU_LIB.all;

entity controller is
    port (
        clk          : in std_logic;
        rst          : in std_logic;
        PC_Wr_Cond  : out std_logic;
        PC_WR      : out std_logic;
        IorD         : out std_logic;
        MemRead      : out std_logic;
        MemWrite     : out std_logic;
        MemToReg     : out std_logic_vector(1 downto 0);
        IR_WR      : out std_logic;
        JumpAndLink  : out std_logic;
        IsSigned     : out std_logic;
        PCSource     : out std_logic_vector(1 downto 0);
        OpSelect     : out std_logic_vector(SEL_SIZE-1 downto 0);
        ALUSrcA      : out std_logic;
        ALUSrcB      : out std_logic_vector(1 downto 0);
        RegWrite     : out std_logic;
        RegDst       : out std_logic;
        ALU_LO_HI    : out std_logic_vector(1 downto 0);
        LO_en        : out std_logic;
        HI_en        : out std_logic;
        IR31downto26 : in  std_logic_vector(5 downto 0);
        IR5downto0   : in  std_logic_vector(5 downto 0);
        IR20downto16 : in  std_logic_vector(4 downto 0)
    );
end controller;

architecture FSM of controller is

    type STATE_TYPE is (GET_INSTRUCTION, LOAD_IR, DECODE_INSTRUCTION,R_TYPE_HANDLR, I_TYPE_HANDLR,
                        R_TYPE_COMPLETION, I_TYPE_COMPLETION,
                        MEMORY_ADDRESS_COMPUTATION,
                        MEMORY_ACCESS_READ, LOAD_MEMORY_DATA_REG, MEMORY_READ_COMPLETION,
                        MEMORY_ACCESS_WRITE,
                        BRANCH_COMPLETION,
                        WRITE_RETURN_ADDR,
                        JUMP, JUMP_REGISTER,
                        HALT); 
    signal state, next_state : STATE_TYPE;

    signal IR5downto0_ext : unsigned(7 downto 0);
    signal IR31downto26_ext : unsigned(7 downto 0);

begin

    process(clk,rst)
    begin
        if (rst = '1') then
            state <= GET_INSTRUCTION;
        elsif (rising_edge(clk)) then
            state <= next_state;
        end if;
    end process;

    IR5downto0_ext <= resize(unsigned(IR5downto0),8);
    IR31downto26_ext <= resize(unsigned(IR31downto26),8);

    process(IR31downto26_ext, IR5downto0_ext, state) --When instructions or state changes, process starts
    begin
           --DEFAULTS--
        PC_Wr_Cond <= '0';
        PC_WR     <= '0';
        IorD        <= '0';
        MemRead     <= '0';
        MemWrite    <= '0';
        MemToReg    <= "00";
        IR_WR     <= '0';
        JumpAndLink <= '0';
        IsSigned    <= '0';
        PCSource    <= "00";
        OpSelect    <= (others => '0');
        ALUSrcB     <= "00";
        ALUSrcA     <= '0';
        RegWrite    <= '0';
        RegDst      <= '0';
        HI_en       <= '0'; 
        LO_en       <= '0';
        ALU_LO_HI   <= "00";
        
        next_state  <= state;

        case state is
            when GET_INSTRUCTION =>
                IorD <= '0';
                MemRead <= '1';
                ALUSrcA <= '0';
                ALUSrcB <= "01";
                OpSelect <= ADD_UNSIGNED; 
                PCSource <= "00";
                PC_WR <= '1';
                next_state <= LOAD_IR;

            when LOAD_IR => 
                IR_WR <= '1';
                next_state <= DECODE_INSTRUCTION;

            when DECODE_INSTRUCTION =>
                ALUSrcA <= '0';
                IsSigned <= '1';
                ALUSrcB <= "11";
                OPSelect <= ADD_UNSIGNED;
                if (IR31downto26_ext = x"00")
                    then next_state <= R_TYPE_HANDLR;
                elsif (IR31downto26_ext = x"09" or IR31downto26_ext = x"10" or
                        IR31downto26_ext = x"0C" or IR31downto26_ext = x"0D" or
                        IR31downto26_ext = x"0E" or IR31downto26_ext = x"0A" or
                        IR31downto26_ext = x"0B")
                    then next_state <= I_TYPE_HANDLR;
                elsif (IR31downto26_ext = x"23" or IR31downto26_ext = x"2B")
                    then next_state <= MEMORY_ADDRESS_COMPUTATION;
                elsif (IR31downto26_ext = x"04" or IR31downto26_ext = x"05" or
                        IR31downto26_ext = x"06" or IR31downto26_ext = x"07" or
                        IR31downto26_ext = x"01")
                    then next_state <= BRANCH_COMPLETION;
                elsif (IR31downto26_ext = x"02")
                    then next_state <= JUMP;
                elsif (IR31downto26_ext = x"03")
                    then next_state <= WRITE_RETURN_ADDR;
                elsif (IR31downto26_ext = x"3F")
                    then next_state <= HALT;
                end if;

            when R_TYPE_HANDLR =>
                ALUSrcA <= '1';
                ALUSrcB <= "00";
                next_state <= R_TYPE_COMPLETION;
                case IR5downto0_ext is
                    when x"21" => 
                        OpSelect <= ADD_UNSIGNED;
                    when x"23" => 
                        OpSelect <= SUB_UNSIGNED;
                    when x"18" =>
                        OpSelect <= MULT_SIGNED;
                        LO_en <= '1';
                        HI_en <= '1'; 
                    when x"19" => 
                        OpSelect <= MULT_UNSIGNED;
                        LO_en <= '1';
                        HI_en <= '1';
                    when x"24" => 
                        OpSelect <= AND_OP;
                    when x"25" => 
                        OpSelect <= OR_OP;
                    when x"26" => 
                        OpSelect <= XOR_OP; 
                    when x"02" =>
                        OpSelect <= SHR_L; 
                    when x"00" =>
                        OpSelect <= SHL;
                    when x"03" => 
                        OpSelect <= SHR_A;
                    when x"2A" => 
                        OpSelect <= SLT_SIGNED;
                    when x"2B" => 
                        OpSelect <= SLT_UNSIGNED;
                    when x"10" =>
                        ALU_LO_HI <= "10"; 
                        MemToReg <= "00";
                        RegDst <= '1';
                        RegWrite <= '1';
                        next_state <= GET_INSTRUCTION;
                    when x"12" =>
                        ALU_LO_HI <= "01";
                        MemToReg <= "00";
                        RegDst <= '1';
                        RegWrite <= '1';
                        next_state <= GET_INSTRUCTION;
                    when x"08" =>
                        next_state <= JUMP_REGISTER;
                    when others => report "R Type Broke." severity note;
                end case;
            when R_TYPE_COMPLETION =>

                ALU_LO_HI <= "00";
                MemToReg <= "00";
                RegDst <= '1';
                if IR5downto0_ext =  x"18" or IR5downto0_ext =  x"19" then
                RegWrite <= '0';
                else
                RegWrite <= '1';
                end if;
                next_state <= GET_INSTRUCTION;

            when I_TYPE_HANDLR =>
                ALUSrcA <= '1';
                ALUSrcB <= "10";
                next_state <= I_TYPE_COMPLETION;
                case IR31downto26_ext is
                    when x"09" => 
                        IsSigned <= '1';
                        OpSelect <= ADD_UNSIGNED;
                    when x"10" => 
                        IsSigned <= '1';
                        OpSelect <= SUB_UNSIGNED;
                    when x"0C" =>
                        IsSigned <= '0';
                        OpSelect <= AND_OP;
                    when x"0D" =>
                        IsSigned <= '0';
                        OpSelect <= OR_OP;
                    when x"0E" =>
                        IsSigned <= '0';
                        OpSelect <= XOR_OP;
                    when x"0A" =>
                        IsSigned <= '1';
                        OpSelect <= SLT_SIGNED;
                    when x"0B" =>
                        IsSigned <= '1';
                        OpSelect <= SLT_UNSIGNED;
                    when others =>
                        report "I Type Broke." severity note;
                        next_state <= GET_INSTRUCTION;
                end case;

            when I_TYPE_COMPLETION =>

                ALU_LO_HI <= "00";
                MemToReg <= "00";
                RegDst <= '0';
                RegWrite <= '1';
                next_state <= GET_INSTRUCTION;

            when MEMORY_ADDRESS_COMPUTATION => 

                ALUSrcA <= '1';
                IsSigned <= '0';
                ALUSrcB <= "10";
                OpSelect <= ADD_UNSIGNED;
                if (IR31downto26_ext = x"23") then next_state <= MEMORY_ACCESS_READ;
                elsif (IR31downto26_ext = x"2B") then next_state <= MEMORY_ACCESS_WRITE;
                else 
                    report "memory access broke" severity note;
                    next_state <= GET_INSTRUCTION;
                end if;
            when MEMORY_ACCESS_READ =>

                IorD <= '1';
                MemRead <= '1';
                next_state <= LOAD_MEMORY_DATA_REG;

            when LOAD_MEMORY_DATA_REG =>
                next_state <= MEMORY_READ_COMPLETION;

            when MEMORY_READ_COMPLETION =>
            
                RegDst <= '0';
                MemToReg <= "01";
                RegWrite <= '1';
                next_state <= GET_INSTRUCTION;

            when MEMORY_ACCESS_WRITE =>
                IorD <= '1';
                MemWrite <= '1';
                next_state <= GET_INSTRUCTION;

            when BRANCH_COMPLETION => 
                PC_Wr_Cond <= '1';
                next_state <= GET_INSTRUCTION;
                ALUSrcA <= '1';
                ALUSrcB <= "00";
                PCSource <= "01";

                case IR31downto26_ext is
                    when x"04" => 
                        OpSelect <= B_EQ;
                    when x"05" =>
                        OpSelect <= B_NE;
                    when x"06" => 
                        OpSelect <= B_LT_EQ;
                    when x"07" =>
                        OpSelect <= B_GT;
                    when x"01" =>
                        if (IR20downto16 = "00001") then
                            OpSelect <= B_GT_EQ;
                        elsif(IR20downto16 = "00000") then
                            OpSelect <= B_LT;
                        else report "Problem in Branch." severity note;
                        end if;
                    when others => report "branch broke." severity note;
                end case;

            when WRITE_RETURN_ADDR =>
                MemToReg <= "10";
                JumpAndLink <= '1';
                RegWrite <= '1';
                next_state <= JUMP;
            when JUMP =>
                PCSource <= "10"; 
                PC_WR <= '1';
                next_state <= GET_INSTRUCTION;
            when JUMP_REGISTER =>
                PCSource <= "11";
                PC_WR <= '1';
                next_state <= GET_INSTRUCTION;
            when HALT =>
                next_state <= state;
        end case;
    end process;
end FSM;