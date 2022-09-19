# This file generates a template of a HDL simulation file (VHDL)

puts $new_file_sim ""
puts $new_file_sim "    -- ${name_file}_tb.${suffix_file}: Testbench for module ${name_file}.${suffix_file}"
puts $new_file_sim "    -- Engineer: $engineer_name"
puts $new_file_sim "    -- Email: $email_addr"
set clock_seconds [clock seconds]
set act_date [clock format $clock_seconds -format %D]
# puts $new_file_sim "    -- Created: $act_date"
puts $new_file_sim ""
puts $new_file_sim "    library ieee;"
puts $new_file_sim "    use ieee.std_logic_1164.all;"
puts $new_file_sim "    use ieee.numeric_std.all;"
puts $new_file_sim "    -- use ieee.math_real.all;"
puts $new_file_sim "    -- use ieee.math_complex.all;"
puts $new_file_sim ""
puts $new_file_sim "    use std.textio.all;"
puts $new_file_sim "    use std.env.finish;"
puts $new_file_sim ""
puts $new_file_sim "    -- Additional packages (sim)"
puts $new_file_sim "    library $file_library_sim;"
puts $new_file_sim "        -- Project-specific packages"
puts $new_file_sim "    use $file_library_sim.const_pack_tb.all;"
puts $new_file_sim "    use $file_library_sim.gtypes_pack_tb.all;"
puts $new_file_sim "    use $file_library_sim.signals_pack_tb.all;"
puts $new_file_sim ""
puts $new_file_sim "        -- Generic packages"
puts $new_file_sim "    use $file_library_sim.print_pack_tb.all;"
puts $new_file_sim "    use $file_library_sim.clk_pack_tb.all;"
puts $new_file_sim "    use $file_library_sim.list_string_pack_tb.all;"
puts $new_file_sim "    use $file_library_sim.print_list_pack_tb.all;"
puts $new_file_sim ""
puts $new_file_sim "    -- Additional project-specific packages (src)"
puts $new_file_sim "    library $file_library_src;"
puts $new_file_sim "    use $file_library_src.const_pack.all;"
puts $new_file_sim "    use $file_library_src.gtypes_pack.all;"
puts $new_file_sim "    use $file_library_src.signals_pack.all;"
puts $new_file_sim ""
puts $new_file_sim ""
puts $new_file_sim "    entity ${name_file}_tb is"
puts $new_file_sim "    end ${name_file}_tb;"
puts $new_file_sim ""
puts $new_file_sim "    architecture sim of ${name_file}_tb is"
puts $new_file_sim ""
puts $new_file_sim "        constant CLK_HZ : natural := 100e6;"
puts $new_file_sim "        constant CLK_PERIOD : time := 1 sec / CLK_HZ;"
puts $new_file_sim ""
puts $new_file_sim "        signal clk : std_logic := '1';"
puts $new_file_sim "        signal rst : std_logic := '1';"
puts $new_file_sim "        signal out_module : std_logic;"
puts $new_file_sim ""
puts $new_file_sim "    begin"
puts $new_file_sim ""
puts $new_file_sim "        -----------------------------------------------"
puts $new_file_sim "        -- Complex TB - remove if simple TB is required"
puts $new_file_sim "        -----------------------------------------------"
puts $new_file_sim ""
puts $new_file_sim "        -- Procedures such as checkers, assertions"
puts $new_file_sim "        inst_checkers_${name_file}_tb : entity lib_sim.checkers_${name_file}_tb(sim);"
puts $new_file_sim ""
puts $new_file_sim "        -- Procedures such as setting expected data, sending transactions"
puts $new_file_sim "        inst_executors_${name_file}_tb : entity lib_sim.executors_${name_file}_tb(sim);"
puts $new_file_sim ""
puts $new_file_sim "        -- All instances merged, includes all clocks and sim instances"
puts $new_file_sim "        inst_harness_${name_file}_tb : entity lib_sim.harness_${name_file}_tb(sim);"
puts $new_file_sim ""
puts $new_file_sim ""
puts $new_file_sim "        -- Main Sequencer"
puts $new_file_sim "        proc_sequencer : process"
puts $new_file_sim ""
puts $new_file_sim "            -- Overloaded Procedure 'run_executor_cmd': Subprogram linked to the record type rec_trig_cmd"
puts $new_file_sim "            procedure run_executor_cmd ("
puts $new_file_sim "                id : t_trig_cmd_id;"
puts $new_file_sim "                data : std_logic_vector(7 downto 0) := x\"00\""
puts $new_file_sim "            ) is begin"
puts $new_file_sim "                run_executor_cmd(exec_cmd, id, data);"
puts $new_file_sim "            end procedure;"
puts $new_file_sim ""
puts $new_file_sim "            -- Variables"
puts $new_file_sim "            variable tx_data : std_logic_vector(7 downto 0);"
puts $new_file_sim ""
puts $new_file_sim "        begin"
puts $new_file_sim ""
puts $new_file_sim "            -- 1. Reset DUT"
puts $new_file_sim "            run_executor_cmd(RESET_RELEASE);"
puts $new_file_sim ""
puts $new_file_sim "            -- 2. Loop over all the possible values"
puts $new_file_sim "            for i in 0 to 2**to_uart'length - 1 loop"
puts $new_file_sim ""
puts $new_file_sim "                -- 2.1 Prepare the TX byte"
puts $new_file_sim "                tx_data := std_logic_vector(to_unsigned(i, tx_bfm_data'length));"
puts $new_file_sim ""
puts $new_file_sim "                -- 2.2.1 UART_TX_BFM: if tx_bfm ready, send a byte over UART TX BFM (tx rate: 1/baud) to the DUT"
puts $new_file_sim "                run_executor_cmd(TX_TXBFM_TO_DUT, tx_data);"
puts $new_file_sim ""
puts $new_file_sim "                -- 2.2.2 Wait until the DUT outputs the entire decoded byte from UART_TX_BFM and asssert the value"
puts $new_file_sim "                run_executor_cmd(EXPECT_FROM_DUT, tx_data);"
puts $new_file_sim ""
puts $new_file_sim ""
puts $new_file_sim "                -- 2.3.1 Since DUT is now in idle state, ask the DUT to transmit a new byte FROM DUT to UART_RX_BFM"
puts $new_file_sim "                run_executor_cmd(TX_DUT_TO_RXBFM, tx_data);"
puts $new_file_sim ""
puts $new_file_sim "                -- 2.3.2 Wait until the UART_RX_BFM outputs the decoded byte and assert the value"
puts $new_file_sim "                run_executor_cmd(EXPECT_FROM_RXBFM, tx_data);"
puts $new_file_sim ""
puts $new_file_sim "            end loop;"
puts $new_file_sim ""
puts $new_file_sim "            -- Wait until at least 1 of the queues is empty, then print success"
puts $new_file_sim "            run_executor_cmd(WAIT_UNTIL_QUEUES_EMPTY);"
puts $new_file_sim ""
puts $new_file_sim "            print_success;"
puts $new_file_sim ""
puts $new_file_sim "            finish;"
puts $new_file_sim "            wait;"
puts $new_file_sim "        end process;"
puts $new_file_sim ""
puts $new_file_sim ""
puts $new_file_sim ""
puts $new_file_sim "        -----------------------------------------------"
puts $new_file_sim "        -- Simple TB - remove if complex TB is required"
puts $new_file_sim "        --     - no bfm"
puts $new_file_sim "        --     - no harness"
puts $new_file_sim "        --     - no checkers"
puts $new_file_sim "        --     - no executors"
puts $new_file_sim "        -----------------------------------------------"
puts $new_file_sim ""
puts $new_file_sim "        -- Clock Generator"
puts $new_file_sim "        gen_clk_freq_hz_int(clk, clk_hz);"
puts $new_file_sim ""
puts $new_file_sim "        -- DUT instantiation"
puts $new_file_sim "        inst_dut_${name_file} : entity ${file_library_src}.${name_file}($file_arch)"
puts $new_file_sim "        port map ("
puts $new_file_sim "            clk => clk,"
puts $new_file_sim "            rst => rst,"
puts $new_file_sim ""
puts $new_file_sim "            ${name_file}_rdy => ${name_file}_rdy,"
puts $new_file_sim "            ${name_file}_valid => ${name_file}_valid,"
puts $new_file_sim "            ${name_file}_ack => ${name_file}_ack,"
puts $new_file_sim "            out_port => out_port"
puts $new_file_sim "        );"
puts $new_file_sim ""
puts $new_file_sim "        -- Main Sequencer"
puts $new_file_sim "        proc_sequencer_simple : process"
puts $new_file_sim "        begin"
puts $new_file_sim ""
puts $new_file_sim "            -- Reset strobe"
puts $new_file_sim "            wait for CLK_PERIOD * 2;"
puts $new_file_sim ""
puts $new_file_sim "            -- Release reset"
puts $new_file_sim "            rst <= '0';"
puts $new_file_sim ""
puts $new_file_sim "            -- Run for 10 clock periods"
puts $new_file_sim "            wait for CLK_PERIOD * 10;"
puts $new_file_sim ""
puts $new_file_sim "            -- Assert signal value"
puts $new_file_sim "            assert false"
puts $new_file_sim "                report \"Replace this with your test cases\""
puts $new_file_sim "                severity failure;"
puts $new_file_sim ""
puts $new_file_sim "            -- Test OK"
puts $new_file_sim "            print_success;"
puts $new_file_sim ""
puts $new_file_sim "            -- ModelSim finish run keyword"
puts $new_file_sim "            finish;"
puts $new_file_sim "            wait;"
puts $new_file_sim "        end process;"
puts $new_file_sim ""
puts -nonewline $new_file_sim "    end architecture;"