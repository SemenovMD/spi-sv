# Enable transcript logging
transcript on

# Create the work library
vlib work

# Compile the packages
vlog -sv tb/pkg_tb.sv

# Compile the interfaces
vlog -sv rtl/axil_if.sv

# Compile the design and testbench
vlog -sv rtl/axil_spi_master.sv
vlog -sv tb/axil_spi_master_tb.sv

# Simulate the testbench
vsim -t 1ns -L altera_mf_ver -voptargs="+acc" axil_spi_master_tb

# Add signals to the waveform window
add wave -radix binary          axil_spi_master_tb/axil_spi_master_inst/aresetn
add wave -radix binary          axil_spi_master_tb/axil_spi_master_inst/aclk

add wave -radix binary          axil_spi_master_tb/axil_spi_master_inst/spi_cs
add wave -radix binary          axil_spi_master_tb/axil_spi_master_inst/spi_sclk
add wave -radix binary          axil_spi_master_tb/axil_spi_master_inst/spi_mosi
add wave -radix binary          axil_spi_master_tb/axil_spi_master_inst/spi_miso

add wave -radix hexadecimal 	axil_spi_master_tb/axil_spi_master_inst/s_axil/awaddr
add wave -radix binary 		    axil_spi_master_tb/axil_spi_master_inst/s_axil/awvalid
add wave -radix binary 		    axil_spi_master_tb/axil_spi_master_inst/s_axil/awready
add wave -radix hexadecimal     axil_spi_master_tb/axil_spi_master_inst/s_axil/wdata
add wave -radix hexadecimal     axil_spi_master_tb/axil_spi_master_inst/s_axil/wstrb
add wave -radix binary          axil_spi_master_tb/axil_spi_master_inst/s_axil/wvalid
add wave -radix binary          axil_spi_master_tb/axil_spi_master_inst/s_axil/wready
add wave -radix hexadecimal     axil_spi_master_tb/axil_spi_master_inst/s_axil/bresp
add wave -radix binary          axil_spi_master_tb/axil_spi_master_inst/s_axil/bvalid
add wave -radix binary          axil_spi_master_tb/axil_spi_master_inst/s_axil/bready

add wave -radix hexadecimal 	axil_spi_master_tb/axil_spi_master_inst/s_axil/araddr
add wave -radix binary 		    axil_spi_master_tb/axil_spi_master_inst/s_axil/arvalid
add wave -radix binary 		    axil_spi_master_tb/axil_spi_master_inst/s_axil/arready
add wave -radix hexadecimal     axil_spi_master_tb/axil_spi_master_inst/s_axil/rdata
add wave -radix binary          axil_spi_master_tb/axil_spi_master_inst/s_axil/rvalid
add wave -radix binary          axil_spi_master_tb/axil_spi_master_inst/s_axil/rready
add wave -radix hexadecimal     axil_spi_master_tb/axil_spi_master_inst/s_axil/rresp

# Run the simulation for the specified time
run 10ms

# Zoom out to show all waveform data
wave zoom full