/*
 * sfr.sv
 *
 *  Created on: 27.12.2017
 *      Author: Alexander Antonov <antonov.alex.alex@gmail.com>
 *     License: See LICENSE file for details
 */ 

`include "sigma_tile.svh"

module sfr
#(
	parameter corenum=0
	, parameter SW_RESET_DEFAULT=0
	, parameter IRQ_NUM_POW=4
)
(
	input [0:0] clk_i
	, input [0:0] rst_i
	, MemSplit32.Slave host

	, output logic sw_reset_o

	, output logic [(2**IRQ_NUM_POW)-1:0] irq_en_bo
	, output logic irq_timer

	, output logic sgi_req_o
	, output logic [IRQ_NUM_POW-1:0] sgi_code_bo
);

localparam IDCODE_ADDR 			= 8'h00;
localparam CTRL_ADDR 			= 8'h04;
localparam CORENUM_ADDR 		= 8'h08;

localparam IRQ_EN_ADDR 			= 8'h10;
localparam SGI_ADDR 			= 8'h14;

localparam TIMER_CTRL_ADDR 		= 8'h20;
localparam TIMER_PERIOD_ADDR 	= 8'h24;

localparam ENB_MONITOR          = 8'h2c;
localparam COUNT                = 8'h3c;
localparam CLR                  = 8'h4c;
//localparam CLR_RAM              = 8'h3c;

localparam SFR_RAM_ADDR = 32'h00100050;

logic sw_reset, sw_reset_autocl,sw_reset_autoclr;
logic testmem_host_dly, testmem_host, csr_host;
always @(posedge clk_i) sw_reset_o <= rst_i | sw_reset;

logic timer_inprogress, timer_reload;
logic [31:0] timer_period;
logic [31:0] timer_value;

wire [31:0] host_addr;
wire [31:0] host_wdata;
wire [0:0] host_we;

reg testmem_host_we, testmem_host2_we = 0;
reg [127:0] testmem_host_addr, testmem_host_wdata;
reg [127:0] testmem_host2_addr, testmem_host2_wdata = 0;
wire [127:0] testmem_host_rdata, testmem_host2_rdata;
reg [31:0] i = 0;
reg [1:0] j;

reg [127:0] buf1 = 0;
reg [0:0] flag = 0;
reg [0:0] flag_wr = 0; //флаг вкл/откл мониторинга
reg [0:0] flag_clr = 0;//флаг очистки
//logic [31:0] flagR; 


wire testmem_host_enb;
assign testmem_host_enb = (!(host.addr < SFR_RAM_ADDR) && (host.addr < (SFR_RAM_ADDR + (1024*16))));


ram_dual #(
    .mem_init("NO")
    , .mem_data("nodata_out.hex")
    , .dat_width(128)
    , .adr_width(20)
    , .mem_size(1024)
) mem (
    .clk(clk_i)

    , .dat0_i(testmem_host_wdata)
    , .adr0_i(testmem_host_addr)
    , .we0_i(testmem_host_we)
    , .dat0_o(testmem_host_rdata)

    , .dat1_i(testmem_host2_wdata)
    , .adr1_i({32'h0, testmem_host2_addr})
    , .we1_i(testmem_host2_we)
    , .dat1_o(testmem_host2_rdata)
);





always @(posedge clk_i)
	begin	
	
	if (rst_i)
		begin
		host.resp <= 1'b0;
		sw_reset <= SW_RESET_DEFAULT;
		sw_reset_autoclr <= 1'b0;
		irq_en_bo <= 0;
		irq_timer <= 1'b0;
		sgi_req_o <= 0;
		sgi_code_bo <= 0;
		timer_inprogress <= 1'b0;
		timer_reload <= 1'b0;
		timer_period <= 0;
		timer_value <= 0;
		end
	else
		begin
		testmem_host_we <= 1'b0;
	    testmem_host_dly <= 1'b0;
        testmem_host <= testmem_host_dly;
		
		host.resp <= 1'b0;
		testmem_host_we <= 1'b0;
		sgi_req_o <= 0;
		irq_timer <= 1'b0;

		if (sw_reset && sw_reset_autoclr) sw_reset <= 1'b0;

		if (sw_reset_o)
			begin
			timer_inprogress <= 1'b0;
			timer_reload <= 1'b0;
			irq_timer <= 1'b0;
			timer_period <= 0;
			timer_value <= 0;
			end

		if (timer_inprogress)
			begin
			if (timer_value == timer_period)
				begin
				timer_inprogress <= timer_reload;
				irq_timer <= 1'b1;
				timer_value <= 0;
				end
			else timer_value <= timer_value + 1;
			end

		if (host.req)
			begin			
			if (host.we)
				begin			
				if (host.addr[7:0] == CTRL_ADDR)
					begin
					sw_reset <= host.wdata[0];
					sw_reset_autoclr <= host.wdata[1];
					end
				if (host.addr[7:0] == IRQ_EN_ADDR)
					begin
					irq_en_bo <= host.wdata;
					end
				if (host.addr[7:0] == SGI_ADDR)
					begin
					sgi_req_o <= 1;
					sgi_code_bo <= host.wdata;
					end
				if (host.addr[7:0] == TIMER_CTRL_ADDR)
					begin
					timer_value <= 0;
					timer_inprogress <= host.wdata[0];
					timer_reload <= host.wdata[1];
					end			
					
				if (host.addr[7:0] == TIMER_PERIOD_ADDR)
					begin
					timer_period <= host.wdata;
					end
					
				if (host.addr[7:0] == CLR)//очистка
					begin
					   i <= 0;				
					end
					
					//запись транзакций
					if (flag_wr == 1)
					begin
                        testmem_host_we <= 1'b1;
                        testmem_host_addr <= i;
                        testmem_host_wdata <= {{32'b0},{31'b0, host.we}, host.addr, host.wdata};
                        i <= i + 1;
                    end
                    
                    if (host.addr[7:0] == ENB_MONITOR)//вкл/выкл мониторинга
					begin
					   if (host.wdata == 32'h1)
					       flag_wr <= 1;
					   else
					       flag_wr <= 0;
					end
					
					if (host.addr[7:0] == COUNT)//вывод количества записанных транзакций
					begin
					   testmem_host_we <= 1'b1;			  
					   testmem_host_wdata <= i;
					end					
                    
				end
			else
				begin
                    host.resp <= 1'b1;
                    //reading
                    if (host.addr[7:0] == IDCODE_ADDR)
                    begin
                        host.rdata <= 32'hdeadbeef;
                        if (flag_wr == 1)
                        begin
                            buf1 <= {host.addr, 32'hdeadbeef};
                            flag <= 1;
                        end
                    end
                    
                    if (host.addr[7:0] == CTRL_ADDR)    		
                    begin 
                        host.rdata <= {31'h0, sw_reset};
                        if (flag_wr == 1)
                        begin
                            buf1 <= {host.addr, 31'h0, sw_reset};
                            flag <= 1;
                        end
                    end
                    
                    if (host.addr[7:0] == CORENUM_ADDR) 		
                    begin
                        host.rdata <= corenum;
                        if (flag_wr == 1)
                        begin                      
                            buf1 <= {host.addr,corenum};
                            flag <= 1;
                        end
                    end
                    
                    if (host.addr[7:0] == IRQ_EN_ADDR) 			
                    begin		
                        host.rdata <= irq_en_bo;
                        if (flag_wr == 1)
                        begin
                            buf1 <= {host.addr, {irq_en_bo}};
                            flag <= 1;
                        end
                    end
                    
                    if (host.addr[7:0] == TIMER_CTRL_ADDR) 		
                    begin
                        host.rdata <= {30'h0, timer_reload, timer_inprogress};
                        if (flag_wr == 1)
                        begin                   
                            buf1 <= {host.addr, 30'h0, timer_reload, timer_inprogress};
                            flag <= 1;
                        end
                    end
                    
                    if (host.addr[7:0] == TIMER_PERIOD_ADDR) 	
                    begin 
                        host.rdata <= timer_period;
                        if (flag_wr == 1)
                        begin
                            buf1 <= {host.addr, timer_period};
                            flag <= 1; 
                        end
                    end	
                    
                   if (testmem_host_enb)
                    begin
                        testmem_host2_we <= 1'b0;
                        testmem_host2_addr <= host.addr[7:4]-5;     // 4-byte aligned access only                        
                        testmem_host_dly <= 1'b1;
                        j <= host.addr[3:2];
                    end                       
                end
            end
        end      
	end
	
	always @*
	begin
	   if (flag == 1)
	   begin
	   // запись в память журнала
           testmem_host_we <= 1'b1;
           testmem_host_addr <= i;
           testmem_host_wdata <= {32'b0, buf1};
           i <= i + 1;
           flag <= 0;
       end        
   end
   
   always @*
	begin
	 if (testmem_host)
       begin  
           host.resp = testmem_host;      
           host.rdata = (testmem_host2_rdata >> (j*32));
         
       end          
   end

assign host.ack = host.req;

endmodule
