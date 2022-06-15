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


    bool skip_data_init = true;
    if (!skip_data_init){
        // use wb clk and rst
        reg_mprj_cfg_mode = 1;
        // enable debug mode to load/store data
        reg_mprj_cfg_debug = 1;
        
        // query mem init
        // num query
        for (uint32_t i=0; i<2; i++){  // testing only
        // for (uint32_t i=0; i<494; i++){
            for (uint32_t j=0; j<2; j++){
                reg_mprj_cfg_query[2 * i + j] = 2 * i + j;
            }
        }


        // leaf mem init
        // num leaf
        for (uint32_t i=0; i<2; i++){  // testing only
        // for (uint32_t i=0; i<63; i++){
            // num patch
            for (uint32_t j=0; j<8; j++){
                for (uint32_t r=0; r<2; r++){
                    reg_mprj_cfg_leaf[2 * 8 * i + 2 * j + r] = 2 * 8 * i + 2 * j + r;
                }
            }
        }


        // internal node init


        // disable debug mode to release memory control
        reg_mprj_cfg_mode = 0;
        reg_mprj_cfg_debug = 0;
    }


    // // start fsm
    // reg_mprj_cfg_fsm_done = 0;
    // reg_mprj_cfg_fsm_start = 1;
    // while(reg_mprj_cfg_fsm_done == 1);
    // reg_mprj_cfg_fsm_done = 0;

    bool debug_mem = true;
    if (debug_mem){
        while(reg_mprj_cfg_load_done==0);
        reg_mprj_cfg_load_done = 0;
        while(reg_mprj_cfg_fsm_done==0);
        reg_mprj_cfg_fsm_done = 0;
        while(reg_mprj_cfg_send_done==0);
        reg_mprj_cfg_send_done = 0;
        
        // // if doing 2 tests
        // while(reg_mprj_cfg_load_done==0);
        // reg_mprj_cfg_load_done = 0;
        // while(reg_mprj_cfg_fsm_done==0);
        // reg_mprj_cfg_fsm_done = 0;
        // while(reg_mprj_cfg_send_done==0);
        // reg_mprj_cfg_send_done = 0;

        // enable debug mode to load/store data
        reg_mprj_cfg_mode = 1;
        reg_mprj_cfg_debug = 1;

        uint32_t a;
        // query 0
        if (reg_mprj_cfg_query[0] != 0xF682416B) reg_mprj_cfg_cfg_done = 0;
        if (reg_mprj_cfg_query[1] != 0x00773071) reg_mprj_cfg_cfg_done = 0;
        // query 1
        if (reg_mprj_cfg_query[2] != 0XFB878954) reg_mprj_cfg_cfg_done = 0;
        if (reg_mprj_cfg_query[3] != 0X007E6F6B) reg_mprj_cfg_cfg_done = 0;
        // query 510
        if (reg_mprj_cfg_query[1020] != 0X197C719B) reg_mprj_cfg_cfg_done = 0;
        if (reg_mprj_cfg_query[1021] != 0X00028EF6) reg_mprj_cfg_cfg_done = 0;
        // query 511
        if (reg_mprj_cfg_query[1022] != 0X0DBCFA21) reg_mprj_cfg_cfg_done = 0;
        if (reg_mprj_cfg_query[1023] != 0X0002CEB0) reg_mprj_cfg_cfg_done = 0;


        // node 0
        if (reg_mprj_cfg_node[0] != 0X003B4800) reg_mprj_cfg_cfg_done = 0;
        // node 1
        if (reg_mprj_cfg_node[1] != 0X00002802) reg_mprj_cfg_cfg_done = 0;
        // node 61
        if (reg_mprj_cfg_node[61] != 0X0001F803) reg_mprj_cfg_cfg_done = 0;
        // node 62
        if (reg_mprj_cfg_node[62] != 0X00062800) reg_mprj_cfg_cfg_done = 0;


        // leaf 0 patch 0
        if (reg_mprj_cfg_leaf[0] != 0XDFBA6F35) reg_mprj_cfg_cfg_done = 0;
        if (reg_mprj_cfg_leaf[1] != 0X90005007) reg_mprj_cfg_cfg_done = 0;
        // leaf 0 patch 1
        if (reg_mprj_cfg_leaf[2] != 0XE3BB7F2E) reg_mprj_cfg_cfg_done = 0;
        if (reg_mprj_cfg_leaf[3] != 0XA0FFC093) reg_mprj_cfg_cfg_done = 0;
        // leaf 1 patch 0
        if (reg_mprj_cfg_leaf[16] != 0XF67EAF66) reg_mprj_cfg_cfg_done = 0;
        if (reg_mprj_cfg_leaf[17] != 0X77FECFF3) reg_mprj_cfg_cfg_done = 0;
        // leaf 62 patch 0
        if (reg_mprj_cfg_leaf[992] != 0X133FE878) reg_mprj_cfg_cfg_done = 0;
        if (reg_mprj_cfg_leaf[993] != 0X1D07A014) reg_mprj_cfg_cfg_done = 0;
        // leaf 62 patch 7
        if (reg_mprj_cfg_leaf[1006] != 0X0EC0A8C5) reg_mprj_cfg_cfg_done = 0;
        if (reg_mprj_cfg_leaf[1007] != 0X0F032050) reg_mprj_cfg_cfg_done = 0;
        // leaf 63 patch 6
        if (reg_mprj_cfg_leaf[1020] != 0X0745F9C7) reg_mprj_cfg_cfg_done = 0;
        if (reg_mprj_cfg_leaf[1021] != 0X7FFC20D0) reg_mprj_cfg_cfg_done = 0;
        // leaf 63 patch 7
        if (reg_mprj_cfg_leaf[1022] != 0XFA8569CA) reg_mprj_cfg_cfg_done = 0;
        if (reg_mprj_cfg_leaf[1023] != 0X8FFFC0D1) reg_mprj_cfg_cfg_done = 0;


        // best 0
        if (reg_mprj_cfg_best[0] != 0X005EE6BF) reg_mprj_cfg_cfg_done = 0;
        // best 16
        if (reg_mprj_cfg_best[1] != 0X00A1FA37) reg_mprj_cfg_cfg_done = 0;
        // best 1
        if (reg_mprj_cfg_best[2] != 0X018F231F) reg_mprj_cfg_cfg_done = 0;
        // best 17
        if (reg_mprj_cfg_best[3] != 0X00985637) reg_mprj_cfg_cfg_done = 0;
        // best 494
        if (reg_mprj_cfg_best[1020] != 0X001D9E08) reg_mprj_cfg_cfg_done = 0;
        // best 510
        if (reg_mprj_cfg_best[1021] != 0X00A464BD) reg_mprj_cfg_cfg_done = 0;
        // best 495
        if (reg_mprj_cfg_best[1022] != 0X006A0026) reg_mprj_cfg_cfg_done = 0;
        // best 511
        if (reg_mprj_cfg_best[1023] != 0X01979EBD) reg_mprj_cfg_cfg_done = 0;


        // the following for loop do not generate read!!! why?

        // // query mem read
        // // num query
        // for (uint32_t i=0; i<2; i++){  // testing only
        // // for (uint32_t i=0; i<512; i++){
        //     for (uint32_t j=0; j<2; j++){
        //         uint32_t data = reg_mprj_cfg_query[2 * i + j];
        //     }
        // }

        // // leaf mem read
        // // num leaf
        // for (uint32_t i=0; i<2; i++){  // testing only
        // // for (uint32_t i=0; i<63; i++){
        //     // num patch
        //     for (uint32_t j=0; j<8; j++){
        //         for (uint32_t r=0; r<2; r++){
        //             uint32_t data = reg_mprj_cfg_leaf[2 * 8 * i + 2 * j + r];
        //         }
        //     }
        // }

        // // best array read back
        // // num query
        // for (uint32_t i=0; i<2; i++){  // testing only
        // // for (uint32_t i=0; i<512; i++){
        //     for (uint32_t j=0; j<2; j++){
        //         uint32_t data = reg_mprj_cfg_best[2 * i + j];
        //     }
        // }

        // disable debug mode to release memory control
        reg_mprj_cfg_mode = 0;
        reg_mprj_cfg_debug = 0;
    }

    // tell ann_tb to stop
    reg_mprj_cfg_done = 1;


}
