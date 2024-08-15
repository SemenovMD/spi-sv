interface axil_if;

    parameter   AXI_DATA_WIDTH  = 32;
    parameter   AXI_ADDR_WIDTH  = 32;

    // Clock and Reset
    logic                               aclk;
    logic                               aresetn;

    // Channel Write Address
    logic   [AXI_ADDR_WIDTH-1:0]        awaddr;
    logic                               awvalid;
    logic                               awready;

    // Channel Write Data
    logic   [AXI_DATA_WIDTH-1:0]        wdata;
    logic   [AXI_DATA_WIDTH/8-1:0]      wstrb;
    logic                               wvalid;
    logic                               wready;

    // Channel Write Response
    logic   [1:0]                       bresp;
    logic                               bvalid;
    logic                               bready;
    
    // Channel Read Address
    logic   [AXI_ADDR_WIDTH-1:0]        araddr;
    logic                               arvalid;
    logic                               arready;

    // Channel Read Data
    logic   [AXI_DATA_WIDTH-1:0]        rdata;
    logic   [1:0]                       rresp;
    logic                               rvalid;
    logic                               rready;

    modport m_axil
    (
        output awaddr,
        output awvalid,
        input  awready,

        output wdata,
        output wstrb,
        output wvalid,
        input  wready,

        input  bresp,
        input  bvalid,
        output bready,

        output araddr,
        output arvalid,
        input  arready,

        input  rdata,
        input  rresp,
        input  rvalid,
        output rready
    );

    modport s_axil
    (
        input  awaddr,
        input  awvalid,
        output awready,

        input  wdata,
        input  wstrb,
        input  wvalid,
        output wready,

        output bresp,
        output bvalid,
        input  bready,

        input  araddr,
        input  arvalid,
        output arready,

        output rdata,
        output rresp,
        output rvalid,
        input  rready
    );

endinterface