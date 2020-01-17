`timescale 1ns / 1ps
//***************************************************************//
//  File Name:  DBstatemachine.v                                            //
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


module DBstatemachine(reset, clk, sw, m_tick, out);
    input           clk, reset;
    input           sw, m_tick;
    output          out;
    
    reg     [2:0]   state, next_state;
    reg             out, next_out;
    
    parameter       ZERO = 3'b000, Wait1_1 = 3'b001, 
                    Wait1_2 = 3'b010, Wait1_3 = 3'b011,
                    ONE = 3'b100, Wait0_1 = 3'b101,
                    Wait0_2 = 3'b110, Wait0_3 = 3'b111;  

///////////////////////////////////////////////////////////////////
// combination block generates the next values
///////////////////////////////////////////////////////////////////
always @ (*)
    begin 
        case (state)
           ZERO:    {next_state, next_out} = (sw) ? {Wait1_1,1'b0} 
                                                  : {ZERO,1'b0};
           Wait1_1: {next_state, next_out} = (sw) ? (m_tick? {Wait1_2,1'b0} 
                                                  : {Wait1_1,1'b0}) 
                                                  : {ZERO,1'b0};
           Wait1_2: {next_state, next_out} = (sw) ? (m_tick? {Wait1_3,1'b0} 
                                                  : {Wait1_2,1'b0}) 
                                                  : {ZERO,1'b0};
           Wait1_3: {next_state, next_out} = (sw) ? (m_tick? {ONE,1'b1}     
                                                  : {Wait1_3,1'b0}) 
                                                  : {ZERO,1'b0}; 
           ONE    : {next_state, next_out} = (sw) ? {ONE, 1'b1} 
                                                  : {Wait0_1, 1'b1};
           Wait0_1: {next_state, next_out} = (sw) ? {ONE, 1'b1} 
                                                  : (m_tick? {Wait0_2,1'b1} 
                                                  : {Wait0_1,1'b1});
           Wait0_2: {next_state, next_out} = (sw) ? {ONE, 1'b1}
                                                  : (m_tick? {Wait0_3,1'b1} 
                                                  : {Wait0_2,1'b1});
           Wait0_3: {next_state, next_out} = (sw) ? {ONE, 1'b1} 
                                                  : (m_tick? {ZERO,1'b0}    
                                                  : {Wait0_3,1'b1});
           default: {next_state, next_out} = {ZERO, 1'b0};
        
        endcase
    end 

/////////////////////////////////////////////////////////////////////
// sequential block generates the registers
/////////////////////////////////////////////////////////////////////
always @ (posedge reset, posedge clk) 
    if (reset) begin
        state <= 3'b000;
        out <= 1'b0;
        end
    else begin
        state <= next_state;
        out <= next_out;
        end
        

endmodule
