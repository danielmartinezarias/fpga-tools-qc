puts $new_file_sim "    -- bfm_${name_file}_tb.${suffix_file}: <brief description>"
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
puts $new_file_sim "        -- Project-specific packages"
puts $new_file_sim "    library $file_library_sim;"
puts $new_file_sim "    use $file_library_sim.const_pack_tb.all;"
puts $new_file_sim "    use $file_library_sim.gtypes_pack_tb.all;"
puts $new_file_sim "    use $file_library_sim.signals_pack_tb.all;"
puts $new_file_sim "    "
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
puts $new_file_sim "    entity bfm_${name_file}_tb is"
puts $new_file_sim "    generic ("
puts $new_file_sim "        "
puts $new_file_sim "    );"
puts $new_file_sim "    port ("
puts $new_file_sim "        -- Received data (valid on rising 'valid')"
puts $new_file_sim "        data : out std_logic_vector(7 downto 0);"
puts $new_file_sim ""
puts $new_file_sim "        -- Select tx or rx behaviour"
puts $new_file_sim "        rx : in std_logic"
puts $new_file_sim "        -- tx : in std_logic"
puts $new_file_sim "    );"
puts $new_file_sim "    end bfm_${name_file}_tb;"
puts $new_file_sim ""
puts $new_file_sim "    architecture beh of bfm_${name_file}_tb is"
puts $new_file_sim ""
puts $new_file_sim "    begin"
puts $new_file_sim ""
puts $new_file_sim "        proc_rx : process"
puts $new_file_sim "            variable tmp : std_logic_vector(7 downto 0);"
puts $new_file_sim ""
puts $new_file_sim "        begin"
puts $new_file_sim "            wait until falling_edge(rx);"
puts $new_file_sim ""
puts $new_file_sim "            -- Wait until the middle of the first bit"
puts $new_file_sim "            wait for symbol_duration * 1.5;"
puts $new_file_sim ""
puts $new_file_sim "            -- Sample all bits"
puts $new_file_sim "            for i in 0 to 7 loop"
puts $new_file_sim "                tmp(i) := rx;"
puts $new_file_sim "                wait for symbol_duration;"
puts $new_file_sim "            end loop;"
puts $new_file_sim ""
puts $new_file_sim "            -- Check the stop bit"
puts $new_file_sim "            assert rx = '1'"
puts $new_file_sim "                report \"Stop bit should be '1'\""
puts $new_file_sim "                severity failure;"
puts $new_file_sim "            "
puts $new_file_sim "            data <= tmp;"
puts $new_file_sim "            -- This is not needed because of the 'transaction attribute in the main uart_tb file"
puts $new_file_sim "            -- valid <= true;"
puts $new_file_sim "            -- wait for 0 ns;"
puts $new_file_sim "            -- valid <= false;"
puts $new_file_sim "        end process;"
puts $new_file_sim ""
puts -nonewline $new_file_sim "    end architecture;"