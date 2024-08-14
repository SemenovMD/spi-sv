module axil_spi_master_wrapper_sv

    import axil_pkg ::*;

(
    input   logic                               aclk,
    input   logic                               aresetn,

    // SPI Master
    output  logic                               spi_cs,
    output  logic                               spi_sclk,
    output  logic                               spi_mosi,
    input   logic                               spi_miso,
    
    // AXI-Lite Slave
    axil_if.s_axil                              s_axil
);

    axil_spi_master axil_spi_master_inst

    (
        .*
    );

endmodule