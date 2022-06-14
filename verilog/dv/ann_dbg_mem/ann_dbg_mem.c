/*
 * SPDX-FileCopyrightText: 2020 Efabless Corporation
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 * SPDX-License-Identifier: Apache-2.0
 */

// This include is relative to $CARAVEL_PATH (see Makefile)
#include <defs.h>
#include <stub.c>

/*
	Wishbone Test:
		- Configures MPRJ lower 8-IO pins as outputs
		- Checks counter value through the wishbone port
*/
#define reg_mprj_cfg_mode                   (*(volatile uint32_t*)0x30000000)
#define reg_mprj_cfg_debug                  (*(volatile uint32_t*)0x30000004)
#define reg_mprj_cfg_done                   (*(volatile uint32_t*)0x30000008)
#define reg_mprj_cfg_fsm_start              (*(volatile uint32_t*)0x3000000C)
#define reg_mprj_cfg_fsm_done               (*(volatile uint32_t*)0x30000010)
#define reg_mprj_cfg_load_done              (*(volatile uint32_t*)0x30000014)
#define reg_mprj_cfg_send_done              (*(volatile uint32_t*)0x30000018)
#define reg_mprj_cfg_cfg_done               (*(volatile uint32_t*)0x3000001C)
#define reg_mprj_cfg_query                  ((volatile uint32_t*)0x30010000)
#define reg_mprj_cfg_leaf                   ((volatile uint32_t*)0x30020000)
#define reg_mprj_cfg_best                   ((volatile uint32_t*)0x30030000)
#define reg_mprj_cfg_node                   ((volatile uint32_t*)0x30040000)


void main()
{

	/* 
	IO Control Registers
	| DM     | VTRIP | SLOW  | AN_POL | AN_SEL | AN_EN | MOD_SEL | INP_DIS | HOLDH | OEB_N | MGMT_EN |
	| 3-bits | 1-bit | 1-bit | 1-bit  | 1-bit  | 1-bit | 1-bit   | 1-bit   | 1-bit | 1-bit | 1-bit   |
	Output: 0000_0110_0000_1110  (0x1808) = GPIO_MODE_USER_STD_OUTPUT
	| DM     | VTRIP | SLOW  | AN_POL | AN_SEL | AN_EN | MOD_SEL | INP_DIS | HOLDH | OEB_N | MGMT_EN |
	| 110    | 0     | 0     | 0      | 0      | 0     | 0       | 1       | 0     | 0     | 0       |
	
	 
	Input: 0000_0001_0000_1111 (0x0402) = GPIO_MODE_USER_STD_INPUT_NOPULL
	| DM     | VTRIP | SLOW  | AN_POL | AN_SEL | AN_EN | MOD_SEL | INP_DIS | HOLDH | OEB_N | MGMT_EN |
	| 001    | 0     | 0     | 0      | 0      | 0     | 0       | 0       | 0     | 1     | 0       |
	*/

	/* Set up the housekeeping SPI to be connected internally so	*/
	/* that external pin changes don't affect it.			*/

    reg_spi_enable = 1;
    reg_wb_enable = 1;
	// reg_spimaster_config = 0xa002;	// Enable, prescaler = 2,
                                        // connect to housekeeping SPI

    // Connect the housekeeping SPI to the SPI master
	// so that the CSB line is not left floating.  This allows
	// all of the GPIO pins to be used for user functions.

    reg_mprj_io_37 = GPIO_MODE_USER_STD_OUTPUT;
    reg_mprj_io_36 = GPIO_MODE_USER_STD_OUTPUT;
    reg_mprj_io_35 = GPIO_MODE_USER_STD_OUTPUT;
    reg_mprj_io_34 = GPIO_MODE_USER_STD_OUTPUT;
    reg_mprj_io_33 = GPIO_MODE_USER_STD_OUTPUT;
    reg_mprj_io_32 = GPIO_MODE_USER_STD_OUTPUT;
    reg_mprj_io_31 = GPIO_MODE_USER_STD_OUTPUT;
    reg_mprj_io_30 = GPIO_MODE_USER_STD_OUTPUT;
    reg_mprj_io_29 = GPIO_MODE_USER_STD_OUTPUT;
    reg_mprj_io_28 = GPIO_MODE_USER_STD_OUTPUT;
    reg_mprj_io_27 = GPIO_MODE_USER_STD_OUTPUT;
    reg_mprj_io_26 = GPIO_MODE_USER_STD_OUTPUT;
    reg_mprj_io_25 = GPIO_MODE_USER_STD_INPUT_NOPULL;
    reg_mprj_io_24 = GPIO_MODE_USER_STD_OUTPUT;
    reg_mprj_io_23 = GPIO_MODE_USER_STD_OUTPUT;
    reg_mprj_io_22 = GPIO_MODE_USER_STD_OUTPUT;
    reg_mprj_io_21 = GPIO_MODE_USER_STD_OUTPUT;
    reg_mprj_io_20 = GPIO_MODE_USER_STD_OUTPUT;
    reg_mprj_io_19 = GPIO_MODE_USER_STD_OUTPUT;
    reg_mprj_io_18 = GPIO_MODE_USER_STD_OUTPUT;
    reg_mprj_io_17 = GPIO_MODE_USER_STD_INPUT_NOPULL;
    reg_mprj_io_16 = GPIO_MODE_USER_STD_INPUT_NOPULL;
    reg_mprj_io_15 = GPIO_MODE_USER_STD_INPUT_NOPULL;
    reg_mprj_io_14 = GPIO_MODE_USER_STD_OUTPUT;
    reg_mprj_io_13 = GPIO_MODE_USER_STD_INPUT_NOPULL;
    reg_mprj_io_12 = GPIO_MODE_USER_STD_INPUT_NOPULL; 
    reg_mprj_io_11 = GPIO_MODE_USER_STD_INPUT_NOPULL;
    reg_mprj_io_10 = GPIO_MODE_USER_STD_INPUT_NOPULL;
    reg_mprj_io_9  = GPIO_MODE_USER_STD_INPUT_NOPULL;
    reg_mprj_io_8  = GPIO_MODE_USER_STD_INPUT_NOPULL;
    reg_mprj_io_7  = GPIO_MODE_USER_STD_INPUT_NOPULL;
    reg_mprj_io_6  = GPIO_MODE_USER_STD_INPUT_NOPULL;
    reg_mprj_io_5  = GPIO_MODE_USER_STD_INPUT_NOPULL;  
    reg_mprj_io_4  = GPIO_MODE_USER_STD_INPUT_NOPULL;
    reg_mprj_io_3  = GPIO_MODE_USER_STD_INPUT_NOPULL;
    reg_mprj_io_2  = GPIO_MODE_USER_STD_INPUT_NOPULL;
    reg_mprj_io_1  = GPIO_MODE_USER_STD_INPUT_NOPULL;
    reg_mprj_io_0  = GPIO_MODE_USER_STD_INPUT_NOPULL;

    // Set clock to 64 kbaud and enable the UART.  It is important to do this
    // before applying the configuration, or else the Tx line initializes as
    // zero, which indicates the start of a byte to the receiver.

    // reg_uart_clkdiv = 625;
    reg_uart_enable = 1;

    /* Apply configuration */
    reg_mprj_xfer = 1;
    while (reg_mprj_xfer == 1);

    // configure all LA as output
	reg_la0_oenb = reg_la0_iena = 0xFFFFFFFF;    // [31:0]
	reg_la1_oenb = reg_la1_iena = 0xFFFFFFFF;    // [63:32]
	reg_la2_oenb = reg_la2_iena = 0xFFFFFFFF;    // [95:64]
	reg_la3_oenb = reg_la3_iena = 0xFFFFFFFF;    // [127:96]

    reg_la0_data = 0x00000000;
	reg_la1_data = 0x00000000;
	reg_la2_data = 0x00000000;
	reg_la3_data = 0x00000000;

    // Done configuring the IO
    reg_mprj_cfg_cfg_done = 1;


    // bool skip_data_init = true;
    // if (!skip_data_init){
    //     // use wb clk and rst
    //     reg_mprj_cfg_mode = 1;
    //     // enable debug mode to load/store data
    //     reg_mprj_cfg_debug = 1;
        
    //     // query mem init
    //     // num query
    //     for (uint32_t i=0; i<2; i++){  // testing only
    //     // for (uint32_t i=0; i<494; i++){
    //         for (uint32_t j=0; j<2; j++){
    //             reg_mprj_cfg_query[2 * i + j] = 2 * i + j;
    //         }
    //     }


    //     // leaf mem init
    //     // num leaf
    //     for (uint32_t i=0; i<2; i++){  // testing only
    //     // for (uint32_t i=0; i<63; i++){
    //         // num patch
    //         for (uint32_t j=0; j<8; j++){
    //             for (uint32_t r=0; r<2; r++){
    //                 reg_mprj_cfg_leaf[2 * 8 * i + 2 * j + r] = 2 * 8 * i + 2 * j + r;
    //             }
    //         }
    //     }


    //     // internal node init


    //     // disable debug mode to release memory control
    //     reg_mprj_cfg_mode = 0;
    //     reg_mprj_cfg_debug = 0;
    // }


    // // start fsm
    // reg_mprj_cfg_fsm_done = 0;
    // reg_mprj_cfg_fsm_start = 1;
    // while(reg_mprj_cfg_fsm_done == 1);
    // reg_mprj_cfg_fsm_done = 0;

    
    // print("hello world\n");
    bool test_pass = true;

    bool debug_mem = true;
    if (debug_mem){
        while(reg_mprj_cfg_load_done==0);

        // enable debug mode to load/store data
        reg_mprj_cfg_mode = 1;
        reg_mprj_cfg_debug = 1;

        while(reg_mprj_cfg_query[0] != 0);
        while(reg_mprj_cfg_query[1] != 0);
        while(reg_mprj_cfg_query[2] != 0);
        while(reg_mprj_cfg_query[3] != 0);

        uint32_t a = reg_mprj_cfg_query[4];
        a = reg_mprj_cfg_query[5];
        a = reg_mprj_cfg_query[6];
        a = reg_mprj_cfg_query[7];

        // query mem read
        // num query
        for (uint32_t i=0; i<4; i=i+1){  // testing only
        // for (uint32_t i=0; i<494; i++){
            uint32_t data0 = reg_mprj_cfg_query[2 * i + 0];
            uint32_t data1 = reg_mprj_cfg_query[2 * i + 1];
            uint64_t data64b = ((uint64_t)data1 << 32) | data0;
            uint64_t mask_11b = 2047;
            for (uint32_t m=0; m<5; m++){
                uint64_t data_11b = data64b & mask_11b;
                data_11b = data_11b >> (m * 11);
                uint64_t expected_data_11b = (5 * i + m) & 0x7FF;
                if (data_11b != expected_data_11b) test_pass = false;
                mask_11b = mask_11b << 11;
            }
        }

        // leaf mem read
        // num leaf
        for (uint32_t i=0; i<2; i++){  // testing only
        // for (uint32_t i=0; i<63; i++){
            // num patch
            for (uint32_t j=0; j<8; j++){
                uint32_t data0 = reg_mprj_cfg_leaf[2 * i + 0];
                uint32_t data1 = reg_mprj_cfg_leaf[2 * i + 1];
                uint64_t data64b = ((uint64_t)data1 << 32) | data0;
                uint64_t mask_11b = 2047;
                for (uint32_t m=0; m<6; m++){
                    uint64_t data_11b = data64b & mask_11b;
                    data_11b = data_11b >> (m * 11);
                    uint64_t expected_data_11b = (6 * 8 * i + 6 * j + m);
                    if (m == 5)
                        expected_data_11b = expected_data_11b & 0x1FF;
                    else
                        expected_data_11b = expected_data_11b & 0x7FF;
                    if (data_11b != expected_data_11b) test_pass = false;
                    mask_11b = mask_11b << 11;
                }
            }
        }

        // // internal node tree read
        // for (uint32_t i=0; i<63; i++){
        //     uint32_t data = reg_mprj_cfg_node[i];

        //     // 3 bit index
        //     uint32_t data_idx3b = data & 0x07;
        //     uint32_t expected_data = (2 * i) & 0x07;
        //     if (data_idx3b != expected_data) {
        //         reg_mprj_cfg_cfg_done = 1;
        //         test_pass = false;
        //     }

        //     // 11 bit median
        //     uint32_t data_11b = (data & 0x03FF800) >> 11;
        //     // median is in bits [21:11]
        //     expected_data = (2 * i + 1) & 0x7FF;
        //     if (data_11b != expected_data) {
        //         reg_mprj_cfg_cfg_done = 1;
        //         test_pass = false;
        //     }

        //     // uint32_t mask_11b = 0x7FF;
        //     // for (uint32_t m=0; m<2; m++){
        //     //     uint32_t data_11b = data & mask_11b;
        //     //     uint32_t expected_data_11b = (2 * i + m) & 0x7FF;
        //     //     data_11b = data_11b >> (m * 11);
        //     //     if (data_11b != expected_data_11b) {
        //     //         reg_mprj_cfg_cfg_done = 1;
        //     //         test_pass = false;
        //     //     }
        //     //     mask_11b = mask_11b << 11;
        //     // }
        // }

        // disable debug mode to release memory control
        reg_mprj_cfg_mode = 0;
        reg_mprj_cfg_debug = 0;
    }

    // temporary hack
    if (test_pass) reg_mprj_cfg_cfg_done = 0;

    // tell ann_tb to stop
    reg_mprj_cfg_done = 1;
}
