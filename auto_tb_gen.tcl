# === SETTINGS ===
set top_entity [get_property top [current_fileset]]
set tb_name "${top_entity}_tb"
set tb_file "${tb_name}.vhd"

# === GET PORTS ===
set ports [get_ports]

# === OPEN FILE FOR WRITING ===
set fp [open $tb_file "w"]

# === HEADER ===
puts $fp "-- Auto-generated VHDL Testbench for entity: $top_entity"
puts $fp "library IEEE;"
puts $fp "use IEEE.STD_LOGIC_1164.ALL;"
puts $fp "use IEEE.NUMERIC_STD.ALL;"
puts $fp ""
puts $fp "entity $tb_name is"
puts $fp "end $tb_name;"
puts $fp ""
puts $fp "architecture behavior of $tb_name is"

# === SIGNAL DECLARATIONS ===
foreach port $ports {
    set name [get_property name $port]
    set dir [get_property direction $port]
    set datatype [get_property type $port]

    # Convert scalar std_logic to vector form
    if {[regexp -nocase {std_logic_vector} $datatype]} {
        set signal_type $datatype
    } else {
        set signal_type "std_logic"
    }

    puts $fp "    signal $name : $signal_type;"
}
puts $fp ""
puts $fp "begin"

# === DUT INSTANTIATION ===
puts $fp "    uut: entity work.$top_entity"
puts $fp "        port map ("
foreach port $ports {
    set name [get_property name $port]
    puts $fp "            $name => $name,"
}
# Remove trailing comma
seek $fp -3 current
puts $fp "\n        );"
puts $fp ""

# === CLOCK PROCESS (50 MHz) ===
# Add only if clk signal exists
set has_clk 0
foreach port $ports {
    set name [string tolower [get_property name $port]]
    if {[regexp {clk|clock} $name]} {
        set clk_sig [get_property name $port]
        set has_clk 1
        break
    }
}

if {$has_clk} {
    puts $fp "    -- 50 MHz Clock Generation"
    puts $fp "    clk_process : process"
    puts $fp "    begin"
    puts $fp "        $clk_sig <= '0';"
    puts $fp "        wait for 10 ns;"
    puts $fp "        $clk_sig <= '1';"
    puts $fp "        wait for 10 ns;"
    puts $fp "    end process;"
    puts $fp ""
}

# === STIMULUS PROCESS ===
puts $fp "    stim_proc: process"
puts $fp "    begin"
puts $fp "        -- Initialize Inputs"
foreach port $ports {
    set name [get_property name $port]
    set dir [get_property direction $port]
    if {$dir == "in"} {
        puts $fp "        $name <= '0';"
    }
}
puts $fp "        wait for 100 ns;"
puts $fp "        -- Add stimulus here"
puts $fp "        wait;"
puts $fp "    end process;"
puts $fp ""
puts $fp "end behavior;"

# === CLOSE FILE ===
close $fp

# === ADD TO PROJECT ===
add_files $tb_file
set_property top $tb_name [current_fileset -simset]

puts "✅ VHDL Testbench '$tb_file' created and added to simulation set."
