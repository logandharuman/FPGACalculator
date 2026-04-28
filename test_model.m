library ieee;
use ieee.std_logic_1164.all;

entity priority_arbiter is
    generic (
        DATA_WIDTH   : integer := 32;
        NUM_CHANNELS : integer := 4
    );
    port (
        clk       : in  std_logic;
        rst       : in  std_logic;
        in_valid  : in  std_logic_vector(NUM_CHANNELS-1 downto 0);
        in_data   : in  std_logic_vector(NUM_CHANNELS*DATA_WIDTH-1 downto 0);
        out_valid : out std_logic_vector(NUM_CHANNELS-1 downto 0);
        out_data  : out std_logic_vector(NUM_CHANNELS*DATA_WIDTH-1 downto 0)
    );
end entity priority_arbiter;

architecture rtl of priority_arbiter is

    type data_array_t is array (0 to NUM_CHANNELS-1) of std_logic_vector(DATA_WIDTH-1 downto 0);

    signal latch_data  : data_array_t;
    signal latch_valid : std_logic_vector(NUM_CHANNELS-1 downto 0);
    signal grant       : std_logic_vector(NUM_CHANNELS-1 downto 0);
    signal out_data_r  : data_array_t;
    signal out_valid_r : std_logic_vector(NUM_CHANNELS-1 downto 0);

begin

    -- Priority grant: combinatorial, index 0 = highest priority
    grant(0) <= latch_valid(0);
    grant(1) <= latch_valid(1) and not latch_valid(0);
    grant(2) <= latch_valid(2) and not latch_valid(1) and not latch_valid(0);
    grant(3) <= latch_valid(3) and not latch_valid(2) and not latch_valid(1) and not latch_valid(0);

    -- Latch input data and hold pending valid
    p_latch : process(clk)
    begin
        if rising_edge(clk) then
            if rst = '1' then
                latch_valid <= (others => '0');
                latch_data  <= (others => (others => '0'));
            else
                for i in 0 to NUM_CHANNELS-1 loop
                    if in_valid(i) = '1' then
                        latch_data(i)  <= in_data((i+1)*DATA_WIDTH-1 downto i*DATA_WIDTH);
                        latch_valid(i) <= '1';
                    elsif grant(i) = '1' then
                        latch_valid(i) <= '0';
                    end if;
                end loop;
            end if;
        end if;
    end process p_latch;

    -- Output register: 1-cycle delay after grant
    p_output : process(clk)
    begin
        if rising_edge(clk) then
            if rst = '1' then
                out_valid_r <= (others => '0');
                out_data_r  <= (others => (others => '0'));
            else
                out_valid_r <= (others => '0');
                for i in 0 to NUM_CHANNELS-1 loop
                    if grant(i) = '1' then
                        out_data_r(i)  <= latch_data(i);
                        out_valid_r(i) <= '1';
                    end if;
                end loop;
            end if;
        end if;
    end process p_output;

    -- Output assignments
    gen_out : for i in 0 to NUM_CHANNELS-1 generate
        out_data((i+1)*DATA_WIDTH-1 downto i*DATA_WIDTH) <= out_data_r(i);
    end generate gen_out;

    out_valid <= out_valid_r;

end architecture rtl;