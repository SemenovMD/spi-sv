`timescale 1ns / 1ps

module axil_spi_master_tb;

    import pkg_tb ::*;

    axil_if #(.AXI_DATA_WIDTH(AXI_DATA_WIDTH), .AXI_ADDR_WIDTH(AXI_ADDR_WIDTH)) m_axil();

    logic                           aclk;
    logic                           aresetn;

    logic                           spi_cs;
    logic                           spi_sclk;
    logic                           spi_mosi;
    logic                           spi_miso;

    axil_spi_master #
    (
        .AXI_DATA_WIDTH(AXI_DATA_WIDTH),
        .AXI_ADDR_WIDTH(AXI_ADDR_WIDTH),
        .CLOCK(CLOCK),
        .SPI_CLOCK(SPI_CLOCK)
    )
    axil_spi_master_inst
    (
        .aclk(aclk),
        .aresetn(aresetn),
        .spi_cs(spi_cs),
        .spi_sclk(spi_sclk),
        .spi_mosi(spi_mosi),
        .spi_miso(spi_miso),
        .s_axil(m_axil)
    );

    // Instantiate the AXI Lite Master classes
    AXI_Lite_Master_Write master_write_inst = new(m_axil);
    AXI_Lite_Master_Read master_read_inst = new(m_axil);

    assign m_axil.aclk = aclk;
    assign m_axil.aresetn = aresetn;

    initial
    begin
        aclk = 0;
        forever #(CLK_PERIOD_NS/2) aclk = ~aclk;
    end

    initial 
    begin
        aresetn = 0;
        #(10*CLK_PERIOD_NS/2) aresetn = 1; 
    end

    initial
    begin
        forever
        begin
            @(negedge spi_sclk)
            spi_miso = $random;
        end
    end

    initial
    begin
        spi_miso        = 1;

        m_axil.awaddr   = '0;
        m_axil.awvalid  = 0;
        m_axil.wdata    = '0;
        m_axil.wstrb    = '0;
        m_axil.wvalid   = 0;
        m_axil.bready   = 0;

        m_axil.araddr   = '0;
        m_axil.arvalid  = 0;
        m_axil.rready   = 0;
    end 

    initial 
    begin
        fork
            master_write_inst.run();
            master_read_inst.run();
        join
    end

endmodule