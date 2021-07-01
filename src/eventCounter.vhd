library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity eventCounter is
    port(
        clk,rst,B : in std_logic;
        C: out std_logic_vector(15 downto 0)
    );
end eventCounter;

architecture HLSM of eventCounter is
    type StateType is (S_init,S_one,S_zero,S_damp1,S_damp0);
    signal currState,nextState: stateType;
    signal currCnt,nextCnt: std_logic_vector(15 downto 0);
begin
    regs: process(clk,rst)
    begin
        if(rst='1') then
            currState<=S_init;
            currCnt<=(others=>'0');
        elsif (rising_edge(clk)) then
            currState<=nextState;
            currCnt<=nextCnt;
        end if;
    end process regs;
    
    C<=currCnt;
    
    comb: process(currState,B,currCnt)
    begin
        case currState is
            when S_init=> nextCnt<=(others=>'0');
                          if(B='1') then
                            nextState<=S_one;
                          else
                            nextState<=S_zero;
                          end if;
            when S_one=> nextCnt<=std_logic_vector(unsigned(currCnt)+1);
                          if(B='1') then
                            nextState<=S_damp1;
                          else
                            nextState<=S_zero;
                          end if;
            when S_zero=> nextCnt<=std_logic_vector(unsigned(currCnt)+1);
                          if(B='1') then
                            nextState<=S_one;
                          else
                            nextState<=S_damp0;
                          end if;
            when S_damp1=> nextCnt<=currCnt;
                          if(B='1') then
                            nextState<=S_damp1;
                          else
                            nextState<=S_zero;
                          end if;
            when S_damp0=> nextCnt<=currCnt;
                          if(B='1') then
                            nextState<=S_one;
                          else
                            nextState<=S_damp0;
                          end if;
            when others=> nextCnt<=(others=>'0'); nextState<=S_init;          
        end case;
    end process comb;

end HLSM;

architecture FSMD of eventCounter is
    -- shared ctrl
    signal cnt_sel: std_logic_vector(1 downto 0);
    --DP
    signal currCnt,nextCnt: std_logic_vector(15 downto 0);
    --FSM
    type StateType is (S_init,S_one,S_zero,S_damp1,S_damp0);
    signal currState,nextState: stateType;
    
begin

    -- DP
    
    DPregs: process(clk,rst)
    begin
        if(rst='1') then
            currCnt<=(others=>'0');
        elsif (rising_edge(clk)) then
            currCnt<=nextCnt;
        end if;
    end process DPregs;
    
    C<=currCnt;
    
    DPcomb: process(currCnt,cnt_sel)
    begin
        if(cnt_sel="00") then
            nextCnt<=(others=>'0');
        elsif (cnt_sel="01") then
            nextCnt<=currCnt;
        else
            nextCnt<=std_logic_vector(unsigned(currCnt)+1);
        end if;
    end process DPcomb;
    
    
    -- FSM
    
    FSMregs: process(clk,rst)
    begin
        if(rst='1') then
            currState<=S_init;
        elsif (rising_edge(clk)) then
            currState<=nextState;
        end if;
    end process FSMregs;
    
    FSMcomb: process(currState,B)
    begin
        case currState is
            when S_init=> cnt_sel<="00";
                          if(B='1') then
                            nextState<=S_one;
                          else
                            nextState<=S_zero;
                          end if;
            when S_one=> cnt_sel<="10";
                          if(B='1') then
                            nextState<=S_damp1;
                          else
                            nextState<=S_zero;
                          end if;
            when S_zero=> cnt_sel<="10";
                          if(B='1') then
                            nextState<=S_one;
                          else
                            nextState<=S_damp0;
                          end if;
            when S_damp1=> cnt_sel<="01";
                          if(B='1') then
                            nextState<=S_damp1;
                          else
                            nextState<=S_zero;
                          end if;
            when S_damp0=> cnt_sel<="01";
                          if(B='1') then
                            nextState<=S_one;
                          else
                            nextState<=S_damp0;
                          end if;
            when others=> cnt_sel<="00"; nextState<=S_init;          
        end case;
    end process FSMcomb;

end FSMD;
