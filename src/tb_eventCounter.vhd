library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity tb_eventCounter is
end tb_eventCounter;

architecture Behavioral of tb_eventCounter is
    component eventCounter is
        port(
            clk,rst,B : in std_logic;
            C: out std_logic_vector(15 downto 0)
        );
    end component eventCounter;
    
    signal clk_s,rst_s,B_s: std_logic;
    signal C_s,CFSMD_s: std_logic_vector(15 downto 0);
    constant clkper: time := 10 ns;
    
    for HLSM: eventCounter use entity work.eventCounter(HLSM);
    for FSMD: eventCounter use entity work.eventCounter(FSMD);
    
begin
    
    HLSM: eventCounter port map(clk=>clk_s,rst=>rst_s,B=>B_s,C=>C_s);
    FSMD: eventCounter port map(clk=>clk_s,rst=>rst_s,B=>B_s,C=>CFSMD_s);
    
    process
    begin
        clk_s<='0';
        wait for clkper/2;
        clk_s<='1';
        wait for clkper/2;
    end process;
    
    process
    begin
        rst_s<='1';
        wait for clkper;
        rst_s<='0';
        B_s<='0';
        wait for clkper;
        B_s<='1';
        wait for clkper;
        B_s<='0';
        wait for clkper;
        B_s<='0';
        wait for clkper;
        B_s<='1';
        wait for clkper;
        B_s<='1';
        wait for clkper;
        B_s<='1';
        wait for clkper;
        B_s<='1';
        wait for clkper;
        B_s<='0';
        wait for clkper;
        B_s<='1';
        wait for clkper;
        B_s<='0';
        wait for clkper;
        B_s<='0';
        wait for clkper;
        wait;
    end process;

end Behavioral;
