    library ieee;
    use ieee.std_logic_1164.all;
    use ieee.numeric_std.all;

    library UNISIM;
    use UNISIM.VComponents.all;

    entity memristor_ctrl is
        generic (
            CTRL_DATA_WIDTH : positive := 3;
            CLK_SYS_HZ : natural := 100e6
        );
        port (
            -- Clocks
            clk0      : in  std_logic;
            clk1      : in  std_logic;
            clk2      : in  std_logic;
            clk3      : in  std_logic;
            clk4      : in  std_logic;
            clk5      : in  std_logic;
            sys_clk       : in  std_logic;

            -- Data in
            ctrl_data_in : std_logic_vector(CTRL_DATA_WIDTH-1 downto 0);

            -- Data out
            out_pulses : out std_logic
        );
    end memristor_ctrl;

    architecture rtl of memristor_ctrl is


        -- Data & valid pulse crossed from another domain
        signal sl_crossdomain_valid : std_logic := '0';
        signal slv_crossdomain_data_prev : std_logic_vector(CTRL_DATA_WIDTH-1 downto 0) := (others => '0');
        signal slv_crossdomain_data_new : std_logic_vector(CTRL_DATA_WIDTH-1 downto 0) := (others => '0');

        -- Add new clicks
        signal int_add_new_clicks : integer range 0 to 2*CTRL_DATA_WIDTH-1;

        -- Counter
        -- constant C_COUNTER_SECOND_MAXCOUNTS : natural := 1000000; -- TODO: Per second
        constant C_COUNTER_SECOND_MAXCOUNTS : natural := CLK_SYS_HZ;
        signal slv_lap_counter : integer range 0 to C_COUNTER_SECOND_MAXCOUNTS-1 := 0;
        signal int_clicks_total_lap : integer := 0;
        signal int_clicks_selector : integer := 0;
        signal sl_clicks_valid : std_logic := '0';


        constant C_NUM_OUTPUTS : natural := 5;
        signal slv_level_out : std_logic_vector(C_NUM_OUTPUTS-1 downto 0) := (others => '0');
        signal slv_level_trig : std_logic_vector(C_NUM_OUTPUTS-1 downto 0) := (others => '0');

        -- signal slv_level_selector : std_logic_vector(C_NUM_OUTPUTS-1 downto 0) := std_logic_vector(to_unsigned(1, C_NUM_OUTPUTS));



        -- Levels:
        constant C_COUNTER_LEVEL1 : natural := 500;
        constant C_COUNTER_LEVEL2 : natural := 1000;
        constant C_COUNTER_LEVEL3 : natural := 5000;
        constant C_COUNTER_LEVEL4 : natural := 9000;
        constant C_COUNTER_LEVEL5 : natural := 13000;
        -- constant C_COUNTER_LEVEL6 : natural := 15000;

    begin




        -- Determine the difference between two values
        -- 000 = 0
        -- 001 = 1
        -- 011 = 2
        -- 111 = 3
        -- 110 = 4
        -- 100 = 5
        proc_add_new_clicks : process(sys_clk)
        begin
            if falling_edge(sys_clk) then

                -- Default
                int_add_new_clicks <= 0;

                if sl_crossdomain_valid = '1' then
                    case slv_crossdomain_data_prev is
                        when "000" => -- 0
                            if slv_crossdomain_data_new = "001" then -- 1
                                int_add_new_clicks <= 1;

                            elsif slv_crossdomain_data_new = "011" then -- 2
                                int_add_new_clicks <= 2;

                            elsif slv_crossdomain_data_new = "111" then -- 3
                                int_add_new_clicks <= 3;

                            elsif slv_crossdomain_data_new = "110" then -- 4
                                int_add_new_clicks <= 4;

                            elsif slv_crossdomain_data_new = "100" then -- 5
                                int_add_new_clicks <= 5;
                            else
                                int_add_new_clicks <= 0;
                            end if;

                        when "001" => -- 1
                            if slv_crossdomain_data_new = "011" then -- 1
                                int_add_new_clicks <= 1;

                            elsif slv_crossdomain_data_new = "111" then -- 2
                                int_add_new_clicks <= 2;

                            elsif slv_crossdomain_data_new = "110" then -- 3
                                int_add_new_clicks <= 3;

                            elsif slv_crossdomain_data_new = "100" then -- 4
                                int_add_new_clicks <= 4;

                            elsif slv_crossdomain_data_new = "000" then -- 5
                                int_add_new_clicks <= 5;
                            else
                                int_add_new_clicks <= 0;
                            end if;

                        when "011" => -- 2
                            if slv_crossdomain_data_new = "111" then -- 1
                                int_add_new_clicks <= 1;

                            elsif slv_crossdomain_data_new = "110" then -- 2
                                int_add_new_clicks <= 2;

                            elsif slv_crossdomain_data_new = "100" then -- 3
                                int_add_new_clicks <= 3;

                            elsif slv_crossdomain_data_new = "000" then -- 4
                                int_add_new_clicks <= 4;

                            elsif slv_crossdomain_data_new = "100" then -- 5
                                int_add_new_clicks <= 5;
                            else
                                int_add_new_clicks <= 0;
                            end if;

                        when "111" => -- 3
                            if slv_crossdomain_data_new = "110" then -- 1
                                int_add_new_clicks <= 1;

                            elsif slv_crossdomain_data_new = "100" then -- 2
                                int_add_new_clicks <= 2;

                            elsif slv_crossdomain_data_new = "000" then -- 3
                                int_add_new_clicks <= 3;

                            elsif slv_crossdomain_data_new = "001" then -- 4
                                int_add_new_clicks <= 4;

                            elsif slv_crossdomain_data_new = "011" then -- 5
                                int_add_new_clicks <= 5;
                            else
                                int_add_new_clicks <= 0;
                            end if;

                        when "110" => -- 4
                            if slv_crossdomain_data_new = "100" then -- 1
                                int_add_new_clicks <= 1;

                            elsif slv_crossdomain_data_new = "000" then -- 2
                                int_add_new_clicks <= 2;

                            elsif slv_crossdomain_data_new = "001" then -- 3
                                int_add_new_clicks <= 3;

                            elsif slv_crossdomain_data_new = "011" then -- 4
                                int_add_new_clicks <= 4;

                            elsif slv_crossdomain_data_new = "111" then -- 5
                                int_add_new_clicks <= 5;
                            else
                                int_add_new_clicks <= 0;
                            end if;

                        when "100" => -- 5
                            if slv_crossdomain_data_new = "000" then -- 1
                                int_add_new_clicks <= 1;

                            elsif slv_crossdomain_data_new = "001" then -- 2
                                int_add_new_clicks <= 2;

                            elsif slv_crossdomain_data_new = "011" then -- 3
                                int_add_new_clicks <= 3;

                            elsif slv_crossdomain_data_new = "111" then -- 4
                                int_add_new_clicks <= 4;

                            elsif slv_crossdomain_data_new = "110" then -- 5
                                int_add_new_clicks <= 5;
                            else
                                int_add_new_clicks <= 0;
                            end if;

                        when others =>
                            int_add_new_clicks <= 0;
                    end case;
                    
                end if;
            end if;
        end process;



        -- Counting clicks per 1 lap (second)
        proc_fast_counter : process(sys_clk)
        begin
            if falling_edge(sys_clk) then

                slv_lap_counter <= slv_lap_counter + 1;
                int_clicks_total_lap <= int_clicks_total_lap + int_add_new_clicks;
                sl_clicks_valid <= '0';

                if slv_lap_counter = C_COUNTER_SECOND_MAXCOUNTS-1 then
                    slv_lap_counter <= 0;
                    int_clicks_total_lap <= 0;
                    int_clicks_selector <= int_clicks_total_lap;
                    sl_clicks_valid <= '1';
                end if;

            end if;
        end process;


        -- Controlling pulse selection
        proc_level_selector : process(sys_clk)
        begin
            if falling_edge(sys_clk) then

                slv_level_trig <= slv_level_trig;

                if sl_clicks_valid = '1' then

                    -- Level setting
                    if  int_clicks_selector <= C_COUNTER_LEVEL1 then
                        -- slv_level_trig <= "00001";
                        slv_level_trig <= std_logic_vector(to_unsigned(2**0, slv_level_trig'length));

                    elsif   int_clicks_selector <= C_COUNTER_LEVEL2
                        and int_clicks_selector >  C_COUNTER_LEVEL1 then
                        -- slv_level_trig <= "00010";
                        slv_level_trig <= std_logic_vector(to_unsigned(2**1, slv_level_trig'length));

                    elsif   int_clicks_selector <= C_COUNTER_LEVEL3
                        and int_clicks_selector >  C_COUNTER_LEVEL2 then
                        -- slv_level_trig <= "00100";
                        slv_level_trig <= std_logic_vector(to_unsigned(2**2, slv_level_trig'length));

                    elsif   int_clicks_selector <= C_COUNTER_LEVEL4
                        and int_clicks_selector >  C_COUNTER_LEVEL3 then
                        -- slv_level_trig <= "01000";
                        slv_level_trig <= std_logic_vector(to_unsigned(2**3, slv_level_trig'length));
                    
                    elsif   int_clicks_selector <= C_COUNTER_LEVEL5
                        and int_clicks_selector >  C_COUNTER_LEVEL4 then
                        -- slv_level_trig <= "10000";
                        slv_level_trig <= std_logic_vector(to_unsigned(2**4, slv_level_trig'length));

                    else
                        -- slv_level_trig <= "00000";
                        slv_level_trig <= std_logic_vector(to_unsigned(0, slv_level_trig'length));

                    end if;


                end if;
            end if;
        end process;



        -- 27%
        BUFGMUX_CTRL_inst_5_4 : BUFGMUX_CTRL
        port map (
            I0 => clk5,         -- 1-bit input: Clock input (S=0)
            I1 => clk4,         -- 1-bit input: Clock input (S=1)
            O => slv_level_out(4),     -- 1-bit output: Clock output
            S => slv_level_trig(4)      -- 1-bit input: Clock select
        );

        -- 22%
        BUFGMUX_CTRL_inst_3 : BUFGMUX_CTRL
        port map (
            I0 => clk4,         -- 1-bit input: Clock input (S=0)
            I1 => clk3,         -- 1-bit input: Clock input (S=1)
            O => slv_level_out(3),     -- 1-bit output: Clock output
            S => slv_level_trig(3)      -- 1-bit input: Clock select
        );

        -- 18%
        BUFGMUX_CTRL_inst_2 : BUFGMUX_CTRL
        port map (
            I0 => slv_level_out(3),         -- 1-bit input: Clock input (S=0)
            I1 => clk2,         -- 1-bit input: Clock input (S=1)
            O => slv_level_out(2),     -- 1-bit output: Clock output
            S => slv_level_trig(2)      -- 1-bit input: Clock select
        );

        -- 13%
        BUFGMUX_CTRL_inst_1 : BUFGMUX_CTRL
        port map (
            I0 => slv_level_out(2),         -- 1-bit input: Clock input (S=0)
            I1 => clk1,         -- 1-bit input: Clock input (S=1)
            O => slv_level_out(1),     -- 1-bit output: Clock output
            S => slv_level_trig(1)      -- 1-bit input: Clock select
        );

        -- 9%
        BUFGMUX_CTRL_inst_0 : BUFGMUX_CTRL
        port map (
            I0 => slv_level_out(1),         -- 1-bit input: Clock input (S=0)
            I1 => clk0,         -- 1-bit input: Clock input (S=1)
            O => slv_level_out(0),     -- 1-bit output: Clock output
            S => slv_level_trig(0)      -- 1-bit input: Clock select
        );

        out_pulses <= slv_level_out(0);

    end architecture;