// SPDX-FileCopyrightText: 2020 Efabless Corporation
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
// SPDX-License-Identifier: Apache-2.0

`default_nettype none

`timescale 1 ns / 1 ps

module wb_e2e_tb;
    parameter DATA_WIDTH = 11;
    parameter LEAF_SIZE = 8;
    parameter PATCH_SIZE = 5;
    parameter ROW_SIZE = 32;
    parameter COL_SIZE = 16;
    parameter NUM_QUERYS = ROW_SIZE * COL_SIZE;
    parameter NUM_LEAVES = 64;
    parameter NUM_NODES = NUM_LEAVES - 1;
    parameter BLOCKING = 4;
    parameter ADDR_WIDTH = $clog2(NUM_LEAVES);

    reg clock;
    reg RSTB;
    reg CSB;
    reg power1, power2;
    reg power3, power4;

    wire gpio;
    wire [37:0] mprj_io;

    reg                                 io_clk;
    reg                                 io_rst_n;
    reg                                 fsm_start;
    wire                                load_done;
    wire                                fsm_done;
    wire                                send_done;
    reg                                 send_best_arr;
    reg                                 load_kdtree;
    reg                                 in_fifo_wenq;
    reg [10:0]                          in_fifo_wdata;
    wire                                in_fifo_wfull_n;
    reg                                 out_fifo_deq;
    wire [10:0]                         out_fifo_rdata;
    wire                                out_fifo_rempty_n;
    wire                                wbs_done;
    wire                                wbs_busy;
    wire                                wbs_cfg_done;


    assign mprj_io[0] = io_clk;
    assign mprj_io[1] = io_rst_n;
    assign mprj_io[2] = in_fifo_wenq;
    assign mprj_io[13:3] = in_fifo_wdata;
    assign in_fifo_wfull_n = mprj_io[14];
    assign mprj_io[15] = fsm_start;
    assign mprj_io[16] = send_best_arr;
    assign mprj_io[17] = load_kdtree;
    assign load_done = mprj_io[18];
    assign fsm_done = mprj_io[19];
    assign send_done = mprj_io[20];
    assign wbs_done = mprj_io[21];
    assign wbs_busy = mprj_io[22];
    assign wbs_cfg_done = mprj_io[23];
    assign mprj_io[25] = out_fifo_deq;
    assign out_fifo_rdata = mprj_io[36:26];
    assign out_fifo_rempty_n = mprj_io[37];

    // External clock is used by default.  Make this artificially fast for the
    // simulation.  Normally this would be a slow clock and the digital PLL
    // would be the fast clock.

    always #50 clock <= (clock === 1'b0);
    always #3 io_clk <= (io_clk === 1'b0);

    initial begin
        clock = 0;
        io_clk = 0;
    end

    integer scan_file;
    integer expected_idx_data_file;
    integer received_idx_data_file;
    integer received_dist_data_file;
    integer query_data_file;
    integer leaves_data_file;
    integer int_nodes_data_file;
    reg [2*DATA_WIDTH-1:0] received_dist [NUM_QUERYS-1:0];
    reg [DATA_WIDTH-1:0] received_idx [NUM_QUERYS-1:0];
    reg [DATA_WIDTH-1:0] expected_idx [NUM_QUERYS-1:0];
    integer x;
    integer xi;
    integer y;
    integer addr;
    real simtime;
    real kdtreetime;
    real querytime;
    real fsmtime;
    real outputtime;
    integer q;
    integer i;
    integer px;
    integer agg;
    reg sent;

    initial begin
        $timeformat(-9, 2, "ns", 20);
        $dumpfile("wb_e2e.vcd");
        $dumpvars(0, wb_e2e_tb);

        // 126 vidpairs
        expected_idx_data_file = $fopen("inputs/expectedIndex.txt", "r");
        if (expected_idx_data_file == 0) begin
            $display("expected_idx_data_file handle was NULL");
            $finish;
        end

        received_idx_data_file = $fopen("received_idx.txt", "w");
        received_dist_data_file = $fopen("received_dist.txt", "w");

	    for (q=0; q<1; q=q+1) begin
            
            for(i=0; i<NUM_QUERYS; i=i+1) begin
                scan_file = $fscanf(expected_idx_data_file, "%d\n", expected_idx[i]);
            end

            $display("Starting new image");

        
            fsm_start = 0;
            send_best_arr = 0;
            load_kdtree = 0;
            io_rst_n = 1'b1;
            in_fifo_wenq = 0;
            in_fifo_wdata = 11'd0;
            out_fifo_deq = 0;

            // reset accelerator
            #100
            io_rst_n = 0;
            #100
            io_rst_n = 1'b1;
            #100


            // wait for mgmt soc to finish configuring the io ports
            wait(wbs_cfg_done);
            $display("[T=%0t] Wishbone IO configuration done", $realtime);
            simtime = $realtime;

            wait(fsm_done == 1'b1);
            $display("[T=%0t] Wishbone finished", $realtime);
            fsmtime = $realtime - simtime;

            // wait for wishbone
            wait(wbs_done == 1);

            // receive outputs
            @(negedge io_clk) send_best_arr = 1'b1;
            $display("[T=%0t] Start receiving outputs", $realtime);
            simtime = $realtime;
            @(negedge io_clk) send_best_arr = 1'b0;

            // #1000; // test for continuous and uncontinuous rempty_n

            sent=0;
            for(px=0; px<2; px=px+1) begin
                //for(x=0; x<4; x=x+1) begin  // for row_size = 26
                for(x=0; x<(ROW_SIZE/2/BLOCKING); x=x+1) begin
                    for(y=0; y<COL_SIZE; y=y+1) begin
                        for(xi=0; xi<BLOCKING; xi=xi+1) begin
                            //if ((x != 3) || (xi < 1)) begin  // for row_size = 26
                                while(sent == 0) begin 
                                    @(negedge io_clk)
                                    if (out_fifo_rempty_n) begin
                                        out_fifo_deq = 1'b1;
                                        addr = px*ROW_SIZE/2 + y*ROW_SIZE + x*BLOCKING + xi;
                                        received_idx[addr] = out_fifo_rdata;
                                        // $display("addr %d, rdata %d", addr, out_fifo_rdata);
                                        @(negedge io_clk)
                                        out_fifo_deq = 1'b0;
                                        @(negedge io_clk);
                                        sent = 1;
                                    end else out_fifo_deq = 1'b0;
                                end
                                sent = 0;
                            // end
                        end
                    end
                end
            end

            @(negedge io_clk) out_fifo_deq = 1'b0;
            // #1000;

            for(px=0; px<2; px=px+1) begin
                //for(x=0; x<4; x=x+1) begin  // for row_size = 26
                for(x=0; x<(ROW_SIZE/2/BLOCKING); x=x+1) begin
                    for(y=0; y<COL_SIZE; y=y+1) begin
                        for(xi=0; xi<BLOCKING; xi=xi+1) begin
                            for(agg=0; agg<=1; agg=agg+1) begin  // most significant first
                                // if ((x != 3) || (xi < 1)) begin  // for row_size = 26
                                    while(sent == 0) begin
                                        @(negedge io_clk)
                                        if (out_fifo_rempty_n) begin
                                            out_fifo_deq = 1'b1;
                                            addr = px*ROW_SIZE/2 + y*ROW_SIZE + x*BLOCKING + xi;
                                            received_dist[addr][agg*DATA_WIDTH+:DATA_WIDTH] = out_fifo_rdata;
                                            @(negedge io_clk)
                                            out_fifo_deq = 1'b0;
                                            @(negedge io_clk);
                                            sent = 1;
                                        end else out_fifo_deq = 1'b0;
                                    end
                                    sent = 0;
                                // end
                            end
                        end
                    end
                end
            end

            @(negedge io_clk) out_fifo_deq = 1'b0;
            $display("[T=%0t] Finished receiving outputs", $realtime);
            outputtime = $realtime - simtime;

            for(i=0; i<NUM_QUERYS; i=i+1) begin
                $fwrite(received_idx_data_file, "%d\n", received_idx[i]);
                if (expected_idx[i] != received_idx[i])
                    $display("mismatch %d: expected: %d, received %d", i, expected_idx[i], received_idx[i]);
                // else
                //     $display("match %d: expected: %d, received %d", i, expected_idx[i], received_idx[i]);
            end

            for(i=0; i<NUM_QUERYS; i=i+1) begin
                $fwrite(received_dist_data_file, "%d\n", received_dist[i]);
                // if (expected_idx[i] != received_dist[i])
                //     $display("mismatch %d: expected: %d, received %d", i, expected_idx[i], received_dist[i]);
                // else
                //     $display("match %d: expected: %d, received %d", i, expected_idx[i], received_dist[i]);
            end

            $display("===============Runtime Summary===============");
            $display("KD tree: %t", kdtreetime);
            $display("Query patches: %t", querytime);
            $display("Main Algorithm: %t", fsmtime);
            $display("Outputs: %t", outputtime);

            #200;
            $finish;
        end
    end

    initial begin
        // Repeat cycles of 1000 clock edges as needed to complete testbench
        repeat (5000) begin
            repeat (1000) @(posedge clock);
            $display("+1000 cycles");
        end
        $display("%c[1;31m",27);
        `ifdef GL
            $display ("Monitor: Timeout, Test Mega-Project WB Port (GL) Failed");
        `else
            $display ("Monitor: Timeout, Test Mega-Project WB Port (RTL) Failed");
        `endif
        $display("%c[0m",27);
        $finish;
    end

    initial begin
        $display("Monitor: MPRJ-Logic WB Started");
        wait(fsm_done == 1);
        wait(wbs_done == 1);
        if (wbs_cfg_done == 1) begin
            `ifdef GL
                $display("Monitor: Wishbone debugging (GL) Passed");
            `else
                $display("Monitor: Wishbone debugging (RTL) Passed");
            `endif
        end
        else begin
            `ifdef GL
                $display ("Monitor: Wishbone debugging (GL) Failed");
            `else
                $display ("Monitor: Wishbone debugging (RTL) Failed");
            `endif
        end
        // $finish;
    end

    initial begin
        RSTB <= 1'b0;
        CSB  <= 1'b1;		// Force CSB high
        #2000;
        RSTB <= 1'b1;	    	// Release reset
        #100000;
        CSB = 1'b0;		// CSB can be released
    end

    initial begin		// Power-up sequence
        power1 <= 1'b0;
        power2 <= 1'b0;
        #200;
        power1 <= 1'b1;
        #200;
        power2 <= 1'b1;
    end

    wire flash_csb;
    wire flash_clk;
    wire flash_io0;
    wire flash_io1;

    wire VDD3V3 = power1;
    wire VDD1V8 = power2;
    wire USER_VDD3V3 = power3;
    wire USER_VDD1V8 = power4;
    wire VSS = 1'b0;

    caravel uut (
        .vddio	  (VDD3V3),
        .vddio_2  (VDD3V3),
        .vssio	  (VSS),
        .vssio_2  (VSS),
        .vdda	  (VDD3V3),
        .vssa	  (VSS),
        .vccd	  (VDD1V8),
        .vssd	  (VSS),
        .vdda1    (VDD3V3),
        .vdda1_2  (VDD3V3),
        .vdda2    (VDD3V3),
        .vssa1	  (VSS),
        .vssa1_2  (VSS),
        .vssa2	  (VSS),
        .vccd1	  (VDD1V8),
        .vccd2	  (VDD1V8),
        .vssd1	  (VSS),
        .vssd2	  (VSS),
        .clock    (clock),
        .gpio     (gpio),
        .mprj_io  (mprj_io),
        .flash_csb(flash_csb),
        .flash_clk(flash_clk),
        .flash_io0(flash_io0),
        .flash_io1(flash_io1),
        .resetb	  (RSTB)
    );

    spiflash #(
        .FILENAME("wb_e2e.hex")
    ) spiflash (
        .csb(flash_csb),
        .clk(flash_clk),
        .io0(flash_io0),
        .io1(flash_io1),
        .io2(),			// not used
        .io3()			// not used
    );

    `ifdef ENABLE_SDF
		initial begin
			$sdf_annotate("../../../sdf/user_project_wrapper.sdf", uut.mprj);
			$sdf_annotate("../../../sdf/user_proj_example.sdf", uut.mprj.mprj);
		end
	`endif 

endmodule
`default_nettype wire