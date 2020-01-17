`timescale 1ns / 1ps
//***************************************************************//
//  File Name:  pulsegeneration.v                                            //
//                                                               // 
//  Created by       Nguyen Doan on 9/6/2019	                 //
//  Copyright @ 2018 Nguyen Doan. All rights reserved,           //
//                                                               //    
//                                                               // 
//  In submiting this file for class work ar CSULB               //
//  I am confirming that this is my work and the work      	     //
//  of no one else. In submitting this code I acknowledge that   //
//  plagiarism in student project work is subject to dismissal 	 //
//  from the class                                               //    
//***************************************************************//

module pulsegeneration(reset, clk, tick);
    input               clk, reset;
    output              tick;
    reg       [19:0]    count, n_count;
    
    always @(posedge clk, posedge reset)
        if (reset) 
            count <= 0;
        else 
            count <= n_count;
            
    always @ (*)
        if(tick)
            n_count = 20'b0;
        else
            n_count = count + 1'b1;
     
    assign tick = (count == 20'd999_999);
    
endmodule
