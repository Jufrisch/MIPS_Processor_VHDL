library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.ALU_LIB.all;

entity datapath is
    port(
        clk          : in  std_logic;
        rst          : in  std_logic;
        InPort       : in  std_logic_vector(31 downto 0); 
        PC_Wr_Cond  : in  std_logic;
        PC_WR      : in  std_logic; 
        IorD         : in  std_logic; 
        MemRead      : in  std_logic; 
        MemWrite     : in  std_logic;
        MemToReg     : in  std_logic_vector(1 downto 0);
        IR_WR      : in  std_logic; 
        JumpAndLink  : in  std_logic;
        IsSigned     : in  std_logic; 
        PCSource     : in  std_logic_vector(1 downto 0); 
        OpSelect     : in  std_logic_vector(4 downto 0);
        ALUSrcA      : in  std_logic; 
        ALUSrcB      : in  std_logic_vector(1 downto 0);
        RegWrite     : in  std_logic; 
        RegDst       : in  std_logic; 
        ALU_LO_HI    : in  std_logic_vector(1 downto 0); 
        LO_en        : in  std_logic; 
        HI_en        : in  std_logic; 
        IR31downto26 : out std_logic_vector(5 downto 0); 
        IR5downto0   : out std_logic_vector(5 downto 0); 
        IR20downto16 : out  std_logic_vector(4 downto 0); 
        Inport1En   : in  std_logic;
        Inport0En   : in  std_logic;
        OutPort      : out std_logic_vector(31 downto 0)
    );
end datapath;

architecture STR of datapath is
    signal PC             : std_logic_vector(31 downto 0); 
    signal ALUOut         : std_logic_vector(31 downto 0); 
    signal ALU_out_reg      : std_logic_vector(31 downto 0);
    signal Memory_Address        : std_logic_vector(31 downto 0); 
    signal IR             : std_logic_vector(31 downto 0);
    signal WriteRegister  : std_logic_vector( 4 downto 0); 
    signal WriteData      : std_logic_vector(31 downto 0); 
    signal MemData_In        : std_logic_vector(31 downto 0);
    signal MemData_Out     : std_logic_vector(31 downto 0);
    signal MUX_ALU_OUT : std_logic_vector(31 downto 0);
    signal RegAIn         : std_logic_vector(31 downto 0); 
    signal RegBIn         : std_logic_vector(31 downto 0);
    signal RegAOut        : std_logic_vector(31 downto 0); 
    signal RegBOut        : std_logic_vector(31 downto 0);
    signal ALUInputA      : std_logic_vector(31 downto 0);
    signal ALUInputB      : std_logic_vector(31 downto 0);
    signal PCInput        : std_logic_vector(31 downto 0); 
    signal HI             : std_logic_vector(31 downto 0); 
    signal Hi_Reg          : std_logic_vector(31 downto 0);
    signal LO             : std_logic_vector(31 downto 0); 
    signal Lo_Reg          : std_logic_vector(31 downto 0);
    signal Branch         : std_logic; 
    signal sign_extended      : std_logic_vector(31 downto 0); 
    signal sign_extended_shift_left_2      : std_logic_vector(31 downto 0); 
    signal Shift_Left_2_Concat      : std_logic_vector(31 downto 0); 
    signal PC_en          : std_logic;
	 
begin
    U_PC: entity work.reg
        generic map (
            WIDTH => 32
        )
        port map (
            clk    => clk,
            rst    => rst,
            en     => PC_en,
            input  => PCInput,
            output => PC
        );

    PC_en <= ((Branch and PC_Wr_Cond) or PC_WR);

    U_MEMORY: entity work.memory
        port map (
            clk        => clk,
            rst        => rst,
            address    => Memory_Address,
            Rd_Data       => MemData_In,
            MemRead    => MemRead,
            MemWrite   => MemWrite,
            Inport1En => Inport1En,
            Inport0En => Inport0En,
            InPort     => InPort,
            OutPort    => OutPort,
            Wr_Data       => RegBOut
        );

    U_IR: entity work.reg
        generic map (
            WIDTH => 32
        )
        port map (
            clk    => clk,
            rst    => rst,
            en     => IR_WR,
            input  => MemData_In,
            output => IR
        );

    U_MEMORY_DATA: entity work.reg
        generic map (
            WIDTH => 32
        )
        port map (
            clk    => clk,
            rst    => rst,
            en     => '1',
            input  => MemData_In,
            output => MemData_Out
        );

    U_MUX_2x1_Memory: entity work.mux_2x1
        generic map (
            WIDTH => 32
        )
        port map(
            sel    => IorD,
            in0    => PC,
            in1    => ALU_out_reg,
            output => Memory_Address
        );

    U_MUX_2x1_RF_1: entity work.mux_2x1
        generic map (
            WIDTH => 5
        )
        port map(
            sel    => RegDst,
            in0    => IR(20 downto 16),
            in1    => IR(15 downto 11),
            output => WriteRegister
        );

    U_MUX_4x1_RF_1: entity work.mux_4x1
        generic map (
            WIDTH => 32
        )
        port map(
            sel    => MemToReg,
            in0    => MUX_ALU_OUT,
            in1    => MemData_Out,
            in2 => PC,
            in3 => std_logic_vector(to_unsigned(0,32)),
            output => WriteData
        );

    U_RF: entity work.reg_file
        port map (
            clk           => clk,
            rst           => rst,
            Rd_Reg1      => IR(25 downto 21),
            Rd_Reg2      => IR(20 downto 16),
            Rd_Data1     => RegAIn,
            Rd_Data2     => RegBIn,
            Wr_Reg => WriteRegister,
            Wr_Data     => WriteData,
            Wr_Reg_En      => RegWrite,
            JumpAndLink   => JumpAndLink
        );

    U_REG_A: entity work.reg
        generic map (
            WIDTH => 32
        )
        port map (
            clk    => clk,
            rst    => rst,
            en     => '1',
            input  => RegAIn,
            output => RegAOut
        );

    U_REG_B: entity work.reg
        generic map (
            WIDTH => 32
        )
        port map (
            clk    => clk,
            rst    => rst,
            en     => '1',
            input  => RegBIn,
            output => RegBOut
        );

    U_MUX_2x1_ALU_1: entity work.mux_2x1
        generic map (
            WIDTH => 32
        )
        port map(
            sel    => ALUSrcA,
            in0    => PC,
            in1    => RegAOut,
            output => ALUInputA
        );

    U_Sign_Extender: entity work.extender
        generic map (
            IN_WIDTH => 16,
            OUT_WIDTH => 32
        )
        port map (
            IsSigned => IsSigned,
            input    => IR(15 downto 0),
            output   => sign_extended
        );

    sign_extended_shift_left_2 <= std_logic_vector(SHIFT_LEFT(unsigned(sign_extended), 2));

    U_MUX_4x1_ALU_2: entity work.mux_4x1
        generic map (
            WIDTH => 32
        )
        port map(
            sel    => ALUSrcB,
            in0    => RegBOut,
            in1    => std_logic_vector(to_unsigned(4, 32)),
            in2    => sign_extended,
            in3    => sign_extended_shift_left_2,
            output => ALUInputB
        );

    U_ALU: entity work.alu
        generic map (
            WIDTH => 32
        )
        port map(
            Input1   => ALUInputA,
            Input2   => ALUInputB,
            SHIFT_N => IR(10 downto 6),
            SEL => OpSelect,
            Result   => ALUOut,
            RESULT_Hi => HI,
            Branch   => Branch
        );

    Shift_Left_2_Concat <= PC(31 downto 28) & IR(25 downto 0) & "00";

    U_MUX_Top_Right: entity work.mux_4x1
        generic map (
            WIDTH => 32
        )
        port map(
            sel    => PCSource,
            in0    => ALUOut,
            in1    => ALU_out_reg,
            in2    => Shift_Left_2_Concat,
            in3    => std_logic_vector(to_unsigned(0, 32)),
            output => PCInput
        );

    U_MUX_ALU_OUT: entity work.mux_4x1
        generic map (
            WIDTH => 32
        )
        port map(
            sel    => ALU_LO_HI,
            in0    => ALU_out_reg,
            in1    => Lo_Reg,
            in2    => Hi_Reg,
            in3    => std_logic_vector(to_unsigned(0, 32)),
            output => MUX_ALU_OUT
        );

    U_ALU_OUT_REGISTER: entity work.reg
        generic map (
            WIDTH => 32
        )
        port map (
            clk    => clk,
            rst    => rst,
            en     => '1',
            input  => ALUOut,
            output => ALU_out_reg
        );

    U_LO_REGISTER: entity work.reg
        generic map (
            WIDTH => 32
        )
        port map (
            clk    => clk,
            rst    => rst,
            en     => LO_en,
            input  => ALUOut,
            output => Lo_Reg
        );

    U_HI_REGISTER: entity work.reg
        generic map (
            WIDTH => 32
        )
        port map (
            clk    => clk,
            rst    => rst,
            en     => HI_en,
            input  => HI,
            output => Hi_Reg
        );

    IR31downto26 <= IR(31 downto 26);
    
    IR20downto16 <= IR(20 downto 16);

    IR5downto0 <= IR(5 downto 0);

end STR;