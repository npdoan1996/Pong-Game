`timescale 1ns / 1ps
//***************************************************************//
//  File Name:  top_level_p5.v                                   //
//                                                               // 
//  Created by       Nguyen Doan on 10/29/2019	                 //
//  Copyright @ 2018 Nguyen Doan. All rights reserved,           //
//                                                               //    
//                                                               // 
//  In submiting this file for class work ar CSULB               //
//  I am confirming that this is my work and the work      	 //
//  of no one else. In submitting this code I acknowledge that   //
//  plagiarism in student project work is subject to dismissal 	 //
//  from the class                                               //       
//***************************************************************//


module top_level_p5(clk, rst, btn, h_sync, v_sync, rgb);
    input           clk, rst;
    input    [1:0]  btn;
    output          h_sync, v_sync;
    output  [11:0]  rgb;
    
    wire            reset_S;
    wire     [1:0]  button; //, button_p;
    
    AISO 
        AISO(.reset(rst), .clk(clk), .reset_S(reset_S));
        
    debounce
          d0(.reset(reset_S), .clk(clk), .button_in(btn[0]), .db_signal(button[0]));
    debounce
          d1(.reset(reset_S), .clk(clk), .button_in(btn[1]), .db_signal(button[1]));         
    vga_test
         VGA(.clk(clk),
             .rst(reset_S),
             .btn(button),
             .h_sync(h_sync),
             .v_sync(v_sync), 
             .rgb(rgb)
             );
endmodule
