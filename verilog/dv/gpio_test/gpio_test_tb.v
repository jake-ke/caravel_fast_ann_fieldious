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

module gpio_test_tb;
    parameter DATA_WIDTH = 11;
    parameter LEAF_SIZE = 8;
    parameter PATCH_SIZE = 5;
    parameter ROW_SIZE = 26;
    parameter COL_SIZE = 19;
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


    // assign mprj_io[0] = io_clk;
    // assign mprj_io[1] = io_rst_n;
    // assign mprj_io[2] = in_fifo_wenq;
    // assign mprj_io[13:3] = in_fifo_wdata;
    // assign mprj_io[14] = out_fifo_deq;
    // assign mprj_io[15] = fsm_start;
    // assign mprj_io[16] = send_best_arr;
    // assign mprj_io[17] = load_kdtree;
    // assign in_fifo_wfull_n = mprj_io[18];
    // assign out_fifo_rdata = mprj_io[29:19];
    // assign out_fifo_rempty_n = mprj_io[30];
    // assign fsm_done = mprj_io[31];
    // assign wbs_done = mprj_io[32];
    // assign wbs_busy = mprj_io[33];
    // assign wbs_cfg_done = mprj_io[34];
    reg [37:0] dummy;
    assign mprj_io = dummy;

    // External clock is used by default.  Make this artificially fast for the
    // simulation.  Normally this would be a slow clock and the digital PLL
    // would be the fast clock.

    always #1 clock <= (clock === 1'b0);
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
        $dumpfile("gpio_test.vcd");
        $dumpvars(0, gpio_test_tb);

        
        fsm_start = 0;
        send_best_arr = 0;
        load_kdtree = 0;
        io_rst_n = 1'b1;
        in_fifo_wenq = 0;
        in_fifo_wdata = 11'd0;
        out_fifo_deq = 0;

        dummy = 38'hf0_dead_beef;
        #100000;
        dummy = 38'bZ;
        // // wait for mgmt soc to finish configuring the io ports
        // wait(wbs_cfg_done);

        
    end

    initial begin
        // Repeat cycles of 1000 clock edges as needed to complete testbench
        repeat (100) begin
            repeat (1000) @(posedge clock);
            $display("+1000 cycles");
        end
        $display("%c[1;31m",27);
        $display("%c[0m",27);
        `ifdef GL
            $display ("Monitor: Test Mega-Project WB Port (GL) Failed");
        `else
            $display ("Monitor: Test Mega-Project WB Port (RTL) Failed");
        `endif
        $finish;
    end

    initial begin
        $display("Monitor: MPRJ-Logic WB Started");
        wait(mprj_io == 38'h0F0F0F0F0F);
        `ifdef GL
            $display("Monitor: Mega-Project WB (GL) Passed");
        `else
            $display("Monitor: Mega-Project WB (RTL) Passed");
        `endif
        #1000
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
        .FILENAME("gpio_test.hex")
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