`timescale 1ns / 1ps
//***************************************************************//
//  File Name:  debounce.v                                       //
//                                                               // 
//  Created by       Nguyen Doan on 9/6/2019	                 //
//  Copyright @ 2018 Nguyen Doan. All rights reserved,           //
//                                                               //    
//                                                               // 
//  In submiting this file for class work ar CSULB               //
//  I am confirming that this is my work and the work      	 //
//  of no one else. In submitting this code I acknowledge that   //
//  plagiarism in student project work is subject to dismissal 	 //
//  from the class                                               //    
//***************************************************************//


module debounce (reset, clk, button_in, db_signal);
    input               reset, clk, button_in;
    output              db_signal;
    
    wire                tick;
    
    pulsegeneration 
        pulse           (.reset(reset), .clk(clk), .tick(tick));
    
    DBstatemachine
        statemachine    (.reset(reset), .clk(clk), .sw(button_in), 
                         .m_tick(tick), .out(db_signal));
        
endmodule
