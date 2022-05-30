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

module ann_tb;
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


    assign mprj_io[13] = io_clk;
    assign mprj_io[14] = io_rst_n;
    assign mprj_io[0] = in_fifo_wenq;
    assign mprj_io[11:1] = in_fifo_wdata;
    assign in_fifo_wfull_n = mprj_io[12];
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

    always #1 clock <= (clock === 1'b0);
    always #5 io_clk <= (io_clk === 1'b0);

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
    integer i;
    integer px;
    integer agg;

    initial begin
        $timeformat(-9, 2, "ns", 20);
        $dumpfile("ann.vcd");
        $dumpvars(0, ann_tb);

        // basketball1
        expected_idx_data_file = $fopen("expectedIndex.txt", "r");
        // expected_idx_data_file = $fopen("data/IO_data/topToBottomLeafIndex.txt", "r");
        if (expected_idx_data_file == 0) begin
            $display("expected_idx_data_file handle was NULL");
            $finish;
        end
        for(i=0; i<NUM_QUERYS; i=i+1) begin
            scan_file = $fscanf(expected_idx_data_file, "%d\n", expected_idx[i]);
        end

        int_nodes_data_file = $fopen("internalNodes.txt", "r");
        if (int_nodes_data_file == 0) begin
            $display("int_nodes_data_file handle was NULL");
            $finish;
        end
        
        leaves_data_file = $fopen("leafNodes.txt", "r");
        if (leaves_data_file == 0) begin
            $display("leaves_data_file handle was NULL");
            $finish;
        end

        query_data_file = $fopen("patches.txt", "r");
        if (query_data_file == 0) begin
            $display("query_data_file handle was NULL");
            $finish;
        end

        
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
        #20
        io_rst_n = 1'b1;
        #40

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
            scan_file = $fscanf(int_nodes_data_file, "%d\n", in_fifo_wdata[10:0]);
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
            scan_file = $fscanf(leaves_data_file, "%d\n", in_fifo_wdata[10:0]);
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
            scan_file = $fscanf(query_data_file, "%d\n", in_fifo_wdata[10:0]);
        end
        @(negedge io_clk)
        in_fifo_wenq = 0;
        in_fifo_wdata = 11'd0;
        $display("[T=%0t] Finished sending queries", $realtime);
        querytime = $realtime - simtime;

        #100;  // can be replaced by send_done

        //start algorithm
        @(negedge io_clk) fsm_start = 1'b1;
        $display("[T=%0t] Start algorithm (ExactFstRow, SearchLeaf and ProcessRows)", $realtime);
        simtime = $realtime;
        @(negedge io_clk) fsm_start = 1'b0;

        wait(fsm_done == 1'b1);
        $display("[T=%0t] Finished algorithm (ExactFstRow, SearchLeaf and ProcessRows)", $realtime);
        fsmtime = $realtime - simtime;

        @(negedge io_clk);
        @(negedge io_clk);
        @(negedge io_clk);

        // receive outputs
        @(negedge io_clk) send_best_arr = 1'b1;
        $display("[T=%0t] Start receiving outputs", $realtime);
        simtime = $realtime;
        @(negedge io_clk) send_best_arr = 1'b0;

        for(px=0; px<2; px=px+1) begin
            for(x=0; x<4; x=x+1) begin
                // for(x=0; x<(ROW_SIZE/2/BLOCKING); x=x+1) begin  // for row_size = 24
                for(y=0; y<COL_SIZE; y=y+1) begin
                    for(xi=0; xi<BLOCKING; xi=xi+1) begin
                        if ((x != 3) || (xi < 1)) begin  // for row_size = 26
                            wait(out_fifo_rempty_n);
                            @(negedge io_clk)
                            out_fifo_deq = 1'b1;
                            addr = px*ROW_SIZE/2 + y*ROW_SIZE + x*BLOCKING + xi;
                            received_idx[addr] = out_fifo_rdata;
                            @(posedge io_clk); #1;
                        end
                    end
                end
            end
        end

        for(px=0; px<2; px=px+1) begin
            for(x=0; x<4; x=x+1) begin
                // for(x=0; x<(ROW_SIZE/2/BLOCKING); x=x+1) begin  // for row_size = 24
                for(y=0; y<COL_SIZE; y=y+1) begin
                    for(xi=0; xi<BLOCKING; xi=xi+1) begin
                        for(agg=0; agg<=1; agg=agg+1) begin  // most significant first
                            if ((x != 3) || (xi < 1)) begin  // for row_size = 26
                                wait(out_fifo_rempty_n);
                                @(negedge io_clk)
                                out_fifo_deq = 1'b1;
                                addr = px*ROW_SIZE/2 + y*ROW_SIZE + x*BLOCKING + xi;
                                received_dist[addr][agg*DATA_WIDTH+:DATA_WIDTH] = out_fifo_rdata;
                                @(posedge io_clk); #1;
                            end
                        end
                    end
                end
            end
        end

        @(negedge io_clk) out_fifo_deq = 1'b0;
        $display("[T=%0t] Finished receiving outputs", $realtime);
        outputtime = $realtime - simtime;

        received_idx_data_file = $fopen("received_idx.txt", "w");
        for(i=0; i<NUM_QUERYS; i=i+1) begin
            $fwrite(received_idx_data_file, "%d\n", received_idx[i]);
            if (expected_idx[i] != received_idx[i])
                $display("mismatch %d: expected: %d, received %d", i, expected_idx[i], received_idx[i]);
            // else
            //     $display("match %d: expected: %d, received %d", i, expected_idx[i], received_idx[i]);
        end

        received_dist_data_file = $fopen("received_dist.txt", "w");
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
        `ifdef GL
            $display("Monitor: Mega-Project WB (GL) Passed");
        `else
            $display("Monitor: Mega-Project WB (RTL) Passed");
        `endif
    end

    initial begin
        // Repeat cycles of 1000 clock edges as needed to complete testbench
        repeat (200) begin
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
        wait(wbs_done == 1);
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
        .FILENAME("ann.hex")
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