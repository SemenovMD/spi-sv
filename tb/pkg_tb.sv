package pkg_tb;

    parameter   AXI_DATA_WIDTH  =   32;
    parameter   AXI_ADDR_WIDTH  =   32;
    parameter   CLOCK           =   100_000_000;
    parameter   SPI_CLOCK       =   5_000_000;

    parameter   CLK_PERIOD_NS   =   1_000_000_000 / CLOCK;

    parameter   AXI_TRAN_MIN_DELAY = 50;
    parameter   AXI_TRAN_MAX_DELAY = 100;

    class AXI_Lite_Master_Write;
        virtual axil_if m_axil_if;
        
        function new(virtual axil_if m_axil_if);
            this.m_axil_if = m_axil_if;
        endfunction

        task run();
            forever
            begin
                repeat ($urandom_range(AXI_TRAN_MIN_DELAY, AXI_TRAN_MAX_DELAY)) @(posedge m_axil_if.aclk);
                
                @(posedge m_axil_if.aclk);
                m_axil_if.awaddr = $random;
                m_axil_if.awvalid = 1;
                
                m_axil_if.wdata = $random;
                m_axil_if.wstrb = 4'b1111;
                m_axil_if.wvalid = 1;

                wait(m_axil_if.awready && m_axil_if.wready);

                @(posedge m_axil_if.aclk);
                m_axil_if.awaddr = '0;
                m_axil_if.awvalid = 0;

                m_axil_if.wdata = '0;
                m_axil_if.wstrb = '0;
                m_axil_if.wvalid = 0;
                m_axil_if.bready = 1;

                wait(m_axil_if.bvalid);

                @(posedge m_axil_if.aclk);
                m_axil_if.bready = 0;
            end
        endtask
    endclass

    class AXI_Lite_Master_Read;
        virtual axil_if m_axil_if;
        
        function new(virtual axil_if m_axil_if);
            this.m_axil_if = m_axil_if;
        endfunction

        task run();
            forever
            begin
                repeat ($urandom_range(AXI_TRAN_MIN_DELAY, AXI_TRAN_MAX_DELAY)) @(posedge m_axil_if.aclk);
                
                @(posedge m_axil_if.aclk);
                m_axil_if.araddr = $random;
                m_axil_if.arvalid = 1;

                wait(m_axil_if.arready);

                @(posedge m_axil_if.aclk);
                m_axil_if.araddr = '0;
                m_axil_if.arvalid = 0;
                m_axil_if.rready = 1;

                wait(m_axil_if.rvalid);

                @(posedge m_axil_if.aclk);
                m_axil_if.rready = 0;
            end
        endtask
    endclass

endpackage