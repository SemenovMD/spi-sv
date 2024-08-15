module axil_spi_master_wrapper_sv

#(
    parameter   AXI_DATA_WIDTH  = 32,
    parameter   AXI_ADDR_WIDTH  = 32,
    parameter   CLOCK           = 100_000_000,
    parameter   SPI_CLOCK       = 5_000_000
)

(
    // Global Signals
    input   logic                               aclk,
    input   logic                               aresetn,

    // Interface SPI Master
    output  logic                               spi_cs,
    output  logic                               spi_sclk,
    output  logic                               spi_mosi,
    input   logic                               spi_miso,
    
    // Interface AXI-Lite Slave
    input   logic   [AXI_ADDR_WIDTH-1:0]        s_axil_awaddr,
    input   logic                               s_axil_awvalid,
    output  logic                               s_axil_awready,

    input   logic   [AXI_DATA_WIDTH-1:0]        s_axil_wdata,
    input   logic   [AXI_DATA_WIDTH/8-1:0]      s_axil_wstrb,
    input   logic                               s_axil_wvalid,
    output  logic                               s_axil_wready,

    output  logic   [1:0]                       s_axil_bresp,
    output  logic                               s_axil_bvalid,
    input   logic                               s_axil_bready,

    input   logic   [AXI_ADDR_WIDTH-1:0]        s_axil_araddr,
    input   logic                               s_axil_arvalid,
    output  logic                               s_axil_arready,

    output  logic   [AXI_DATA_WIDTH-1:0]        s_axil_rdata,
    output  logic   [1:0]                       s_axil_rresp,
    output  logic                               s_axil_rvalid,
    input   logic                               s_axil_rready
);

    axil_if #(.AXI_DATA_WIDTH(AXI_DATA_WIDTH), .AXI_ADDR_WIDTH(AXI_ADDR_WIDTH)) s_axil();

    generate
        assign s_axil.awaddr    = s_axil_awaddr;
        assign s_axil.awvalid   = s_axil_awvalid;
        assign s_axil_awready   = s_axil.awready;

        assign s_axil.wdata     = s_axil_wdata;
        assign s_axil.wstrb     = s_axil_wstrb;
        assign s_axil.wvalid    = s_axil_wvalid;
        assign s_axil_wready    = s_axil.wready;

        assign s_axil_bvalid    = s_axil.bresp;
        assign s_axil_bresp     = s_axil.bvalid;
        assign s_axil.bready    = s_axil_bready;

        assign s_axil.araddr    = s_axil_araddr;
        assign s_axil.arvalid   = s_axil_arvalid;
        assign s_axil_arready   = s_axil.arready;

        assign s_axil_rdata     = s_axil.rdata;
        assign s_axil_rvalid    = s_axil.rresp;
        assign s_axil_rresp     = s_axil.rvalid;
        assign s_axil.rready    = s_axil_rready;
    endgenerate
    
    axil_spi_master #
    (
        .AXI_DATA_WIDTH(AXI_DATA_WIDTH),
        .AXI_ADDR_WIDTH(AXI_ADDR_WIDTH),    
        .CLOCK(CLOCK),
        .SPI_CLOCK(SPI_CLOCK)
    )
    
    axil_spi_master_inst
    
    (
        .*
    );

endmodule