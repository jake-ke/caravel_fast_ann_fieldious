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

module ann_dbg_mem_tb;
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
    wire                                fsm_done;
    reg                                 send_best_arr;
    wire                                send_done;
    reg                                 load_kdtree;
    wire                                load_done;
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

    always #0.5 clock <= (clock === 1'b0);
    always #1 io_clk <= (io_clk === 1'b0);

    initial begin
        clock = 0;
        io_clk = 0;
    end


    integer x;
    integer xi;
    integer y;
    integer addr;
    real simtime;
    real kdtreetime;
    real querytime;
    real fsmtime;
    real outputtime;
    integer i;
    integer px;
    integer agg;

    initial begin
        $timeformat(-9, 2, "ns", 20);
        $dumpfile("ann_dbg_mem.vcd");
        $dumpvars(0, ann_dbg_mem_tb);

        
        fsm_start = 0;
        send_best_arr = 0;
        load_kdtree = 0;
        io_rst_n = 1'b1;
        in_fifo_wenq = 0;
        in_fifo_wdata = 11'd0;
        out_fifo_deq = 0;


        // wait for mgmt soc to finish configuring the io ports
        wait(wbs_cfg_done);


        // reset accelerator
        #100
        io_rst_n = 0;
        #100
        io_rst_n = 1'b1;
        #100

        // start load kd tree internal nodes and leaves
        @(negedge io_clk) load_kdtree = 1'b1;
        simtime = $realtime;
        $display("[T=%0t] Start sending KD tree internal nodes and leaves", $realtime);
        @(negedge io_clk) load_kdtree = 1'b0;

        // send internal nodes, 2 lines per node
        // index
        // median
        for(i=0; i<NUM_NODES*2; i=i+1) begin
            @(negedge io_clk)
            in_fifo_wenq = 1'b1;
            in_fifo_wdata = i;
        end
        @(negedge io_clk)
        in_fifo_wenq = 0;
        in_fifo_wdata = 11'd0;

        // send leaves, 6*8 lines per leaf
        // 8 patches per leaf
        // each patch has 5 lines of data
        // and 1 line of patch index in the original image (for reconstruction)
        for(i=0; i<NUM_LEAVES*6*8; i=i+1) begin
            @(negedge io_clk)
            in_fifo_wenq = 1'b1;
            in_fifo_wdata = i;
        end
        @(negedge io_clk)
        in_fifo_wenq = 0;
        in_fifo_wdata = 11'd0;
        $display("[T=%0t] Finished sending KD tree internal nodes and leaves", $realtime);
        kdtreetime = $realtime - simtime;
        
        $display("[T=%0t] Start sending queries", $realtime);
        simtime = $realtime;
        // send query patches, 5 lines per query patch
        // each patch has 5 lines of data
        for(i=0; i<NUM_QUERYS*5; i=i+1) begin
            @(negedge io_clk)
            in_fifo_wenq = 1'b1;
            in_fifo_wdata = i;
        end
        @(negedge io_clk)
        in_fifo_wenq = 0;
        in_fifo_wdata = 11'd0;
        $display("[T=%0t] Finished sending queries", $realtime);
        querytime = $realtime - simtime;


        $display("===============Runtime Summary===============");
        $display("KD tree: %t", kdtreetime);
        $display("Query patches: %t", querytime);
    end

    initial begin
        // Repeat cycles of 1000 clock edges as needed to complete testbench
        repeat (150) begin
            repeat (1000) @(posedge clock);
            $display("+1000 cycles");
        end
        $display("%c[1;31m",27);
        $display("%c[0m",27);
        $finish;
    end

    initial begin
        $display("Monitor: MPRJ-Logic WB Started");
        wait(wbs_done == 1);
        if (wbs_cfg_done == 0) begin
            `ifdef GL
                $display("Monitor: Mega-Project WB (GL) Passed");
            `else
                $display("Monitor: Mega-Project WB (RTL) Passed");
            `endif
        end
        else begin
            `ifdef GL
                $display ("Monitor: Test Mega-Project WB Port (GL) Failed");
            `else
                $display ("Monitor: Test Mega-Project WB Port (RTL) Failed");
            `endif
        end
        $finish;
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
        .FILENAME("ann_dbg_mem.hex")
    ) spiflash (
        .csb(flash_csb),
        .clk(flash_clk),
        .io0(flash_io0),
        .io1(flash_io1),
        .io2(),			// not used
        .io3()			// not used
    );

endmodule
`default_nettype wire