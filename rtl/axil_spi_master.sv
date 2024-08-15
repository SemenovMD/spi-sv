module axil_spi_master

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
    axil_if.s_axil                              s_axil
);

    localparam COUNT_SPEED = CLOCK/SPI_CLOCK;

    logic           [7:0]                       spi_reg_addr_wr;
    logic           [7:0]                       spi_reg_data_wr;
    logic           [7:0]                       spi_reg_addr_rd;
    logic           [7:0]                       spi_reg_data_rd;

    logic                                       spi_tran_wr;
    logic                                       spi_tran_rd;

    logic                                       spi_flag_wr;
    logic                                       spi_flag_rd;

    logic           [$clog2(COUNT_SPEED)-1:0]   spi_count_speed;
    logic           [2:0]                       spi_count_bit;

    // FSM WRITE
    typedef enum logic [1:0]
    {  
        IDLE_WR,
        RESP_WR,
        HAND_WR,
        TRAN_WR_SPI
    } state_type_wr;

    state_type_wr state_wr;

    always_ff @(posedge aclk)
    begin
        if (!aresetn)
        begin
            state_wr <= IDLE_WR;
            s_axil.awready <= 0;
            s_axil.wready <= 0;
            s_axil.bvalid <= 0;
            s_axil.bresp <= 2'b00;
            spi_reg_addr_wr <= '0;
            spi_reg_data_wr <= '0;
            spi_tran_wr <= 0;
        end else 
        begin
            case (state_wr)
                IDLE_WR:
                    begin
                        case ({s_axil.awvalid, s_axil.wvalid})
                            2'b11:
                                begin
                                    state_wr <= RESP_WR;
                                    s_axil.awready <= 1;
                                    s_axil.wready <= 1;
                                    spi_reg_addr_wr <= s_axil.awaddr[7:0];
                                    spi_reg_data_wr <= s_axil.wdata[7:0];
                                end
                            default:
                                begin
                                    state_wr <= IDLE_WR;
                                end
                        endcase
                    end
                RESP_WR:
                    begin
                        state_wr <= HAND_WR;
                        s_axil.awready <= 0;
                        s_axil.wready <= 0;
                        s_axil.bvalid <= 1;
                        s_axil.bresp <= 2'b00;
                    end
                HAND_WR:
                    begin
                        if (!s_axil.bready)
                        begin
                            state_wr <= HAND_WR;
                        end else
                        begin
                            state_wr <= TRAN_WR_SPI;
                            s_axil.bvalid <= 0;
                            s_axil.bresp <= 2'b00;
                            spi_tran_wr <= 1;
                        end
                    end
                TRAN_WR_SPI:
                    begin
                        if (!spi_flag_wr)
                        begin
                            state_wr <= TRAN_WR_SPI;
                        end else
                        begin
                            state_wr <= IDLE_WR;
                            spi_reg_addr_wr <= '0;
                            spi_reg_data_wr <= '0;
                            spi_tran_wr <= 0;
                        end
                    end
            endcase 
        end
    end

    // FSM READ
    typedef enum logic [1:0]
    {  
        IDLE_RD,
        TRAN_RD_SPI,
        RESP_RD,
        HAND_RD
    } state_type_rd;

    state_type_rd state_rd;

    always_ff @(posedge aclk)
    begin
        if (!aresetn)
        begin
            state_rd <= IDLE_RD;
            s_axil.arready <= 0;
            s_axil.rdata <= '0;
            s_axil.rresp <= 2'b00;
            s_axil.rvalid <= 0;
            spi_reg_addr_rd <= '0;
            spi_tran_rd <= 0;
        end else 
        begin
            case (state_rd)
                IDLE_RD:
                    begin
                        if (!s_axil.arvalid)
                        begin
                            state_rd <= IDLE_RD;
                        end else
                        begin
                            state_rd <= TRAN_RD_SPI;
                            s_axil.arready <= 1;
                            spi_reg_addr_rd <= s_axil.araddr[7:0];
                            spi_tran_rd <= 1;
                        end
                    end
                TRAN_RD_SPI:
                    begin
                        if (!spi_flag_rd)
                        begin
                            state_rd <= TRAN_RD_SPI;
                        end else
                        begin
                            state_rd <= RESP_RD;
                            spi_reg_addr_rd <= '0;
                            spi_tran_rd <= 0;
                        end

                        s_axil.arready <= 0;
                    end
                RESP_RD:
                    begin
                        state_rd <= HAND_RD;
                        s_axil.rdata[7:0] <= spi_reg_data_rd;
                        s_axil.rresp <= 2'b00;
                        s_axil.rvalid <= 1;
                    end
                HAND_RD:
                    begin
                        if (!s_axil.rready)
                        begin
                            state_rd <= HAND_RD;
                        end else
                        begin
                            state_rd <= IDLE_RD;
                            s_axil.rdata <= '0;
                            s_axil.rresp <= 2'b00;
                            s_axil.rvalid <= 0;
                        end
                    end
            endcase 
        end
    end

    // FSM SPI
    typedef enum logic [2:0]
    {  
        IDLE_SPI,
        DELAY_SPI_1,
        ADDR_WR_SPI,
        DATA_WR_SPI,
        ADDR_RD_SPI,
        DATA_RD_SPI,
        DELAY_SPI_2,
        PAUSE_SPI
    } state_type_spi;

    state_type_spi state_spi;

    always_ff @(posedge aclk)
    begin
        if (!aresetn)
        begin
            state_spi <= IDLE_SPI;
            spi_count_speed <= '0;
            spi_count_bit <= '0;
            spi_reg_data_rd <= '0;
            spi_flag_wr <= 0;
            spi_flag_rd <= 0;
        end else
        begin
            case (state_spi)
                IDLE_SPI:
                    begin
                        if (!(spi_tran_wr || spi_tran_rd))
                        begin
                            state_spi <= IDLE_SPI;
                        end else
                        begin
                            state_spi <= DELAY_SPI_1;
                        end
                    end
                DELAY_SPI_1:
                    begin
                        if (spi_count_speed < COUNT_SPEED - 1)
                        begin
                            state_spi <= DELAY_SPI_1;
                            spi_count_speed <= spi_count_speed + 1;
                        end else
                        begin
                            case ({spi_tran_wr, spi_tran_rd})
                                2'b00: state_spi <= IDLE_SPI;
                                2'b01: state_spi <= ADDR_RD_SPI;
                                2'b10: state_spi <= ADDR_WR_SPI;
                                2'b11: state_spi <= ADDR_RD_SPI;
                            endcase

                            spi_count_speed <= '0;
                        end
                    end
                ADDR_WR_SPI:
                    begin
                        if (!((spi_count_speed == COUNT_SPEED - 1) && (spi_count_bit == 8 - 1)))
                        begin
                            if (spi_count_speed < COUNT_SPEED - 1)
                            begin
                                state_spi <= ADDR_WR_SPI;
                                spi_count_speed <= spi_count_speed + 1;
                            end else
                            begin
                                state_spi <= ADDR_WR_SPI;
                                spi_count_speed <= '0;
                                spi_count_bit <= spi_count_bit + 1;
                            end
                        end else
                        begin
                            state_spi <= DATA_WR_SPI;
                            spi_count_speed <= '0;
                            spi_count_bit <= '0;
                        end
                    end
                DATA_WR_SPI:
                    begin
                        if (!((spi_count_speed == COUNT_SPEED - 1) && (spi_count_bit == 8 - 1)))
                        begin
                            if (spi_count_speed < COUNT_SPEED - 1)
                            begin
                                state_spi <= DATA_WR_SPI;
                                spi_count_speed <= spi_count_speed + 1;
                            end else
                            begin
                                state_spi <= DATA_WR_SPI;
                                spi_count_speed <= '0;
                                spi_count_bit <= spi_count_bit + 1;
                            end
                        end else
                        begin
                            state_spi <= DELAY_SPI_2;
                            spi_count_speed <= '0;
                            spi_count_bit <= '0;
                            spi_flag_wr <= 1;
                        end
                    end
                ADDR_RD_SPI:
                    begin
                        if (!((spi_count_speed == COUNT_SPEED - 1) && (spi_count_bit == 8 - 1)))
                        begin
                            if (spi_count_speed < COUNT_SPEED - 1)
                            begin
                                state_spi <= ADDR_RD_SPI;
                                spi_count_speed <= spi_count_speed + 1;
                            end else
                            begin
                                state_spi <= ADDR_RD_SPI;
                                spi_count_speed <= '0;
                                spi_count_bit <= spi_count_bit + 1;
                            end
                        end else
                        begin
                            state_spi <= DATA_RD_SPI;
                            spi_count_speed <= '0;
                            spi_count_bit <= '0;
                        end
                    end
                DATA_RD_SPI:
                    begin
                        if (!((spi_count_speed == COUNT_SPEED - 1) && (spi_count_bit == 8 - 1)))
                        begin
                            if (spi_count_speed < COUNT_SPEED - 1)
                            begin
                                state_spi <= DATA_RD_SPI;
                                spi_count_speed <= spi_count_speed + 1;
                            end else
                            begin
                                state_spi <= DATA_RD_SPI;
                                spi_count_speed <= '0;
                                spi_count_bit <= spi_count_bit + 1;
                            end
                        end else
                        begin
                            state_spi <= DELAY_SPI_2;
                            spi_count_speed <= '0;
                            spi_count_bit <= '0;
                            spi_flag_rd <= 1;
                        end

                        if (spi_count_speed == (COUNT_SPEED/2 - 1))
                        begin
                            case (spi_count_bit)
                                0: spi_reg_data_rd[7] <= spi_miso;
                                1: spi_reg_data_rd[6] <= spi_miso;
                                2: spi_reg_data_rd[5] <= spi_miso;
                                3: spi_reg_data_rd[4] <= spi_miso;
                                4: spi_reg_data_rd[3] <= spi_miso;
                                5: spi_reg_data_rd[2] <= spi_miso;
                                6: spi_reg_data_rd[1] <= spi_miso;
                                7: spi_reg_data_rd[0] <= spi_miso;
                            endcase
                        end else
                        begin
                            spi_reg_data_rd <= spi_reg_data_rd;
                        end
                    end
                DELAY_SPI_2:
                    begin
                        if (spi_count_speed < COUNT_SPEED - 1)
                        begin
                            state_spi <= DELAY_SPI_2;
                            spi_count_speed <= spi_count_speed + 1;
                        end else
                        begin
                            state_spi <= PAUSE_SPI;
                            spi_count_speed <= '0;
                        end

                        spi_flag_wr <= 0;
                        spi_flag_rd <= 0;
                    end
                PAUSE_SPI:
                    begin
                        if (spi_count_speed < COUNT_SPEED - 1)
                        begin
                            state_spi <= PAUSE_SPI;
                            spi_count_speed <= spi_count_speed + 1;
                        end else
                        begin
                            state_spi <= IDLE_SPI;
                            spi_count_speed <= '0;
                        end
                    end
            endcase
        end
    end

    always_comb
    begin
        case (state_spi)
            IDLE_SPI, PAUSE_SPI:
                begin
                    spi_cs = 1'b1;
                    spi_sclk = 1'b1;
                    spi_mosi = 1'b1;
                end
            DELAY_SPI_1, DELAY_SPI_2:
                begin
                    spi_cs = 1'b0;
                    spi_sclk = 1'b1;
                    spi_mosi = 1'b1;
                end
            ADDR_WR_SPI:
                begin
                    spi_cs = 1'b0;
                    spi_sclk = (spi_count_speed < COUNT_SPEED/2) ? 1'b0 : 1'b1;
                    spi_mosi = spi_reg_addr_wr[7 - spi_count_bit];
                end
            DATA_WR_SPI:
                begin
                    spi_cs = 1'b0;
                    spi_sclk = (spi_count_speed < COUNT_SPEED/2) ? 1'b0 : 1'b1;
                    spi_mosi = spi_reg_data_wr[7 - spi_count_bit];
                end
            ADDR_RD_SPI:
                begin
                    spi_cs = 1'b0;
                    spi_sclk = (spi_count_speed < COUNT_SPEED/2) ? 1'b0 : 1'b1;
                    spi_mosi = spi_reg_addr_rd[7 - spi_count_bit];
                end
            DATA_RD_SPI:
                begin
                    spi_cs = 1'b0;
                    spi_sclk = (spi_count_speed < COUNT_SPEED/2) ? 1'b0 : 1'b1;
                    spi_mosi = 1'b1;
                end
        endcase
    end

endmodule