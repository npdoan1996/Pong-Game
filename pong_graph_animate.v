`timescale 1ns / 1ps
//***************************************************************//
//  File Name:  pong_graph_animate.v                             //
//                                                               // 
//  Created by       Nguyen Doan on 10/29/2019	                 //
//  Copyright @ 2019 Nguyen Doan. All rights reserved,           //
//                                                               // 
//  In submiting this file for class work ar CSULB               //
//  I am confirming that this is my work based on Pong Chu's     //
//  pong_graph_animate. In submitting this code I acknowledge that    //
//  plagiarism in student project work is subject to dismissal 	 //
//  from the class                                               //    
//***************************************************************//


module pong_graph_animate(clk, rst, btn, video_on, pixel_x, pixel_y, graph_rgb);

    input                clk, rst;
    input        [1:0]   btn;
    input                video_on;
    input        [9:0]   pixel_x, pixel_y;
    output reg  [11:0]   graph_rgb;
    
    // constant and signal decleration
    // x, y coordinates (0,0) to (639,479)
    localparam  MAX_X = 640;
    localparam  MAX_Y = 480;
    
    ///////////////////////////////////////
    // Object output signals
    ///////////////////////////////////////
    wire         wall_on, paddle_on, sq_ball_on, rd_ball_on;
    wire  [11:0] wall_rgb, paddle_rgb, ball_rgb;
    wire   [9:0] paddle_y_t, paddle_y_b;
    // register to track to boundary 
    reg    [9:0] paddle_y_reg, paddle_y_next;
    // Reg to track left and top position
    reg    [9:0] ball_x_reg, ball_y_reg;
    wire   [9:0] ball_x_next, ball_y_next;
    // Reg to track ball speed 
    reg    [9:0] x_delta_reg, x_delta_next;
    reg    [9:0] y_delta_reg, y_delta_next;
    wire         refr_tick;
    
    // registers
    always @(posedge clk, posedge rst)
        if (rst)
            begin
                paddle_y_reg <= 10'd204;
                ball_x_reg <= 0;
                ball_y_reg <= 0;
                x_delta_reg <= 10'h2;
                y_delta_reg <= 10'h2;
            end
         else 
            begin
                paddle_y_reg <= paddle_y_next;
                ball_x_reg <= ball_x_next;
                ball_y_reg <= ball_y_next;
                x_delta_reg <= x_delta_next;
                y_delta_reg <= y_delta_next;
            end
       
    // refr_tick: 1-clock tick asserted at start of v_sync
    //              i.e when the screen is refreshed (60Hz)
    assign refr_tick = (pixel_y == 481) && (pixel_x == 0);
    
    ///////////////////////////////////////
    //  Wall
    ///////////////////////////////////////
    // Wall left, right boundary
    localparam WALL_X_L = 32;
    localparam WALL_X_R = 35;
    
    assign wall_on = (WALL_X_L <= pixel_x) && (pixel_x <= WALL_X_R);
    // wall rgb output
    assign wall_rgb = 12'h00f; // GREEN
    
    ///////////////////////////////////////
    // Paddle
    ///////////////////////////////////////
    // Paddle left, right boundary
    localparam PADDLE_X_L = 600;
    localparam PADDLE_X_R = 603;
    // Paddle top, bottom boundary
    localparam PADDLE_Y_SIZE = 72;
    localparam PADDLE_Y_T = MAX_Y/2 - PADDLE_Y_SIZE/2; // 204
    localparam PADDLE_Y_B = PADDLE_Y_T + PADDLE_Y_SIZE - 1; // 276  
 
    // paddle moving velocity when a button is presses
    localparam  PADDLE_V = 2; //4
    
    assign paddle_y_t = paddle_y_reg;
    assign paddle_y_b = paddle_y_t + PADDLE_Y_SIZE - 1;
    assign paddle_on = (PADDLE_X_L <= pixel_x) && (pixel_x <= PADDLE_X_R) &&
                       (paddle_y_t <= pixel_y) && (pixel_y <= paddle_y_b);
    // new bar y-position
    always @*
    begin 
        paddle_y_next = paddle_y_reg;
        if (refr_tick)
            if (btn[1] & (paddle_y_b < (MAX_Y -1 - PADDLE_V)))
                paddle_y_next = paddle_y_reg + PADDLE_V; // move down
            else if (btn[0] & (paddle_y_t > PADDLE_V))
                paddle_y_next = paddle_y_reg - PADDLE_V; // move up  
    end
                  
    // Paddle rgb output 
    assign paddle_rgb = 12'h0f0;   // RED
    
    ///////////////////////////////////////
    // Round  ball
    ///////////////////////////////////////
    localparam BALL_SIZE = 8;
    // Ball left, right boundary
    wire [9:0]  ball_x_l, ball_x_r;  
    // ball top, bottom boundary
    wire [9:0]  ball_y_t, ball_y_b;

    // ball velocity can be pos or neg 
    localparam BALL_V_P = 1;  // 2 
    localparam BALL_V_N = -1; //-2
    // Round ball configuration
    wire [2:0]  rom_addr, rom_col;
    wire        rom_bit;
    reg  [7:0]  rom_data;
    
    // rom ball image ROM
    always @*
        case(rom_addr) 
            3'h0: rom_data = 8'b00111100;
            3'h1: rom_data = 8'b01111110;
            3'h2: rom_data = 8'b11111111;
            3'h3: rom_data = 8'b11111111;
            3'h4: rom_data = 8'b11111111;
            3'h5: rom_data = 8'b11111111;
            3'h6: rom_data = 8'b01111110;
            3'h7: rom_data = 8'b00111100;
        endcase
    // boundary
    assign ball_x_l = ball_x_reg;
    assign ball_y_t = ball_y_reg;
    assign ball_x_r = ball_x_l + BALL_SIZE - 1;
    assign ball_y_b = ball_y_t + BALL_SIZE - 1;
    // map current pixel location to ROM addr/col
    assign rom_addr = pixel_y[2:0] - ball_y_t[2:0];
    assign rom_col = pixel_x[2:0] - ball_x_l[2:0];
    assign rom_bit = rom_data[rom_col];
    // pixel within ball 
    assign rd_ball_on = sq_ball_on & rom_bit;
    // pixel within ball 
    assign sq_ball_on = (ball_x_l <= pixel_x) && (pixel_x <= ball_x_r) &&
                        (ball_y_t <= pixel_y) && (pixel_y <= ball_y_b);
    assign ball_rgb = 12'hf00;  //BLUE
    // new ball position
    assign ball_x_next = (refr_tick) ? ball_x_reg + x_delta_reg : ball_x_reg;
    assign ball_y_next = (refr_tick) ? ball_y_reg + y_delta_reg : ball_y_reg;
    
    // new ball velocity
    always @*
    begin
        x_delta_next = x_delta_reg;
        y_delta_next = y_delta_reg;
        if (ball_y_t < 1) // reach top
            y_delta_next = BALL_V_P;
        else if (ball_y_b > (MAX_Y - 1)) // reach bottom
            y_delta_next = BALL_V_N;
        else if (ball_x_l <= WALL_X_R)  //reach wall
            x_delta_next = BALL_V_P;    // bounce back
        else if ((PADDLE_X_L <= ball_x_r) && (ball_x_r <= PADDLE_X_R) &&
                 (paddle_y_t <= ball_y_b) && (ball_y_t <= paddle_y_b))
            // reach x of right bar and hit, ball bounce back
            x_delta_next = BALL_V_N;
    end
   
    ///////////////////////////////////////
    // rgb multiplexing
    ///////////////////////////////////////
    always @*
        if (~video_on)
            graph_rgb = 12'h0;
        else 
            if (wall_on)
                graph_rgb = wall_rgb;
            else if (paddle_on)
                graph_rgb = paddle_rgb;
            else if (rd_ball_on)
                graph_rgb = ball_rgb;
            else 
                graph_rgb = 12'haaa;
        
endmodule
