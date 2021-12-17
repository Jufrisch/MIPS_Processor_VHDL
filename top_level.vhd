
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.ALU_LIB.all;

entity top_level is
  port (
    clk      : in  std_logic;
	switch   : in  std_logic_vector(9 downto 0);
    button   : in  std_logic_vector(1 downto 0);
	led0     : out std_logic_vector(6 downto 0);
    led0_dp  : out std_logic;
    led1     : out std_logic_vector(6 downto 0);
    led1_dp  : out std_logic;
    led2     : out std_logic_vector(6 downto 0);
    led2_dp  : out std_logic;
    led3     : out std_logic_vector(6 downto 0);
    led3_dp  : out std_logic;
    led4     : out std_logic_vector(6 downto 0);
    led4_dp  : out std_logic;
    led5     : out std_logic_vector(6 downto 0);
    led5_dp  : out std_logic);
	 
end top_level;

architecture STR of top_level is
--Signals--
signal rst : std_logic;
signal InPort       :   std_logic_vector(31 downto 0); 
signal PC_Wr_Cond   :   std_logic;
signal PC_WR        :   std_logic; 
signal IorD         :   std_logic; 
signal MemRead      :   std_logic; 
signal MemWrite     :   std_logic;
signal MemToReg     :   std_logic_vector(1 downto 0);
signal IR_WR        :   std_logic; 
signal JumpAndLink  :   std_logic;
signal IsSigned     :   std_logic; 
signal PCSource     :   std_logic_vector(1 downto 0); 
signal OpSelect     :   std_logic_vector(4 downto 0);
signal ALUSrcA      :   std_logic; 
signal ALUSrcB      :   std_logic_vector(1 downto 0);
signal RegWrite     :   std_logic; 
signal RegDst       :   std_logic; 
signal ALU_LO_HI    :   std_logic_vector(1 downto 0); 
signal LO_en        :   std_logic; 
signal HI_en        :   std_logic; 
signal IR31downto26 :   std_logic_vector(5 downto 0); 
signal IR5downto0   :   std_logic_vector(5 downto 0); 
signal IR20downto16 :   std_logic_vector(4 downto 0); 
signal Inport1En    :   std_logic;
signal Inport0En    :   std_logic;
signal OutPort      :   std_logic_vector(31 downto 0);


begin

rst <= not button(1);

Inport1En 	<= (not Button(0)) and switch(9);
Inport0En 	<= not Button(0) and not switch(9);

Inport(31 downto 9) <= (others => '0');
Inport(8 downto 0) <= switch(8 downto 0);

U_Controller: entity work.controller

port map (
    clk          => clk,
    rst          => rst,
    PC_Wr_Cond   => PC_Wr_Cond,
    PC_WR        => PC_WR,
    IorD         => IorD,
    MemRead      => MemRead,
    MemWrite     => MemWrite,
    MemToReg     => MemToReg,
    IR_WR        => IR_WR,
    JumpAndLink  => JumpAndLink,
    IsSigned     => IsSigned,
    PCSource     => PCSource,
    OpSelect     => OpSelect,
    ALUSrcA      => ALUSrcA,
    ALUSrcB      => ALUSrcB,
    RegWrite     => RegWrite,
    RegDst       => RegDst,
    ALU_LO_HI    => ALU_LO_HI,
    LO_en        => LO_en,
    HI_en        => HI_en,
    IR31downto26 => IR31downto26,
    IR5downto0   => IR5downto0,
    IR20downto16 => IR20downto16
    );
    
U_datapath : entity work.datapath 

port map (
    clk          => clk,
    rst          => rst,
    InPort       => Inport,
    PC_Wr_Cond   => PC_Wr_Cond,
    PC_WR      => PC_WR,
    IorD         => IorD,
    MemRead      => MemRead,
    MemWrite     => MemWrite,
    MemToReg     => MemToReg,
    IR_WR        => IR_WR,
    JumpAndLink  => JumpAndLink,
    IsSigned     => IsSigned,
    PCSource     => PCSource,
    OpSelect     => OpSelect,
    ALUSrcA      => ALUSrcA,
    ALUSrcB      => ALUSrcB,
    RegWrite     => RegWrite,
    RegDst       => RegDst,
    ALU_LO_HI    => ALU_LO_HI,
    LO_en        => LO_en,
    HI_en        => HI_en,
    IR31downto26 => IR31downto26,
    IR5downto0   => IR5downto0,
    IR20downto16 => IR20downto16,
    Inport1En    => Inport1En,
    Inport0En    => Inport0En,
    OutPort      => OutPort
 );

U_LED0 : entity work.decoder7seg 
 port map (
     input  => OutPort(3 downto 0),
     output => led0
     );

U_LED1 : entity work.decoder7seg 
 port map (
     input  => OutPort(7 downto 4),
     output => led1
     );

U_LED2 : entity work.decoder7seg 
 port map (
     input  => OutPort(11 downto 8),
     output => led2
     );

U_LED3 : entity work.decoder7seg 
 port map (
     input  => OutPort(15 downto 12),
     output => led3
     );

U_LED4 : entity work.decoder7seg 
 port map (
     input  => OutPort(19 downto 16),
     output => led4
     );

U_LED5 : entity work.decoder7seg 
 port map (
     input  => OutPort(23 downto 20),
     output => led5
     );
     

led5_dp <= '1';
led4_dp <= '1';
led3_dp <= '1';
led2_dp <= '1';
led1_dp <= Button(1);
led0_dp <= Button(0);


end STR;
