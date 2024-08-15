module axil_spi_master_wrapper_v

#(
    parameter   AXI_DATA_WIDTH  = 32,
    parameter   AXI_ADDR_WIDTH  = 32,
    parameter   CLOCK           = 100_000_000,
    parameter   SPI_CLOCK       = 5_000_000
)

(
    // Global Signals
    input   wire                                aclk,
    input   wire                                aresetn,

    // Interface SPI Master
    output  wire                                spi_cs,
    output  wire                                spi_sclk,
    output  wire                                spi_mosi,
    input   wire                                spi_miso,
    
    // Interface AXI-Lite Slave
    input   wire   [AXI_ADDR_WIDTH-1:0]         s_axil_awaddr,
    input   wire                                s_axil_awvalid,
    output  wire                                s_axil_awready,

    input   wire   [AXI_DATA_WIDTH-1:0]         s_axil_wdata,
    input   wire   [AXI_DATA_WIDTH/8-1:0]       s_axil_wstrb,
    input   wire                                s_axil_wvalid,
    output  wire                                s_axil_wready,

    output  wire   [1:0]                        s_axil_bresp,
    output  wire                                s_axil_bvalid,
    input   wire                                s_axil_bready,

    input   wire   [AXI_ADDR_WIDTH-1:0]         s_axil_araddr,
    input   wire                                s_axil_arvalid,
    output  wire                                s_axil_arready,

    output  wire   [AXI_DATA_WIDTH-1:0]         s_axil_rdata,
    output  wire   [1:0]                        s_axil_rresp,
    output  wire                                s_axil_rvalid,
    input   wire                                s_axil_rready
);
    
    axil_spi_master_wrapper_sv #(
        .AXI_DATA_WIDTH(AXI_DATA_WIDTH),
        .AXI_ADDR_WIDTH(AXI_ADDR_WIDTH),    
        .CLOCK(CLOCK),
        .SPI_CLOCK(SPI_CLOCK)
    )
    
    axil_spi_master_wrapper_sv_inst
    
    (
        .aclk(aclk),
        .aresetn(aresetn),
        .spi_cs(spi_cs),
        .spi_sclk(spi_sclk),
        .spi_mosi(spi_mosi),
        .spi_miso(spi_miso),
        .s_axil_awaddr(s_axil_awaddr),
        .s_axil_awvalid(s_axil_awvalid),
        .s_axil_awready(s_axil_awready),
        .s_axil_wdata(s_axil_wdata),
        .s_axil_wstrb(s_axil_wstrb),
        .s_axil_wvalid(s_axil_wvalid),
        .s_axil_wready(s_axil_wready),
        .s_axil_bresp(s_axil_bresp),
        .s_axil_bvalid(s_axil_bvalid),
        .s_axil_bready(s_axil_bready),
        .s_axil_araddr(s_axil_araddr),
        .s_axil_arvalid(s_axil_arvalid),
        .s_axil_arready(s_axil_arready),
        .s_axil_rdata(s_axil_rdata),
        .s_axil_rresp(s_axil_rresp),
        .s_axil_rvalid(s_axil_rvalid),
        .s_axil_rready(s_axil_rready)
    );

endmodule