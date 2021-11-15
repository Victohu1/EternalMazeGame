`timescale 1ns / 1ps

module block_controller(
	input clk, //this clock must be a slow enough clock to view the changing positions of the objects
	input bright,
	input rst,
	input up, input down, input left, input right,
	input [9:0] hCount, vCount,
	output reg [11:0] rgb,
	output reg [11:0] background

   );
	wire block_fill;
	
	//these two values dictate the center of the block, incrementing and decrementing them leads the block to move in certain directions
	reg [9:0] xpos, ypos; 
	//2 values to dictate the current player's position in the matrix, to determine if they can move forward
	reg [9:0] currsquarex, currsquarey;
	
	parameter RED   = 12'b1111_0000_0000; //the end 
	parameter PURPLE = 12'b1111_0000_1111; //the character
	parameter GREEN = 12'b0000_1111_0000; //open path
	parameter BLUE = 12'b0000_0000_1111; //start
	parameter BLACK = 12'b0000_0000_0000; //maze walls
	parameter WHITE = 12'b1111_1111_1111; //background
	parameter RANDO = 12'b0011_0000_1111; //walls2
	
	wire [1:0] mazewall;
	
	reg [7:0] maze1 [0:9] [0:9];
	reg [7:0] maze2 [0:9] [0:9];
	reg [7:0] maze3 [0:9] [0:9];
	reg [7:0] maze4 [0:9] [0:9];

    reg [7:0] xloc, yloc;
	
	//stupid maze initialization
	initial begin
	   maze1[0][0] = 1;
	   maze1[0][1] = 2;
	   maze1[0][2] = 1;
	   maze1[0][3] = 1;
	   maze1[0][4] = 1;
	   maze1[0][5] = 1;
	   maze1[0][6] = 1;
	   maze1[0][7] = 1;
	   maze1[0][8] = 1;
	   maze1[0][9] = 1;
	   maze1[1][0] = 1;
	   maze1[1][1] = 0;
	   maze1[1][2] = 1;
	   maze1[1][3] = 1;
	   maze1[1][4] = 1;
	   maze1[1][5] = 1;
	   maze1[1][6] = 1;
	   maze1[1][7] = 1;
	   maze1[1][8] = 1;
	   maze1[1][9] = 1;
	   maze1[2][0] = 1;
	   maze1[2][1] = 0;
	   maze1[2][2] = 1;
	   maze1[2][3] = 0;
	   maze1[2][4] = 0;
	   maze1[2][5] = 0;
	   maze1[2][6] = 0;
	   maze1[2][7] = 0;
	   maze1[2][8] = 0;
	   maze1[2][9] = 1;
	   maze1[3][0] = 1;
	   maze1[3][1] = 0;
	   maze1[3][2] = 1;
	   maze1[3][3] = 0;
	   maze1[3][4] = 1;
	   maze1[3][5] = 1;
	   maze1[3][6] = 1;
	   maze1[3][7] = 1;
	   maze1[3][8] = 0;
	   maze1[3][9] = 1;
	   maze1[4][0] = 1;
	   maze1[4][1] = 0;
	   maze1[4][2] = 1;
	   maze1[4][3] = 0;
	   maze1[4][4] = 0;
	   maze1[4][5] = 0;
	   maze1[4][6] = 0;
	   maze1[4][7] = 1;
	   maze1[4][8] = 0;
	   maze1[4][9] = 1;
	   maze1[5][0] = 1;
	   maze1[5][1] = 0;
	   maze1[5][2] = 1;
	   maze1[5][3] = 1;
	   maze1[5][4] = 1;
	   maze1[5][5] = 0;
	   maze1[5][6] = 1;
	   maze1[5][7] = 1;
	   maze1[5][8] = 0;
	   maze1[5][9] = 1;
	   maze1[6][0] = 1;
	   maze1[6][1] = 0;
	   maze1[6][2] = 1;
	   maze1[6][3] = 1;
	   maze1[6][4] = 1;
	   maze1[6][5] = 0;
	   maze1[6][6] = 1;
	   maze1[6][7] = 1;
	   maze1[6][8] = 0;
	   maze1[6][9] = 1;
	   maze1[7][0] = 1;
	   maze1[7][1] = 0;
	   maze1[7][2] = 0;
	   maze1[7][3] = 0;
	   maze1[7][4] = 0;
	   maze1[7][5] = 0;
	   maze1[7][6] = 0;
	   maze1[7][7] = 0;
	   maze1[7][8] = 0;
	   maze1[7][9] = 1;
	   maze1[8][0] = 1;
	   maze1[8][1] = 1;
	   maze1[8][2] = 1;
	   maze1[8][3] = 1;
	   maze1[8][4] = 1;
	   maze1[8][5] = 1;
	   maze1[8][6] = 1;
	   maze1[8][7] = 1;
	   maze1[8][8] = 0;
	   maze1[8][9] = 1;
	   maze1[9][0] = 1;
	   maze1[9][1] = 1;
	   maze1[9][2] = 1;
	   maze1[9][3] = 1;
	   maze1[9][4] = 1;
	   maze1[9][5] = 1;
	   maze1[9][6] = 1;
	   maze1[9][7] = 1;
	   maze1[9][8] = 3;
	   maze1[9][9] = 1;
	   
	   maze2[0][0] = 1;
	   maze2[0][1] = 2;
	   maze2[0][2] = 1;
	   maze2[0][3] = 1;
	   maze2[0][4] = 1;
	   maze2[0][5] = 1;
	   maze2[0][6] = 1;
	   maze2[0][7] = 1;
	   maze2[0][8] = 1;
	   maze2[0][9] = 1;
	   maze2[1][0] = 1;
	   maze2[1][1] = 0;
	   maze2[1][2] = 0;
	   maze2[1][3] = 1;
	   maze2[1][4] = 1;
	   maze2[1][5] = 1;
	   maze2[1][6] = 1;
	   maze2[1][7] = 0;
	   maze2[1][8] = 0;
	   maze2[1][9] = 0;
	   maze2[2][0] = 1;
	   maze2[2][1] = 1;
	   maze2[2][2] = 0;
	   maze2[2][3] = 1;
	   maze2[2][4] = 1;
	   maze2[2][5] = 1;
	   maze2[2][6] = 1;
	   maze2[2][7] = 0;
	   maze2[2][8] = 1;
	   maze2[2][9] = 0;
	   maze2[3][0] = 1;
	   maze2[3][1] = 1;
	   maze2[3][2] = 0;
	   maze2[3][3] = 0;
	   maze2[3][4] = 1;
	   maze2[3][5] = 0;
	   maze2[3][6] = 1;
	   maze2[3][7] = 0;
	   maze2[3][8] = 1;
	   maze2[3][9] = 0;
	   maze2[4][0] = 1;
	   maze2[4][1] = 1;
	   maze2[4][2] = 1;
	   maze2[4][3] = 0;
	   maze2[4][4] = 1;
	   maze2[4][5] = 0;
	   maze2[4][6] = 1;
	   maze2[4][7] = 0;
	   maze2[4][8] = 1;
	   maze2[4][9] = 0;
	   maze2[5][0] = 1;
	   maze2[5][1] = 0;
	   maze2[5][2] = 0;
	   maze2[5][3] = 0;
	   maze2[5][4] = 1;
	   maze2[5][5] = 0;
	   maze2[5][6] = 0;
	   maze2[5][7] = 0;
	   maze2[5][8] = 1;
	   maze2[5][9] = 0;
	   maze2[6][0] = 1;
	   maze2[6][1] = 1;
	   maze2[6][2] = 0;
	   maze2[6][3] = 1;
	   maze2[6][4] = 1;
	   maze2[6][5] = 0;
	   maze2[6][6] = 1;
	   maze2[6][7] = 0;
	   maze2[6][8] = 1;
	   maze2[6][9] = 0;
	   maze2[7][0] = 1;
	   maze2[7][1] = 1;
	   maze2[7][2] = 0;
	   maze2[7][3] = 1;
	   maze2[7][4] = 1;
	   maze2[7][5] = 0;
	   maze2[7][6] = 1;
	   maze2[7][7] = 1;
	   maze2[7][8] = 1;
	   maze2[7][9] = 0;
	   maze2[8][0] = 1;
	   maze2[8][1] = 0;
	   maze2[8][2] = 0;
	   maze2[8][3] = 0;
	   maze2[8][4] = 0;
	   maze2[8][5] = 0;
	   maze2[8][6] = 1;
	   maze2[8][7] = 1;
	   maze2[8][8] = 0;
	   maze2[8][9] = 0;
	   maze2[9][0] = 1;
	   maze2[9][1] = 1;
	   maze2[9][2] = 1;
	   maze2[9][3] = 1;
	   maze2[9][4] = 1;
	   maze2[9][5] = 1;
	   maze2[9][6] = 1;
	   maze2[9][7] = 1;
	   maze2[9][8] = 3;
	   maze2[9][9] = 1;
	   
	   maze3[0][0] = 2;
	   maze3[0][1] = 1;
	   maze3[0][2] = 1;
	   maze3[0][3] = 1;
	   maze3[0][4] = 1;
	   maze3[0][5] = 1;
	   maze3[0][6] = 0;
	   maze3[0][7] = 0;
	   maze3[0][8] = 0;
	   maze3[0][9] = 1;
	   maze3[1][0] = 0;
	   maze3[1][1] = 0;
	   maze3[1][2] = 0;
	   maze3[1][3] = 0;
	   maze3[1][4] = 1;
	   maze3[1][5] = 0;
	   maze3[1][6] = 0;
	   maze3[1][7] = 1;
	   maze3[1][8] = 0;
	   maze3[1][9] = 1;
	   maze3[2][0] = 0;
	   maze3[2][1] = 1;
	   maze3[2][2] = 1;
	   maze3[2][3] = 0;
	   maze3[2][4] = 1;
	   maze3[2][5] = 0;
	   maze3[2][6] = 1;
	   maze3[2][7] = 1;
	   maze3[2][8] = 0;
	   maze3[2][9] = 1;
	   maze3[3][0] = 0;
	   maze3[3][1] = 1;
	   maze3[3][2] = 1;
	   maze3[3][3] = 0;
	   maze3[3][4] = 0;
	   maze3[3][5] = 0;
	   maze3[3][6] = 1;
	   maze3[3][7] = 0;
	   maze3[3][8] = 0;
	   maze3[3][9] = 1;
	   maze3[4][0] = 0;
	   maze3[4][1] = 1;
	   maze3[4][2] = 1;
	   maze3[4][3] = 0;
	   maze3[4][4] = 1;
	   maze3[4][5] = 1;
	   maze3[4][6] = 1;
	   maze3[4][7] = 1;
	   maze3[4][8] = 0;
	   maze3[4][9] = 0;
	   maze3[5][0] = 0;
	   maze3[5][1] = 1;
	   maze3[5][2] = 1;
	   maze3[5][3] = 0;
	   maze3[5][4] = 1;
	   maze3[5][5] = 0;
	   maze3[5][6] = 1;
	   maze3[5][7] = 0;
	   maze3[5][8] = 0;
	   maze3[5][9] = 1;
	   maze3[6][0] = 0;
	   maze3[6][1] = 0;
	   maze3[6][2] = 1;
	   maze3[6][3] = 1;
	   maze3[6][4] = 1;
	   maze3[6][5] = 0;
	   maze3[6][6] = 1;
	   maze3[6][7] = 0;
	   maze3[6][8] = 1;
	   maze3[6][9] = 1;
	   maze3[7][0] = 1;
	   maze3[7][1] = 0;
	   maze3[7][2] = 0;
	   maze3[7][3] = 0;
	   maze3[7][4] = 0;
	   maze3[7][5] = 0;
	   maze3[7][6] = 1;
	   maze3[7][7] = 0;
	   maze3[7][8] = 0;
	   maze3[7][9] = 1;
	   maze3[8][0] = 1;
	   maze3[8][1] = 1;
	   maze3[8][2] = 0;
	   maze3[8][3] = 1;
	   maze3[8][4] = 1;
	   maze3[8][5] = 1;
	   maze3[8][6] = 0;
	   maze3[8][7] = 1;
	   maze3[8][8] = 0;
	   maze3[8][9] = 0;
	   maze3[9][0] = 1;
	   maze3[9][1] = 0;
	   maze3[9][2] = 0;
	   maze3[9][3] = 0;
	   maze3[9][4] = 0;
	   maze3[9][5] = 0;
	   maze3[9][6] = 0;
	   maze3[9][7] = 1;
	   maze3[9][8] = 1;
	   maze3[9][9] = 3;
	   
	   maze4[0][0] = 1;
	   maze4[0][1] = 1;
	   maze4[0][2] = 1;
	   maze4[0][3] = 0;
	   maze4[0][4] = 1;
	   maze4[0][5] = 1;
	   maze4[0][6] = 1;
	   maze4[0][7] = 0;
	   maze4[0][8] = 0;
	   maze4[0][9] = 0;
	   maze4[1][0] = 0;
	   maze4[1][1] = 0;
	   maze4[1][2] = 0;
	   maze4[1][3] = 0;
	   maze4[1][4] = 1;
	   maze4[1][5] = 0;
	   maze4[1][6] = 1;
	   maze4[1][7] = 0;
	   maze4[1][8] = 1;
	   maze4[1][9] = 0;
	   maze4[2][0] = 0;
	   maze4[2][1] = 1;
	   maze4[2][2] = 0;
	   maze4[2][3] = 1;
	   maze4[2][4] = 1;
	   maze4[2][5] = 0;
	   maze4[2][6] = 1;
	   maze4[2][7] = 0;
	   maze4[2][8] = 1;
	   maze4[2][9] = 0;
	   maze4[3][0] = 0;
	   maze4[3][1] = 1;
	   maze4[3][2] = 0;
	   maze4[3][3] = 1;
	   maze4[3][4] = 1;
	   maze4[3][5] = 0;
	   maze4[3][6] = 1;
	   maze4[3][7] = 0;
	   maze4[3][8] = 1;
	   maze4[3][9] = 0;
	   maze4[4][0] = 0;
	   maze4[4][1] = 1;
	   maze4[4][2] = 0;
	   maze4[4][3] = 0;
	   maze4[4][4] = 0;
	   maze4[4][5] = 0;
	   maze4[4][6] = 1;
	   maze4[4][7] = 0;
	   maze4[4][8] = 1;
	   maze4[4][9] = 2;
	   maze4[5][0] = 0;
	   maze4[5][1] = 1;
	   maze4[5][2] = 0;
	   maze4[5][3] = 1;
	   maze4[5][4] = 1;
	   maze4[5][5] = 1;
	   maze4[5][6] = 1;
	   maze4[5][7] = 0;
	   maze4[5][8] = 1;
	   maze4[5][9] = 1;
	   maze4[6][0] = 0;
	   maze4[6][1] = 1;
	   maze4[6][2] = 0;
	   maze4[6][3] = 1;
	   maze4[6][4] = 1;
	   maze4[6][5] = 1;
	   maze4[6][6] = 0;
	   maze4[6][7] = 0;
	   maze4[6][8] = 0;
	   maze4[6][9] = 1;
	   maze4[7][0] = 0;
	   maze4[7][1] = 1;
	   maze4[7][2] = 0;
	   maze4[7][3] = 1;
	   maze4[7][4] = 1;
	   maze4[7][5] = 1;
	   maze4[7][6] = 0;
	   maze4[7][7] = 1;
	   maze4[7][8] = 0;
	   maze4[7][9] = 1;
	   maze4[8][0] = 0;
	   maze4[8][1] = 1;
	   maze4[8][2] = 0;
	   maze4[8][3] = 0;
	   maze4[8][4] = 0;
	   maze4[8][5] = 1;
	   maze4[8][6] = 0;
	   maze4[8][7] = 1;
	   maze4[8][8] = 0;
	   maze4[8][9] = 0;
	   maze4[9][0] = 3;
	   maze4[9][1] = 1;
	   maze4[9][2] = 1;
	   maze4[9][3] = 1;
	   maze4[9][4] = 0;
	   maze4[9][5] = 0;
	   maze4[9][6] = 0;
	   maze4[9][7] = 1;
	   maze4[9][8] = 1;
	   maze4[9][9] = 0;
	   
	end
	
	always@ (*) begin
    	if(~bright )	//force black if not inside the display area
			rgb = 12'b0000_0000_0000;
		else if (block_fill) 
			rgb = PURPLE; 
		else if (mazewall == 0)//path
		    rgb = GREEN; 
		else if (mazewall == 1)//wall
		    rgb = BLACK;
		else if (mazewall == 2)//startpoint
		    rgb = BLUE;
		else if (mazewall == 3)//endpoint
		    rgb = RED;
		else if (mazewall == 4)//nothing
		    rgb = WHITE;
		else
			rgb= background;
	end
	
	assign block_fill=vCount>=(ypos-5)&&vCount<=(ypos+5)&&hCount>=(xpos-5)&&hCount<=(xpos+5); //size of block player control

    reg go; //1 bit register //for checking if the wall is hit
    reg[1:0] maze_type = 2'b00;
    reg end_of_maze;
    reg[1:0] changed = 2'b00;

	always@(posedge clk, posedge rst) 
	begin
		if((rst)) //if a wall is hit or rese|| (go != 1)
		begin 
		    
			//rough values for start of maze
			xpos <= 241;
			ypos <= 108;
			maze_type <= changed;
			
			if(changed[1] == 1'b1 && changed[0] == 1'b0) begin
			    xpos <= 175;
			    ypos <= 108;
			end
			else if (changed[1] == 1'b1 && changed[0] == 1'b1) begin
			    xpos <= 752;
			    ypos <= 203;
			end
			
			
		end
		else if (clk) begin
		
		/* Note that the top left of the screen does NOT correlate to vCount=0 and hCount=0. The display_controller.v file has the 
			synchronizing pulses for both the horizontal sync and the vertical sync begin at vcount=0 and hcount=0. Recall that after 
			the length of the pulse, there is also a short period called the back porch before the display area begins. So effectively, 
			the top left corner corresponds to (hcount,vcount)~(144,35). Which means with a 640x480 resolution, the bottom right corner 
			corresponds to ~(783,515).  
		*/
			if(right) begin	
				if(go == 1)
				    xpos<=xpos+2; 
				else
				    xpos<=xpos;
			end
			else if(left) begin
				if(go == 1)
				    xpos<=xpos-2;
				else
				    xpos<=xpos;
			end
			else if(up) begin
				if(go == 1)
				    ypos<=ypos-2;
				else 
				    ypos<=ypos;
			end
			else if(down) begin
				if(go == 1)
				    ypos<=ypos+2;
				else
				    ypos<=ypos;
			end
			
			if(end_of_maze == 1) begin
		        changed <= maze_type + 1;
		    end
		end
	end
	
	reg [1:0] x;
	
	always @ *
	begin
	   if(maze_type == 0)begin
	       if(((hCount >= 10'd144) && (hCount <= 10'd208)) && ((vCount >= 10'd35) && (vCount <= 10'd88)))
               x = maze1[0][0];
           else if (((hCount >= 10'd209) && (hCount <= 10'd272)) && ((vCount >= 10'd35) && (vCount <= 10'd88)))
               x = maze1[0][1];
           else if (((hCount >= 10'd273) && (hCount <= 10'd336)) && ((vCount >= 10'd35) && (vCount <= 10'd88)))
               x = maze1[0][2];
           else if (((hCount >= 10'd337) && (hCount <= 10'd400)) && ((vCount >= 10'd35) && (vCount <= 10'd88)))
               x = maze1[0][3];
           else if (((hCount >= 10'd401) && (hCount <= 10'd464)) && ((vCount >= 10'd35) && (vCount <= 10'd88)))
               x = maze1[0][4];
           else if (((hCount >= 10'd465) && (hCount <= 10'd528)) && ((vCount >= 10'd35) && (vCount <= 10'd88)))
               x = maze1[0][5];
           else if (((hCount >= 10'd529) && (hCount <= 10'd592)) && ((vCount >= 10'd35) && (vCount <= 10'd88)))
               x = maze1[0][6];
           else if (((hCount >= 10'd593) && (hCount <= 10'd656)) && ((vCount >= 10'd35) && (vCount <= 10'd88)))
               x = maze1[0][7];
           else if (((hCount >= 10'd657) && (hCount <= 10'd720)) && ((vCount >= 10'd35) && (vCount <= 10'd88)))
               x = maze1[0][8];	   
           else if (((hCount >= 10'd721) && (hCount <= 10'd784)) && ((vCount >= 10'd35) && (vCount <= 10'd88)))
               x = maze1[0][9];
               
           else if(((hCount >= 10'd144) && (hCount <= 10'd208)) && ((vCount >= 10'd84) && (vCount <= 10'd131)))
               x = maze1[1][0];
           else if (((hCount >= 10'd209) && (hCount <= 10'd272)) && ((vCount >= 10'd84) && (vCount <= 10'd131)))
               x = maze1[1][1];
           else if (((hCount >= 10'd273) && (hCount <= 10'd336)) && ((vCount >= 10'd84) && (vCount <= 10'd131)))
               x = maze1[1][2];
           else if (((hCount >= 10'd337) && (hCount <= 10'd400)) && ((vCount >= 10'd84) && (vCount <= 10'd131)))
               x = maze1[1][3];
           else if (((hCount >= 10'd401) && (hCount <= 10'd464)) && ((vCount >= 10'd84) && (vCount <= 10'd131)))
               x = maze1[1][4];
           else if (((hCount >= 10'd465) && (hCount <= 10'd528)) && ((vCount >= 10'd84) && (vCount <= 10'd131)))
               x = maze1[1][5];
           else if (((hCount >= 10'd529) && (hCount <= 10'd592)) && ((vCount >= 10'd84) && (vCount <= 10'd131)))
               x = maze1[1][6];
           else if (((hCount >= 10'd593) && (hCount <= 10'd656)) && ((vCount >= 10'd84) && (vCount <= 10'd131)))
               x = maze1[1][7];
           else if (((hCount >= 10'd657) && (hCount <= 10'd720)) && ((vCount >= 10'd84) && (vCount <= 10'd131)))
               x = maze1[1][8];	   
           else if (((hCount >= 10'd721) && (hCount <= 10'd784)) && ((vCount >= 10'd84) && (vCount <= 10'd131)))
               x = maze1[1][9];
               
           else if(((hCount >= 10'd144) && (hCount <= 10'd208)) && ((vCount >= 10'd132) && (vCount <= 10'd179)))
               x = maze1[2][0];
           else if (((hCount >= 10'd209) && (hCount <= 10'd272)) && ((vCount >= 10'd132) && (vCount <= 10'd179)))
               x = maze1[2][1];
           else if (((hCount >= 10'd273) && (hCount <= 10'd336)) && ((vCount >= 10'd132) && (vCount <= 10'd179)))
               x = maze1[2][2];
           else if (((hCount >= 10'd337) && (hCount <= 10'd400)) && ((vCount >= 10'd132) && (vCount <= 10'd179)))
               x = maze1[2][3];
           else if (((hCount >= 10'd401) && (hCount <= 10'd464)) && ((vCount >= 10'd132) && (vCount <= 10'd179)))
               x = maze1[2][4];
           else if (((hCount >= 10'd465) && (hCount <= 10'd528)) && ((vCount >= 10'd132) && (vCount <= 10'd179)))
               x = maze1[2][5];
           else if (((hCount >= 10'd529) && (hCount <= 10'd592)) && ((vCount >= 10'd132) && (vCount <= 10'd179)))
               x = maze1[2][6];
           else if (((hCount >= 10'd593) && (hCount <= 10'd656)) && ((vCount >= 10'd132) && (vCount <= 10'd179)))
               x = maze1[2][7];
           else if (((hCount >= 10'd657) && (hCount <= 10'd720)) && ((vCount >= 10'd132) && (vCount <= 10'd179)))
               x = maze1[2][8];	   
           else if (((hCount >= 10'd721) && (hCount <= 10'd784)) && ((vCount >= 10'd132) && (vCount <= 10'd179)))
               x = maze1[2][9];	    
               
           else if(((hCount >= 10'd144) && (hCount <= 10'd208)) && ((vCount >= 10'd180) && (vCount <= 10'd227)))
               x = maze1[3][0];
           else if (((hCount >= 10'd209) && (hCount <= 10'd272)) && ((vCount >= 10'd180) && (vCount <= 10'd227)))
               x = maze1[3][1];
           else if (((hCount >= 10'd273) && (hCount <= 10'd336)) && ((vCount >= 10'd180) && (vCount <= 10'd227)))
               x = maze1[3][2];
           else if (((hCount >= 10'd337) && (hCount <= 10'd400)) && ((vCount >= 10'd180) && (vCount <= 10'd227)))
               x = maze1[3][3];
           else if (((hCount >= 10'd401) && (hCount <= 10'd464)) && ((vCount >= 10'd180) && (vCount <= 10'd227)))
               x = maze1[3][4];
           else if (((hCount >= 10'd465) && (hCount <= 10'd528)) && ((vCount >= 10'd180) && (vCount <= 10'd227)))
               x = maze1[3][5];
           else if (((hCount >= 10'd529) && (hCount <= 10'd592)) && ((vCount >= 10'd180) && (vCount <= 10'd227)))
               x = maze1[3][6];
           else if (((hCount >= 10'd593) && (hCount <= 10'd656)) && ((vCount >= 10'd180) && (vCount <= 10'd227)))
               x = maze1[3][7];
           else if (((hCount >= 10'd657) && (hCount <= 10'd720)) && ((vCount >= 10'd180) && (vCount <= 10'd227)))
               x = maze1[3][8];	   
           else if (((hCount >= 10'd721) && (hCount <= 10'd784)) && ((vCount >= 10'd180) && (vCount <= 10'd227)))
               x = maze1[3][9];
               
           else if(((hCount >= 10'd144) && (hCount <= 10'd208)) && ((vCount >= 10'd228) && (vCount <= 10'd275)))
               x = maze1[4][0];
           else if (((hCount >= 10'd209) && (hCount <= 10'd272)) && ((vCount >= 10'd228) && (vCount <= 10'd275)))
               x = maze1[4][1];
           else if (((hCount >= 10'd273) && (hCount <= 10'd336)) && ((vCount >= 10'd228) && (vCount <= 10'd275)))
               x = maze1[4][2];
           else if (((hCount >= 10'd337) && (hCount <= 10'd400)) && ((vCount >= 10'd228) && (vCount <= 10'd275)))
               x = maze1[4][3];
           else if (((hCount >= 10'd401) && (hCount <= 10'd464)) && ((vCount >= 10'd228) && (vCount <= 10'd275)))
               x = maze1[4][4];
           else if (((hCount >= 10'd465) && (hCount <= 10'd528)) && ((vCount >= 10'd228) && (vCount <= 10'd275)))
               x = maze1[4][5];
           else if (((hCount >= 10'd529) && (hCount <= 10'd592)) && ((vCount >= 10'd228) && (vCount <= 10'd275)))
               x = maze1[4][6];
           else if (((hCount >= 10'd593) && (hCount <= 10'd656)) && ((vCount >= 10'd228) && (vCount <= 10'd275)))
               x = maze1[4][7];
           else if (((hCount >= 10'd657) && (hCount <= 10'd720)) && ((vCount >= 10'd228) && (vCount <= 10'd275)))
               x = maze1[4][8];	   
           else if (((hCount >= 10'd721) && (hCount <= 10'd784)) && ((vCount >= 10'd228) && (vCount <= 10'd275)))
               x = maze1[4][9];      
           
           else if(((hCount >= 10'd144) && (hCount <= 10'd208)) && ((vCount >= 10'd276) && (vCount <= 10'd323)))
               x = maze1[5][0];
           else if (((hCount >= 10'd209) && (hCount <= 10'd272)) && ((vCount >= 10'd276) && (vCount <= 10'd323)))
               x = maze1[5][1];
           else if (((hCount >= 10'd273) && (hCount <= 10'd336)) && ((vCount >= 10'd276) && (vCount <= 10'd323)))
               x = maze1[5][2];
           else if (((hCount >= 10'd337) && (hCount <= 10'd400)) && ((vCount >= 10'd276) && (vCount <= 10'd323)))
               x = maze1[5][3];
           else if (((hCount >= 10'd401) && (hCount <= 10'd464)) && ((vCount >= 10'd276) && (vCount <= 10'd323)))
               x = maze1[5][4];
           else if (((hCount >= 10'd465) && (hCount <= 10'd528)) && ((vCount >= 10'd276) && (vCount <= 10'd323)))
               x = maze1[5][5];
           else if (((hCount >= 10'd529) && (hCount <= 10'd592)) && ((vCount >= 10'd276) && (vCount <= 10'd323)))
               x = maze1[5][6];
           else if (((hCount >= 10'd593) && (hCount <= 10'd656)) && ((vCount >= 10'd276) && (vCount <= 10'd323)))
               x = maze1[5][7];
           else if (((hCount >= 10'd657) && (hCount <= 10'd720)) && ((vCount >= 10'd276) && (vCount <= 10'd323)))
               x = maze1[5][8];	   
           else if (((hCount >= 10'd721) && (hCount <= 10'd784)) && ((vCount >= 10'd276) && (vCount <= 10'd323)))
               x = maze1[5][9];   
               
           else if(((hCount >= 10'd144) && (hCount <= 10'd208)) && ((vCount >= 10'd324) && (vCount <= 10'd371)))
               x = maze1[6][0];
           else if (((hCount >= 10'd209) && (hCount <= 10'd272)) && ((vCount >= 10'd324) && (vCount <= 10'd371)))
               x = maze1[6][1];
           else if (((hCount >= 10'd273) && (hCount <= 10'd336)) && ((vCount >= 10'd324) && (vCount <= 10'd371)))
               x = maze1[6][2];
           else if (((hCount >= 10'd337) && (hCount <= 10'd400)) && ((vCount >= 10'd324) && (vCount <= 10'd371)))
               x = maze1[6][3];
           else if (((hCount >= 10'd401) && (hCount <= 10'd464)) && ((vCount >= 10'd324) && (vCount <= 10'd371)))
               x = maze1[6][4];
           else if (((hCount >= 10'd465) && (hCount <= 10'd528)) && ((vCount >= 10'd324) && (vCount <= 10'd371)))
               x = maze1[6][5];
           else if (((hCount >= 10'd529) && (hCount <= 10'd592)) && ((vCount >= 10'd324) && (vCount <= 10'd371)))
               x = maze1[6][6];
           else if (((hCount >= 10'd593) && (hCount <= 10'd656)) && ((vCount >= 10'd324) && (vCount <= 10'd371)))
               x = maze1[6][7];
           else if (((hCount >= 10'd657) && (hCount <= 10'd720)) && ((vCount >= 10'd324) && (vCount <= 10'd371)))
               x = maze1[6][8];	   
           else if (((hCount >= 10'd721) && (hCount <= 10'd784)) && ((vCount >= 10'd324) && (vCount <= 10'd371)))
               x = maze1[6][9];
               
           else if(((hCount >= 10'd144) && (hCount <= 10'd208)) && ((vCount >= 10'd372) && (vCount <= 10'd419)))
               x = maze1[7][0];
           else if (((hCount >= 10'd209) && (hCount <= 10'd272)) && ((vCount >= 10'd372) && (vCount <= 10'd419)))
               x = maze1[7][1];
           else if (((hCount >= 10'd273) && (hCount <= 10'd336)) && ((vCount >= 10'd372) && (vCount <= 10'd419)))
               x = maze1[7][2];
           else if (((hCount >= 10'd337) && (hCount <= 10'd400)) && ((vCount >= 10'd372) && (vCount <= 10'd419)))
               x = maze1[7][3];
           else if (((hCount >= 10'd401) && (hCount <= 10'd464)) && ((vCount >= 10'd372) && (vCount <= 10'd419)))
               x = maze1[7][4];
           else if (((hCount >= 10'd465) && (hCount <= 10'd528)) && ((vCount >= 10'd372) && (vCount <= 10'd419)))
               x = maze1[7][5];
           else if (((hCount >= 10'd529) && (hCount <= 10'd592)) && ((vCount >= 10'd372) && (vCount <= 10'd419)))
               x = maze1[7][6];
           else if (((hCount >= 10'd593) && (hCount <= 10'd656)) && ((vCount >= 10'd372) && (vCount <= 10'd419)))
               x = maze1[7][7];
           else if (((hCount >= 10'd657) && (hCount <= 10'd720)) && ((vCount >= 10'd372) && (vCount <= 10'd419)))
               x = maze1[7][8];	   
           else if (((hCount >= 10'd721) && (hCount <= 10'd784)) && ((vCount >= 10'd372) && (vCount <= 10'd419)))
               x = maze1[7][9];
               
           else if(((hCount >= 10'd144) && (hCount <= 10'd208)) && ((vCount >= 10'd420) && (vCount <= 10'd467)))
               x = maze1[8][0];
           else if (((hCount >= 10'd209) && (hCount <= 10'd272)) && ((vCount >= 10'd420) && (vCount <= 10'd467)))
               x = maze1[8][1];
           else if (((hCount >= 10'd273) && (hCount <= 10'd336)) && ((vCount >= 10'd420) && (vCount <= 10'd467)))
               x = maze1[8][2];
           else if (((hCount >= 10'd337) && (hCount <= 10'd400)) && ((vCount >= 10'd420) && (vCount <= 10'd467)))
               x = maze1[8][3];
           else if (((hCount >= 10'd401) && (hCount <= 10'd464)) && ((vCount >= 10'd420) && (vCount <= 10'd467)))
               x = maze1[8][4];
           else if (((hCount >= 10'd465) && (hCount <= 10'd528)) && ((vCount >= 10'd420) && (vCount <= 10'd467)))
               x = maze1[8][5];
           else if (((hCount >= 10'd529) && (hCount <= 10'd592)) && ((vCount >= 10'd420) && (vCount <= 10'd467)))
               x = maze1[8][6];
           else if (((hCount >= 10'd593) && (hCount <= 10'd656)) && ((vCount >= 10'd420) && (vCount <= 10'd467)))
               x = maze1[8][7];
           else if (((hCount >= 10'd657) && (hCount <= 10'd720)) && ((vCount >= 10'd420) && (vCount <= 10'd467)))
               x = maze1[8][8];	   
           else if (((hCount >= 10'd721) && (hCount <= 10'd784)) && ((vCount >= 10'd420) && (vCount <= 10'd467)))
               x = maze1[8][9];
           
           else if(((hCount >= 10'd144) && (hCount <= 10'd208)) && ((vCount >= 10'd468) && (vCount <= 10'd516)))
               x = maze1[9][0];
           else if (((hCount >= 10'd209) && (hCount <= 10'd272)) && ((vCount >= 10'd468) && (vCount <= 10'd516)))
               x = maze1[9][1];
           else if (((hCount >= 10'd273) && (hCount <= 10'd336)) && ((vCount >= 10'd468) && (vCount <= 10'd516)))
               x = maze1[9][2];
           else if (((hCount >= 10'd337) && (hCount <= 10'd400)) && ((vCount >= 10'd468) && (vCount <= 10'd516)))
               x = maze1[9][3];
           else if (((hCount >= 10'd401) && (hCount <= 10'd464)) && ((vCount >= 10'd468) && (vCount <= 10'd516)))
               x = maze1[9][4];
           else if (((hCount >= 10'd465) && (hCount <= 10'd528)) && ((vCount >= 10'd468) && (vCount <= 10'd516)))
               x = maze1[9][5];
           else if (((hCount >= 10'd529) && (hCount <= 10'd592)) && ((vCount >= 10'd468) && (vCount <= 10'd516)))
               x = maze1[9][6];
           else if (((hCount >= 10'd593) && (hCount <= 10'd656)) && ((vCount >= 10'd468) && (vCount <= 10'd516)))
               x = maze1[9][7];
           else if (((hCount >= 10'd657) && (hCount <= 10'd720)) && ((vCount >= 10'd468) && (vCount <= 10'd516)))
               x = maze1[9][8];	   
           else if (((hCount >= 10'd721) && (hCount <= 10'd784)) && ((vCount >= 10'd468) && (vCount <= 10'd516)))
               x = maze1[9][9];
           else
               x = 3;
       end
       else if (maze_type == 1) begin
           if(((hCount >= 10'd144) && (hCount <= 10'd208)) && ((vCount >= 10'd35) && (vCount <= 10'd88)))
               x = maze2[0][0];
           else if (((hCount >= 10'd209) && (hCount <= 10'd272)) && ((vCount >= 10'd35) && (vCount <= 10'd88)))
               x = maze2[0][1];
           else if (((hCount >= 10'd273) && (hCount <= 10'd336)) && ((vCount >= 10'd35) && (vCount <= 10'd88)))
               x = maze2[0][2];
           else if (((hCount >= 10'd337) && (hCount <= 10'd400)) && ((vCount >= 10'd35) && (vCount <= 10'd88)))
               x = maze2[0][3];
           else if (((hCount >= 10'd401) && (hCount <= 10'd464)) && ((vCount >= 10'd35) && (vCount <= 10'd88)))
               x = maze2[0][4];
           else if (((hCount >= 10'd465) && (hCount <= 10'd528)) && ((vCount >= 10'd35) && (vCount <= 10'd88)))
               x = maze2[0][5];
           else if (((hCount >= 10'd529) && (hCount <= 10'd592)) && ((vCount >= 10'd35) && (vCount <= 10'd88)))
               x = maze2[0][6];
           else if (((hCount >= 10'd593) && (hCount <= 10'd656)) && ((vCount >= 10'd35) && (vCount <= 10'd88)))
               x = maze2[0][7];
           else if (((hCount >= 10'd657) && (hCount <= 10'd720)) && ((vCount >= 10'd35) && (vCount <= 10'd88)))
               x = maze2[0][8];	   
           else if (((hCount >= 10'd721) && (hCount <= 10'd784)) && ((vCount >= 10'd35) && (vCount <= 10'd88)))
               x = maze2[0][9];
               
           else if(((hCount >= 10'd144) && (hCount <= 10'd208)) && ((vCount >= 10'd84) && (vCount <= 10'd131)))
               x = maze2[1][0];
           else if (((hCount >= 10'd209) && (hCount <= 10'd272)) && ((vCount >= 10'd84) && (vCount <= 10'd131)))
               x = maze2[1][1];
           else if (((hCount >= 10'd273) && (hCount <= 10'd336)) && ((vCount >= 10'd84) && (vCount <= 10'd131)))
               x = maze2[1][2];
           else if (((hCount >= 10'd337) && (hCount <= 10'd400)) && ((vCount >= 10'd84) && (vCount <= 10'd131)))
               x = maze2[1][3];
           else if (((hCount >= 10'd401) && (hCount <= 10'd464)) && ((vCount >= 10'd84) && (vCount <= 10'd131)))
               x = maze2[1][4];
           else if (((hCount >= 10'd465) && (hCount <= 10'd528)) && ((vCount >= 10'd84) && (vCount <= 10'd131)))
               x = maze2[1][5];
           else if (((hCount >= 10'd529) && (hCount <= 10'd592)) && ((vCount >= 10'd84) && (vCount <= 10'd131)))
               x = maze2[1][6];
           else if (((hCount >= 10'd593) && (hCount <= 10'd656)) && ((vCount >= 10'd84) && (vCount <= 10'd131)))
               x = maze2[1][7];
           else if (((hCount >= 10'd657) && (hCount <= 10'd720)) && ((vCount >= 10'd84) && (vCount <= 10'd131)))
               x = maze2[1][8];	   
           else if (((hCount >= 10'd721) && (hCount <= 10'd784)) && ((vCount >= 10'd84) && (vCount <= 10'd131)))
               x = maze2[1][9];
              
           else if(((hCount >= 10'd144) && (hCount <= 10'd208)) && ((vCount >= 10'd132) && (vCount <= 10'd179)))
               x = maze2[2][0];
           else if (((hCount >= 10'd209) && (hCount <= 10'd272)) && ((vCount >= 10'd132) && (vCount <= 10'd179)))
               x = maze2[2][1];
           else if (((hCount >= 10'd273) && (hCount <= 10'd336)) && ((vCount >= 10'd132) && (vCount <= 10'd179)))
               x = maze2[2][2];
           else if (((hCount >= 10'd337) && (hCount <= 10'd400)) && ((vCount >= 10'd132) && (vCount <= 10'd179)))
               x = maze2[2][3];
           else if (((hCount >= 10'd401) && (hCount <= 10'd464)) && ((vCount >= 10'd132) && (vCount <= 10'd179)))
               x = maze2[2][4];
           else if (((hCount >= 10'd465) && (hCount <= 10'd528)) && ((vCount >= 10'd132) && (vCount <= 10'd179)))
               x = maze2[2][5];
           else if (((hCount >= 10'd529) && (hCount <= 10'd592)) && ((vCount >= 10'd132) && (vCount <= 10'd179)))
               x = maze2[2][6];
           else if (((hCount >= 10'd593) && (hCount <= 10'd656)) && ((vCount >= 10'd132) && (vCount <= 10'd179)))
               x = maze2[2][7];
           else if (((hCount >= 10'd657) && (hCount <= 10'd720)) && ((vCount >= 10'd132) && (vCount <= 10'd179)))
               x = maze2[2][8];	   
           else if (((hCount >= 10'd721) && (hCount <= 10'd784)) && ((vCount >= 10'd132) && (vCount <= 10'd179)))
               x = maze2[2][9];	    
               
           else if(((hCount >= 10'd144) && (hCount <= 10'd208)) && ((vCount >= 10'd180) && (vCount <= 10'd227)))
               x = maze2[3][0];
           else if (((hCount >= 10'd209) && (hCount <= 10'd272)) && ((vCount >= 10'd180) && (vCount <= 10'd227)))
               x = maze2[3][1];
           else if (((hCount >= 10'd273) && (hCount <= 10'd336)) && ((vCount >= 10'd180) && (vCount <= 10'd227)))
               x = maze2[3][2];
           else if (((hCount >= 10'd337) && (hCount <= 10'd400)) && ((vCount >= 10'd180) && (vCount <= 10'd227)))
               x = maze2[3][3];
           else if (((hCount >= 10'd401) && (hCount <= 10'd464)) && ((vCount >= 10'd180) && (vCount <= 10'd227)))
               x = maze2[3][4];
           else if (((hCount >= 10'd465) && (hCount <= 10'd528)) && ((vCount >= 10'd180) && (vCount <= 10'd227)))
               x = maze2[3][5];
           else if (((hCount >= 10'd529) && (hCount <= 10'd592)) && ((vCount >= 10'd180) && (vCount <= 10'd227)))
               x = maze2[3][6];
           else if (((hCount >= 10'd593) && (hCount <= 10'd656)) && ((vCount >= 10'd180) && (vCount <= 10'd227)))
               x = maze2[3][7];
           else if (((hCount >= 10'd657) && (hCount <= 10'd720)) && ((vCount >= 10'd180) && (vCount <= 10'd227)))
               x = maze2[3][8];	   
           else if (((hCount >= 10'd721) && (hCount <= 10'd784)) && ((vCount >= 10'd180) && (vCount <= 10'd227)))
               x = maze2[3][9];
               
           else if(((hCount >= 10'd144) && (hCount <= 10'd208)) && ((vCount >= 10'd228) && (vCount <= 10'd275)))
               x = maze2[4][0];
           else if (((hCount >= 10'd209) && (hCount <= 10'd272)) && ((vCount >= 10'd228) && (vCount <= 10'd275)))
               x = maze2[4][1];
           else if (((hCount >= 10'd273) && (hCount <= 10'd336)) && ((vCount >= 10'd228) && (vCount <= 10'd275)))
               x = maze2[4][2];
           else if (((hCount >= 10'd337) && (hCount <= 10'd400)) && ((vCount >= 10'd228) && (vCount <= 10'd275)))
               x = maze2[4][3];
           else if (((hCount >= 10'd401) && (hCount <= 10'd464)) && ((vCount >= 10'd228) && (vCount <= 10'd275)))
               x = maze2[4][4];
           else if (((hCount >= 10'd465) && (hCount <= 10'd528)) && ((vCount >= 10'd228) && (vCount <= 10'd275)))
               x = maze2[4][5];
           else if (((hCount >= 10'd529) && (hCount <= 10'd592)) && ((vCount >= 10'd228) && (vCount <= 10'd275)))
               x = maze2[4][6];
           else if (((hCount >= 10'd593) && (hCount <= 10'd656)) && ((vCount >= 10'd228) && (vCount <= 10'd275)))
               x = maze2[4][7];
           else if (((hCount >= 10'd657) && (hCount <= 10'd720)) && ((vCount >= 10'd228) && (vCount <= 10'd275)))
               x = maze2[4][8];	   
           else if (((hCount >= 10'd721) && (hCount <= 10'd784)) && ((vCount >= 10'd228) && (vCount <= 10'd275)))
               x = maze2[4][9];      
           
           else if(((hCount >= 10'd144) && (hCount <= 10'd208)) && ((vCount >= 10'd276) && (vCount <= 10'd323)))
               x = maze2[5][0];
           else if (((hCount >= 10'd209) && (hCount <= 10'd272)) && ((vCount >= 10'd276) && (vCount <= 10'd323)))
               x = maze2[5][1];
           else if (((hCount >= 10'd273) && (hCount <= 10'd336)) && ((vCount >= 10'd276) && (vCount <= 10'd323)))
               x = maze2[5][2];
           else if (((hCount >= 10'd337) && (hCount <= 10'd400)) && ((vCount >= 10'd276) && (vCount <= 10'd323)))
               x = maze2[5][3];
           else if (((hCount >= 10'd401) && (hCount <= 10'd464)) && ((vCount >= 10'd276) && (vCount <= 10'd323)))
               x = maze2[5][4];
           else if (((hCount >= 10'd465) && (hCount <= 10'd528)) && ((vCount >= 10'd276) && (vCount <= 10'd323)))
               x = maze2[5][5];
           else if (((hCount >= 10'd529) && (hCount <= 10'd592)) && ((vCount >= 10'd276) && (vCount <= 10'd323)))
               x = maze2[5][6];
           else if (((hCount >= 10'd593) && (hCount <= 10'd656)) && ((vCount >= 10'd276) && (vCount <= 10'd323)))
               x = maze2[5][7];
           else if (((hCount >= 10'd657) && (hCount <= 10'd720)) && ((vCount >= 10'd276) && (vCount <= 10'd323)))
               x = maze2[5][8];	   
           else if (((hCount >= 10'd721) && (hCount <= 10'd784)) && ((vCount >= 10'd276) && (vCount <= 10'd323)))
               x = maze2[5][9];   
               
           else if(((hCount >= 10'd144) && (hCount <= 10'd208)) && ((vCount >= 10'd324) && (vCount <= 10'd371)))
               x = maze2[6][0];
           else if (((hCount >= 10'd209) && (hCount <= 10'd272)) && ((vCount >= 10'd324) && (vCount <= 10'd371)))
               x = maze2[6][1];
           else if (((hCount >= 10'd273) && (hCount <= 10'd336)) && ((vCount >= 10'd324) && (vCount <= 10'd371)))
               x = maze2[6][2];
           else if (((hCount >= 10'd337) && (hCount <= 10'd400)) && ((vCount >= 10'd324) && (vCount <= 10'd371)))
               x = maze2[6][3];
           else if (((hCount >= 10'd401) && (hCount <= 10'd464)) && ((vCount >= 10'd324) && (vCount <= 10'd371)))
               x = maze2[6][4];
           else if (((hCount >= 10'd465) && (hCount <= 10'd528)) && ((vCount >= 10'd324) && (vCount <= 10'd371)))
               x = maze2[6][5];
           else if (((hCount >= 10'd529) && (hCount <= 10'd592)) && ((vCount >= 10'd324) && (vCount <= 10'd371)))
               x = maze2[6][6];
           else if (((hCount >= 10'd593) && (hCount <= 10'd656)) && ((vCount >= 10'd324) && (vCount <= 10'd371)))
               x = maze2[6][7];
           else if (((hCount >= 10'd657) && (hCount <= 10'd720)) && ((vCount >= 10'd324) && (vCount <= 10'd371)))
               x = maze2[6][8];	   
           else if (((hCount >= 10'd721) && (hCount <= 10'd784)) && ((vCount >= 10'd324) && (vCount <= 10'd371)))
               x = maze2[6][9];
              
           else if(((hCount >= 10'd144) && (hCount <= 10'd208)) && ((vCount >= 10'd372) && (vCount <= 10'd419)))
               x = maze2[7][0];
           else if (((hCount >= 10'd209) && (hCount <= 10'd272)) && ((vCount >= 10'd372) && (vCount <= 10'd419)))
               x = maze2[7][1];
           else if (((hCount >= 10'd273) && (hCount <= 10'd336)) && ((vCount >= 10'd372) && (vCount <= 10'd419)))
               x = maze2[7][2];
           else if (((hCount >= 10'd337) && (hCount <= 10'd400)) && ((vCount >= 10'd372) && (vCount <= 10'd419)))
               x = maze2[7][3];
           else if (((hCount >= 10'd401) && (hCount <= 10'd464)) && ((vCount >= 10'd372) && (vCount <= 10'd419)))
               x = maze2[7][4];
           else if (((hCount >= 10'd465) && (hCount <= 10'd528)) && ((vCount >= 10'd372) && (vCount <= 10'd419)))
               x = maze2[7][5];
           else if (((hCount >= 10'd529) && (hCount <= 10'd592)) && ((vCount >= 10'd372) && (vCount <= 10'd419)))
               x = maze2[7][6];
           else if (((hCount >= 10'd593) && (hCount <= 10'd656)) && ((vCount >= 10'd372) && (vCount <= 10'd419)))
               x = maze2[7][7];
           else if (((hCount >= 10'd657) && (hCount <= 10'd720)) && ((vCount >= 10'd372) && (vCount <= 10'd419)))
               x = maze2[7][8];	   
           else if (((hCount >= 10'd721) && (hCount <= 10'd784)) && ((vCount >= 10'd372) && (vCount <= 10'd419)))
               x = maze2[7][9];
              
           else if(((hCount >= 10'd144) && (hCount <= 10'd208)) && ((vCount >= 10'd420) && (vCount <= 10'd467)))
               x = maze2[8][0];
           else if (((hCount >= 10'd209) && (hCount <= 10'd272)) && ((vCount >= 10'd420) && (vCount <= 10'd467)))
               x = maze2[8][1];
           else if (((hCount >= 10'd273) && (hCount <= 10'd336)) && ((vCount >= 10'd420) && (vCount <= 10'd467)))
               x = maze2[8][2];
           else if (((hCount >= 10'd337) && (hCount <= 10'd400)) && ((vCount >= 10'd420) && (vCount <= 10'd467)))
               x = maze2[8][3];
           else if (((hCount >= 10'd401) && (hCount <= 10'd464)) && ((vCount >= 10'd420) && (vCount <= 10'd467)))
               x = maze2[8][4];
           else if (((hCount >= 10'd465) && (hCount <= 10'd528)) && ((vCount >= 10'd420) && (vCount <= 10'd467)))
               x = maze2[8][5];
           else if (((hCount >= 10'd529) && (hCount <= 10'd592)) && ((vCount >= 10'd420) && (vCount <= 10'd467)))
               x = maze2[8][6];
           else if (((hCount >= 10'd593) && (hCount <= 10'd656)) && ((vCount >= 10'd420) && (vCount <= 10'd467)))
               x = maze2[8][7];
           else if (((hCount >= 10'd657) && (hCount <= 10'd720)) && ((vCount >= 10'd420) && (vCount <= 10'd467)))
               x = maze2[8][8];	   
           else if (((hCount >= 10'd721) && (hCount <= 10'd784)) && ((vCount >= 10'd420) && (vCount <= 10'd467)))
               x = maze2[8][9];
           
           else if(((hCount >= 10'd144) && (hCount <= 10'd208)) && ((vCount >= 10'd468) && (vCount <= 10'd516)))
               x = maze2[9][0];
           else if (((hCount >= 10'd209) && (hCount <= 10'd272)) && ((vCount >= 10'd468) && (vCount <= 10'd516)))
               x = maze2[9][1];
           else if (((hCount >= 10'd273) && (hCount <= 10'd336)) && ((vCount >= 10'd468) && (vCount <= 10'd516)))
               x = maze2[9][2];
           else if (((hCount >= 10'd337) && (hCount <= 10'd400)) && ((vCount >= 10'd468) && (vCount <= 10'd516)))
               x = maze2[9][3];
           else if (((hCount >= 10'd401) && (hCount <= 10'd464)) && ((vCount >= 10'd468) && (vCount <= 10'd516)))
               x = maze2[9][4];
           else if (((hCount >= 10'd465) && (hCount <= 10'd528)) && ((vCount >= 10'd468) && (vCount <= 10'd516)))
               x = maze2[9][5];
           else if (((hCount >= 10'd529) && (hCount <= 10'd592)) && ((vCount >= 10'd468) && (vCount <= 10'd516)))
               x = maze2[9][6];
           else if (((hCount >= 10'd593) && (hCount <= 10'd656)) && ((vCount >= 10'd468) && (vCount <= 10'd516)))
               x = maze2[9][7];
           else if (((hCount >= 10'd657) && (hCount <= 10'd720)) && ((vCount >= 10'd468) && (vCount <= 10'd516)))
               x = maze2[9][8];	   
           else if (((hCount >= 10'd721) && (hCount <= 10'd784)) && ((vCount >= 10'd468) && (vCount <= 10'd516)))
               x = maze2[9][9];
           else
               x = 3;
       end
       else if (maze_type == 2) begin
           if(((hCount >= 10'd144) && (hCount <= 10'd208)) && ((vCount >= 10'd35) && (vCount <= 10'd88)))
               x = maze3[0][0];
           else if (((hCount >= 10'd209) && (hCount <= 10'd272)) && ((vCount >= 10'd35) && (vCount <= 10'd88)))
               x = maze3[0][1];
           else if (((hCount >= 10'd273) && (hCount <= 10'd336)) && ((vCount >= 10'd35) && (vCount <= 10'd88)))
               x = maze3[0][2];
           else if (((hCount >= 10'd337) && (hCount <= 10'd400)) && ((vCount >= 10'd35) && (vCount <= 10'd88)))
               x = maze3[0][3];
           else if (((hCount >= 10'd401) && (hCount <= 10'd464)) && ((vCount >= 10'd35) && (vCount <= 10'd88)))
               x = maze3[0][4];
           else if (((hCount >= 10'd465) && (hCount <= 10'd528)) && ((vCount >= 10'd35) && (vCount <= 10'd88)))
               x = maze3[0][5];
           else if (((hCount >= 10'd529) && (hCount <= 10'd592)) && ((vCount >= 10'd35) && (vCount <= 10'd88)))
               x = maze3[0][6];
           else if (((hCount >= 10'd593) && (hCount <= 10'd656)) && ((vCount >= 10'd35) && (vCount <= 10'd88)))
               x = maze3[0][7];
           else if (((hCount >= 10'd657) && (hCount <= 10'd720)) && ((vCount >= 10'd35) && (vCount <= 10'd88)))
               x = maze3[0][8];	   
           else if (((hCount >= 10'd721) && (hCount <= 10'd784)) && ((vCount >= 10'd35) && (vCount <= 10'd88)))
               x = maze3[0][9];
               
           else if(((hCount >= 10'd144) && (hCount <= 10'd208)) && ((vCount >= 10'd84) && (vCount <= 10'd131)))
               x = maze3[1][0];
           else if (((hCount >= 10'd209) && (hCount <= 10'd272)) && ((vCount >= 10'd84) && (vCount <= 10'd131)))
               x = maze3[1][1];
           else if (((hCount >= 10'd273) && (hCount <= 10'd336)) && ((vCount >= 10'd84) && (vCount <= 10'd131)))
               x = maze3[1][2];
           else if (((hCount >= 10'd337) && (hCount <= 10'd400)) && ((vCount >= 10'd84) && (vCount <= 10'd131)))
               x = maze3[1][3];
           else if (((hCount >= 10'd401) && (hCount <= 10'd464)) && ((vCount >= 10'd84) && (vCount <= 10'd131)))
               x = maze3[1][4];
           else if (((hCount >= 10'd465) && (hCount <= 10'd528)) && ((vCount >= 10'd84) && (vCount <= 10'd131)))
               x = maze3[1][5];
           else if (((hCount >= 10'd529) && (hCount <= 10'd592)) && ((vCount >= 10'd84) && (vCount <= 10'd131)))
               x = maze3[1][6];
           else if (((hCount >= 10'd593) && (hCount <= 10'd656)) && ((vCount >= 10'd84) && (vCount <= 10'd131)))
               x = maze3[1][7];
           else if (((hCount >= 10'd657) && (hCount <= 10'd720)) && ((vCount >= 10'd84) && (vCount <= 10'd131)))
               x = maze3[1][8];	   
           else if (((hCount >= 10'd721) && (hCount <= 10'd784)) && ((vCount >= 10'd84) && (vCount <= 10'd131)))
               x = maze3[1][9];
              
           else if(((hCount >= 10'd144) && (hCount <= 10'd208)) && ((vCount >= 10'd132) && (vCount <= 10'd179)))
               x = maze3[2][0];
           else if (((hCount >= 10'd209) && (hCount <= 10'd272)) && ((vCount >= 10'd132) && (vCount <= 10'd179)))
               x = maze3[2][1];
           else if (((hCount >= 10'd273) && (hCount <= 10'd336)) && ((vCount >= 10'd132) && (vCount <= 10'd179)))
               x = maze3[2][2];
           else if (((hCount >= 10'd337) && (hCount <= 10'd400)) && ((vCount >= 10'd132) && (vCount <= 10'd179)))
               x = maze3[2][3];
           else if (((hCount >= 10'd401) && (hCount <= 10'd464)) && ((vCount >= 10'd132) && (vCount <= 10'd179)))
               x = maze3[2][4];
           else if (((hCount >= 10'd465) && (hCount <= 10'd528)) && ((vCount >= 10'd132) && (vCount <= 10'd179)))
               x = maze3[2][5];
           else if (((hCount >= 10'd529) && (hCount <= 10'd592)) && ((vCount >= 10'd132) && (vCount <= 10'd179)))
               x = maze3[2][6];
           else if (((hCount >= 10'd593) && (hCount <= 10'd656)) && ((vCount >= 10'd132) && (vCount <= 10'd179)))
               x = maze3[2][7];
           else if (((hCount >= 10'd657) && (hCount <= 10'd720)) && ((vCount >= 10'd132) && (vCount <= 10'd179)))
               x = maze3[2][8];	   
           else if (((hCount >= 10'd721) && (hCount <= 10'd784)) && ((vCount >= 10'd132) && (vCount <= 10'd179)))
               x = maze3[2][9];	    
               
           else if(((hCount >= 10'd144) && (hCount <= 10'd208)) && ((vCount >= 10'd180) && (vCount <= 10'd227)))
               x = maze3[3][0];
           else if (((hCount >= 10'd209) && (hCount <= 10'd272)) && ((vCount >= 10'd180) && (vCount <= 10'd227)))
               x = maze3[3][1];
           else if (((hCount >= 10'd273) && (hCount <= 10'd336)) && ((vCount >= 10'd180) && (vCount <= 10'd227)))
               x = maze3[3][2];
           else if (((hCount >= 10'd337) && (hCount <= 10'd400)) && ((vCount >= 10'd180) && (vCount <= 10'd227)))
               x = maze3[3][3];
           else if (((hCount >= 10'd401) && (hCount <= 10'd464)) && ((vCount >= 10'd180) && (vCount <= 10'd227)))
               x = maze3[3][4];
           else if (((hCount >= 10'd465) && (hCount <= 10'd528)) && ((vCount >= 10'd180) && (vCount <= 10'd227)))
               x = maze3[3][5];
           else if (((hCount >= 10'd529) && (hCount <= 10'd592)) && ((vCount >= 10'd180) && (vCount <= 10'd227)))
               x = maze3[3][6];
           else if (((hCount >= 10'd593) && (hCount <= 10'd656)) && ((vCount >= 10'd180) && (vCount <= 10'd227)))
               x = maze3[3][7];
           else if (((hCount >= 10'd657) && (hCount <= 10'd720)) && ((vCount >= 10'd180) && (vCount <= 10'd227)))
               x = maze3[3][8];	   
           else if (((hCount >= 10'd721) && (hCount <= 10'd784)) && ((vCount >= 10'd180) && (vCount <= 10'd227)))
               x = maze3[3][9];
               
           else if(((hCount >= 10'd144) && (hCount <= 10'd208)) && ((vCount >= 10'd228) && (vCount <= 10'd275)))
               x = maze3[4][0];
           else if (((hCount >= 10'd209) && (hCount <= 10'd272)) && ((vCount >= 10'd228) && (vCount <= 10'd275)))
               x = maze3[4][1];
           else if (((hCount >= 10'd273) && (hCount <= 10'd336)) && ((vCount >= 10'd228) && (vCount <= 10'd275)))
               x = maze3[4][2];
           else if (((hCount >= 10'd337) && (hCount <= 10'd400)) && ((vCount >= 10'd228) && (vCount <= 10'd275)))
               x = maze3[4][3];
           else if (((hCount >= 10'd401) && (hCount <= 10'd464)) && ((vCount >= 10'd228) && (vCount <= 10'd275)))
               x = maze3[4][4];
           else if (((hCount >= 10'd465) && (hCount <= 10'd528)) && ((vCount >= 10'd228) && (vCount <= 10'd275)))
               x = maze3[4][5];
           else if (((hCount >= 10'd529) && (hCount <= 10'd592)) && ((vCount >= 10'd228) && (vCount <= 10'd275)))
               x = maze3[4][6];
           else if (((hCount >= 10'd593) && (hCount <= 10'd656)) && ((vCount >= 10'd228) && (vCount <= 10'd275)))
               x = maze3[4][7];
           else if (((hCount >= 10'd657) && (hCount <= 10'd720)) && ((vCount >= 10'd228) && (vCount <= 10'd275)))
               x = maze3[4][8];	   
           else if (((hCount >= 10'd721) && (hCount <= 10'd784)) && ((vCount >= 10'd228) && (vCount <= 10'd275)))
               x = maze3[4][9];      
           
           else if(((hCount >= 10'd144) && (hCount <= 10'd208)) && ((vCount >= 10'd276) && (vCount <= 10'd323)))
               x = maze3[5][0];
           else if (((hCount >= 10'd209) && (hCount <= 10'd272)) && ((vCount >= 10'd276) && (vCount <= 10'd323)))
               x = maze3[5][1];
           else if (((hCount >= 10'd273) && (hCount <= 10'd336)) && ((vCount >= 10'd276) && (vCount <= 10'd323)))
               x = maze3[5][2];
           else if (((hCount >= 10'd337) && (hCount <= 10'd400)) && ((vCount >= 10'd276) && (vCount <= 10'd323)))
               x = maze3[5][3];
           else if (((hCount >= 10'd401) && (hCount <= 10'd464)) && ((vCount >= 10'd276) && (vCount <= 10'd323)))
               x = maze3[5][4];
           else if (((hCount >= 10'd465) && (hCount <= 10'd528)) && ((vCount >= 10'd276) && (vCount <= 10'd323)))
               x = maze3[5][5];
           else if (((hCount >= 10'd529) && (hCount <= 10'd592)) && ((vCount >= 10'd276) && (vCount <= 10'd323)))
               x = maze3[5][6];
           else if (((hCount >= 10'd593) && (hCount <= 10'd656)) && ((vCount >= 10'd276) && (vCount <= 10'd323)))
               x = maze3[5][7];
           else if (((hCount >= 10'd657) && (hCount <= 10'd720)) && ((vCount >= 10'd276) && (vCount <= 10'd323)))
               x = maze3[5][8];	   
           else if (((hCount >= 10'd721) && (hCount <= 10'd784)) && ((vCount >= 10'd276) && (vCount <= 10'd323)))
               x = maze3[5][9];   
               
           else if(((hCount >= 10'd144) && (hCount <= 10'd208)) && ((vCount >= 10'd324) && (vCount <= 10'd371)))
               x = maze3[6][0];
           else if (((hCount >= 10'd209) && (hCount <= 10'd272)) && ((vCount >= 10'd324) && (vCount <= 10'd371)))
               x = maze3[6][1];
           else if (((hCount >= 10'd273) && (hCount <= 10'd336)) && ((vCount >= 10'd324) && (vCount <= 10'd371)))
               x = maze3[6][2];
           else if (((hCount >= 10'd337) && (hCount <= 10'd400)) && ((vCount >= 10'd324) && (vCount <= 10'd371)))
               x = maze3[6][3];
           else if (((hCount >= 10'd401) && (hCount <= 10'd464)) && ((vCount >= 10'd324) && (vCount <= 10'd371)))
               x = maze3[6][4];
           else if (((hCount >= 10'd465) && (hCount <= 10'd528)) && ((vCount >= 10'd324) && (vCount <= 10'd371)))
               x = maze3[6][5];
           else if (((hCount >= 10'd529) && (hCount <= 10'd592)) && ((vCount >= 10'd324) && (vCount <= 10'd371)))
               x = maze3[6][6];
           else if (((hCount >= 10'd593) && (hCount <= 10'd656)) && ((vCount >= 10'd324) && (vCount <= 10'd371)))
               x = maze3[6][7];
           else if (((hCount >= 10'd657) && (hCount <= 10'd720)) && ((vCount >= 10'd324) && (vCount <= 10'd371)))
               x = maze3[6][8];	   
           else if (((hCount >= 10'd721) && (hCount <= 10'd784)) && ((vCount >= 10'd324) && (vCount <= 10'd371)))
               x = maze3[6][9];
              
           else if(((hCount >= 10'd144) && (hCount <= 10'd208)) && ((vCount >= 10'd372) && (vCount <= 10'd419)))
               x = maze3[7][0];
           else if (((hCount >= 10'd209) && (hCount <= 10'd272)) && ((vCount >= 10'd372) && (vCount <= 10'd419)))
               x = maze3[7][1];
           else if (((hCount >= 10'd273) && (hCount <= 10'd336)) && ((vCount >= 10'd372) && (vCount <= 10'd419)))
               x = maze3[7][2];
           else if (((hCount >= 10'd337) && (hCount <= 10'd400)) && ((vCount >= 10'd372) && (vCount <= 10'd419)))
               x = maze3[7][3];
           else if (((hCount >= 10'd401) && (hCount <= 10'd464)) && ((vCount >= 10'd372) && (vCount <= 10'd419)))
               x = maze3[7][4];
           else if (((hCount >= 10'd465) && (hCount <= 10'd528)) && ((vCount >= 10'd372) && (vCount <= 10'd419)))
               x = maze3[7][5];
           else if (((hCount >= 10'd529) && (hCount <= 10'd592)) && ((vCount >= 10'd372) && (vCount <= 10'd419)))
               x = maze3[7][6];
           else if (((hCount >= 10'd593) && (hCount <= 10'd656)) && ((vCount >= 10'd372) && (vCount <= 10'd419)))
               x = maze3[7][7];
           else if (((hCount >= 10'd657) && (hCount <= 10'd720)) && ((vCount >= 10'd372) && (vCount <= 10'd419)))
               x = maze3[7][8];	   
           else if (((hCount >= 10'd721) && (hCount <= 10'd784)) && ((vCount >= 10'd372) && (vCount <= 10'd419)))
               x = maze3[7][9];
              
           else if(((hCount >= 10'd144) && (hCount <= 10'd208)) && ((vCount >= 10'd420) && (vCount <= 10'd467)))
               x = maze3[8][0];
           else if (((hCount >= 10'd209) && (hCount <= 10'd272)) && ((vCount >= 10'd420) && (vCount <= 10'd467)))
               x = maze3[8][1];
           else if (((hCount >= 10'd273) && (hCount <= 10'd336)) && ((vCount >= 10'd420) && (vCount <= 10'd467)))
               x = maze3[8][2];
           else if (((hCount >= 10'd337) && (hCount <= 10'd400)) && ((vCount >= 10'd420) && (vCount <= 10'd467)))
               x = maze3[8][3];
           else if (((hCount >= 10'd401) && (hCount <= 10'd464)) && ((vCount >= 10'd420) && (vCount <= 10'd467)))
               x = maze3[8][4];
           else if (((hCount >= 10'd465) && (hCount <= 10'd528)) && ((vCount >= 10'd420) && (vCount <= 10'd467)))
               x = maze3[8][5];
           else if (((hCount >= 10'd529) && (hCount <= 10'd592)) && ((vCount >= 10'd420) && (vCount <= 10'd467)))
               x = maze3[8][6];
           else if (((hCount >= 10'd593) && (hCount <= 10'd656)) && ((vCount >= 10'd420) && (vCount <= 10'd467)))
               x = maze3[8][7];
           else if (((hCount >= 10'd657) && (hCount <= 10'd720)) && ((vCount >= 10'd420) && (vCount <= 10'd467)))
               x = maze3[8][8];	   
           else if (((hCount >= 10'd721) && (hCount <= 10'd784)) && ((vCount >= 10'd420) && (vCount <= 10'd467)))
               x = maze3[8][9];
           
           else if(((hCount >= 10'd144) && (hCount <= 10'd208)) && ((vCount >= 10'd468) && (vCount <= 10'd516)))
               x = maze3[9][0];
           else if (((hCount >= 10'd209) && (hCount <= 10'd272)) && ((vCount >= 10'd468) && (vCount <= 10'd516)))
               x = maze3[9][1];
           else if (((hCount >= 10'd273) && (hCount <= 10'd336)) && ((vCount >= 10'd468) && (vCount <= 10'd516)))
               x = maze3[9][2];
           else if (((hCount >= 10'd337) && (hCount <= 10'd400)) && ((vCount >= 10'd468) && (vCount <= 10'd516)))
               x = maze3[9][3];
           else if (((hCount >= 10'd401) && (hCount <= 10'd464)) && ((vCount >= 10'd468) && (vCount <= 10'd516)))
               x = maze3[9][4];
           else if (((hCount >= 10'd465) && (hCount <= 10'd528)) && ((vCount >= 10'd468) && (vCount <= 10'd516)))
               x = maze3[9][5];
           else if (((hCount >= 10'd529) && (hCount <= 10'd592)) && ((vCount >= 10'd468) && (vCount <= 10'd516)))
               x = maze3[9][6];
           else if (((hCount >= 10'd593) && (hCount <= 10'd656)) && ((vCount >= 10'd468) && (vCount <= 10'd516)))
               x = maze3[9][7];
           else if (((hCount >= 10'd657) && (hCount <= 10'd720)) && ((vCount >= 10'd468) && (vCount <= 10'd516)))
               x = maze3[9][8];	   
           else if (((hCount >= 10'd721) && (hCount <= 10'd784)) && ((vCount >= 10'd468) && (vCount <= 10'd516)))
               x = maze3[9][9];
           else
               x = 3;
       end
       else if (maze_type == 3) begin
           if(((hCount >= 10'd144) && (hCount <= 10'd208)) && ((vCount >= 10'd35) && (vCount <= 10'd88)))
               x = maze4[0][0];
           else if (((hCount >= 10'd209) && (hCount <= 10'd272)) && ((vCount >= 10'd35) && (vCount <= 10'd88)))
               x = maze4[0][1];
           else if (((hCount >= 10'd273) && (hCount <= 10'd336)) && ((vCount >= 10'd35) && (vCount <= 10'd88)))
               x = maze4[0][2];
           else if (((hCount >= 10'd337) && (hCount <= 10'd400)) && ((vCount >= 10'd35) && (vCount <= 10'd88)))
               x = maze4[0][3];
           else if (((hCount >= 10'd401) && (hCount <= 10'd464)) && ((vCount >= 10'd35) && (vCount <= 10'd88)))
               x = maze4[0][4];
           else if (((hCount >= 10'd465) && (hCount <= 10'd528)) && ((vCount >= 10'd35) && (vCount <= 10'd88)))
               x = maze4[0][5];
           else if (((hCount >= 10'd529) && (hCount <= 10'd592)) && ((vCount >= 10'd35) && (vCount <= 10'd88)))
               x = maze4[0][6];
           else if (((hCount >= 10'd593) && (hCount <= 10'd656)) && ((vCount >= 10'd35) && (vCount <= 10'd88)))
               x = maze4[0][7];
           else if (((hCount >= 10'd657) && (hCount <= 10'd720)) && ((vCount >= 10'd35) && (vCount <= 10'd88)))
               x = maze4[0][8];	   
           else if (((hCount >= 10'd721) && (hCount <= 10'd784)) && ((vCount >= 10'd35) && (vCount <= 10'd88)))
               x = maze4[0][9];
               
           else if(((hCount >= 10'd144) && (hCount <= 10'd208)) && ((vCount >= 10'd84) && (vCount <= 10'd131)))
               x = maze4[1][0];
           else if (((hCount >= 10'd209) && (hCount <= 10'd272)) && ((vCount >= 10'd84) && (vCount <= 10'd131)))
               x = maze4[1][1];
           else if (((hCount >= 10'd273) && (hCount <= 10'd336)) && ((vCount >= 10'd84) && (vCount <= 10'd131)))
               x = maze4[1][2];
           else if (((hCount >= 10'd337) && (hCount <= 10'd400)) && ((vCount >= 10'd84) && (vCount <= 10'd131)))
               x = maze4[1][3];
           else if (((hCount >= 10'd401) && (hCount <= 10'd464)) && ((vCount >= 10'd84) && (vCount <= 10'd131)))
               x = maze4[1][4];
           else if (((hCount >= 10'd465) && (hCount <= 10'd528)) && ((vCount >= 10'd84) && (vCount <= 10'd131)))
               x = maze4[1][5];
           else if (((hCount >= 10'd529) && (hCount <= 10'd592)) && ((vCount >= 10'd84) && (vCount <= 10'd131)))
               x = maze4[1][6];
           else if (((hCount >= 10'd593) && (hCount <= 10'd656)) && ((vCount >= 10'd84) && (vCount <= 10'd131)))
               x = maze4[1][7];
           else if (((hCount >= 10'd657) && (hCount <= 10'd720)) && ((vCount >= 10'd84) && (vCount <= 10'd131)))
               x = maze4[1][8];	   
           else if (((hCount >= 10'd721) && (hCount <= 10'd784)) && ((vCount >= 10'd84) && (vCount <= 10'd131)))
               x = maze4[1][9];
              
           else if(((hCount >= 10'd144) && (hCount <= 10'd208)) && ((vCount >= 10'd132) && (vCount <= 10'd179)))
               x = maze4[2][0];
           else if (((hCount >= 10'd209) && (hCount <= 10'd272)) && ((vCount >= 10'd132) && (vCount <= 10'd179)))
               x = maze4[2][1];
           else if (((hCount >= 10'd273) && (hCount <= 10'd336)) && ((vCount >= 10'd132) && (vCount <= 10'd179)))
               x = maze4[2][2];
           else if (((hCount >= 10'd337) && (hCount <= 10'd400)) && ((vCount >= 10'd132) && (vCount <= 10'd179)))
               x = maze4[2][3];
           else if (((hCount >= 10'd401) && (hCount <= 10'd464)) && ((vCount >= 10'd132) && (vCount <= 10'd179)))
               x = maze4[2][4];
           else if (((hCount >= 10'd465) && (hCount <= 10'd528)) && ((vCount >= 10'd132) && (vCount <= 10'd179)))
               x = maze4[2][5];
           else if (((hCount >= 10'd529) && (hCount <= 10'd592)) && ((vCount >= 10'd132) && (vCount <= 10'd179)))
               x = maze4[2][6];
           else if (((hCount >= 10'd593) && (hCount <= 10'd656)) && ((vCount >= 10'd132) && (vCount <= 10'd179)))
               x = maze4[2][7];
           else if (((hCount >= 10'd657) && (hCount <= 10'd720)) && ((vCount >= 10'd132) && (vCount <= 10'd179)))
               x = maze4[2][8];	   
           else if (((hCount >= 10'd721) && (hCount <= 10'd784)) && ((vCount >= 10'd132) && (vCount <= 10'd179)))
               x = maze4[2][9];	    
               
           else if(((hCount >= 10'd144) && (hCount <= 10'd208)) && ((vCount >= 10'd180) && (vCount <= 10'd227)))
               x = maze4[3][0];
           else if (((hCount >= 10'd209) && (hCount <= 10'd272)) && ((vCount >= 10'd180) && (vCount <= 10'd227)))
               x = maze4[3][1];
           else if (((hCount >= 10'd273) && (hCount <= 10'd336)) && ((vCount >= 10'd180) && (vCount <= 10'd227)))
               x = maze4[3][2];
           else if (((hCount >= 10'd337) && (hCount <= 10'd400)) && ((vCount >= 10'd180) && (vCount <= 10'd227)))
               x = maze4[3][3];
           else if (((hCount >= 10'd401) && (hCount <= 10'd464)) && ((vCount >= 10'd180) && (vCount <= 10'd227)))
               x = maze4[3][4];
           else if (((hCount >= 10'd465) && (hCount <= 10'd528)) && ((vCount >= 10'd180) && (vCount <= 10'd227)))
               x = maze4[3][5];
           else if (((hCount >= 10'd529) && (hCount <= 10'd592)) && ((vCount >= 10'd180) && (vCount <= 10'd227)))
               x = maze4[3][6];
           else if (((hCount >= 10'd593) && (hCount <= 10'd656)) && ((vCount >= 10'd180) && (vCount <= 10'd227)))
               x = maze4[3][7];
           else if (((hCount >= 10'd657) && (hCount <= 10'd720)) && ((vCount >= 10'd180) && (vCount <= 10'd227)))
               x = maze4[3][8];	   
           else if (((hCount >= 10'd721) && (hCount <= 10'd784)) && ((vCount >= 10'd180) && (vCount <= 10'd227)))
               x = maze4[3][9];
               
           else if(((hCount >= 10'd144) && (hCount <= 10'd208)) && ((vCount >= 10'd228) && (vCount <= 10'd275)))
               x = maze4[4][0];
           else if (((hCount >= 10'd209) && (hCount <= 10'd272)) && ((vCount >= 10'd228) && (vCount <= 10'd275)))
               x = maze4[4][1];
           else if (((hCount >= 10'd273) && (hCount <= 10'd336)) && ((vCount >= 10'd228) && (vCount <= 10'd275)))
               x = maze4[4][2];
           else if (((hCount >= 10'd337) && (hCount <= 10'd400)) && ((vCount >= 10'd228) && (vCount <= 10'd275)))
               x = maze4[4][3];
           else if (((hCount >= 10'd401) && (hCount <= 10'd464)) && ((vCount >= 10'd228) && (vCount <= 10'd275)))
               x = maze4[4][4];
           else if (((hCount >= 10'd465) && (hCount <= 10'd528)) && ((vCount >= 10'd228) && (vCount <= 10'd275)))
               x = maze4[4][5];
           else if (((hCount >= 10'd529) && (hCount <= 10'd592)) && ((vCount >= 10'd228) && (vCount <= 10'd275)))
               x = maze4[4][6];
           else if (((hCount >= 10'd593) && (hCount <= 10'd656)) && ((vCount >= 10'd228) && (vCount <= 10'd275)))
               x = maze4[4][7];
           else if (((hCount >= 10'd657) && (hCount <= 10'd720)) && ((vCount >= 10'd228) && (vCount <= 10'd275)))
               x = maze4[4][8];	   
           else if (((hCount >= 10'd721) && (hCount <= 10'd784)) && ((vCount >= 10'd228) && (vCount <= 10'd275)))
               x = maze4[4][9];      
           
           else if(((hCount >= 10'd144) && (hCount <= 10'd208)) && ((vCount >= 10'd276) && (vCount <= 10'd323)))
               x = maze4[5][0];
           else if (((hCount >= 10'd209) && (hCount <= 10'd272)) && ((vCount >= 10'd276) && (vCount <= 10'd323)))
               x = maze4[5][1];
           else if (((hCount >= 10'd273) && (hCount <= 10'd336)) && ((vCount >= 10'd276) && (vCount <= 10'd323)))
               x = maze4[5][2];
           else if (((hCount >= 10'd337) && (hCount <= 10'd400)) && ((vCount >= 10'd276) && (vCount <= 10'd323)))
               x = maze4[5][3];
           else if (((hCount >= 10'd401) && (hCount <= 10'd464)) && ((vCount >= 10'd276) && (vCount <= 10'd323)))
               x = maze4[5][4];
           else if (((hCount >= 10'd465) && (hCount <= 10'd528)) && ((vCount >= 10'd276) && (vCount <= 10'd323)))
               x = maze4[5][5];
           else if (((hCount >= 10'd529) && (hCount <= 10'd592)) && ((vCount >= 10'd276) && (vCount <= 10'd323)))
               x = maze4[5][6];
           else if (((hCount >= 10'd593) && (hCount <= 10'd656)) && ((vCount >= 10'd276) && (vCount <= 10'd323)))
               x = maze4[5][7];
           else if (((hCount >= 10'd657) && (hCount <= 10'd720)) && ((vCount >= 10'd276) && (vCount <= 10'd323)))
               x = maze4[5][8];	   
           else if (((hCount >= 10'd721) && (hCount <= 10'd784)) && ((vCount >= 10'd276) && (vCount <= 10'd323)))
               x = maze4[5][9];   
               
           else if(((hCount >= 10'd144) && (hCount <= 10'd208)) && ((vCount >= 10'd324) && (vCount <= 10'd371)))
               x = maze4[6][0];
           else if (((hCount >= 10'd209) && (hCount <= 10'd272)) && ((vCount >= 10'd324) && (vCount <= 10'd371)))
               x = maze4[6][1];
           else if (((hCount >= 10'd273) && (hCount <= 10'd336)) && ((vCount >= 10'd324) && (vCount <= 10'd371)))
               x = maze4[6][2];
           else if (((hCount >= 10'd337) && (hCount <= 10'd400)) && ((vCount >= 10'd324) && (vCount <= 10'd371)))
               x = maze4[6][3];
           else if (((hCount >= 10'd401) && (hCount <= 10'd464)) && ((vCount >= 10'd324) && (vCount <= 10'd371)))
               x = maze4[6][4];
           else if (((hCount >= 10'd465) && (hCount <= 10'd528)) && ((vCount >= 10'd324) && (vCount <= 10'd371)))
               x = maze4[6][5];
           else if (((hCount >= 10'd529) && (hCount <= 10'd592)) && ((vCount >= 10'd324) && (vCount <= 10'd371)))
               x = maze4[6][6];
           else if (((hCount >= 10'd593) && (hCount <= 10'd656)) && ((vCount >= 10'd324) && (vCount <= 10'd371)))
               x = maze4[6][7];
           else if (((hCount >= 10'd657) && (hCount <= 10'd720)) && ((vCount >= 10'd324) && (vCount <= 10'd371)))
               x = maze4[6][8];	   
           else if (((hCount >= 10'd721) && (hCount <= 10'd784)) && ((vCount >= 10'd324) && (vCount <= 10'd371)))
               x = maze4[6][9];
              
           else if(((hCount >= 10'd144) && (hCount <= 10'd208)) && ((vCount >= 10'd372) && (vCount <= 10'd419)))
               x = maze4[7][0];
           else if (((hCount >= 10'd209) && (hCount <= 10'd272)) && ((vCount >= 10'd372) && (vCount <= 10'd419)))
               x = maze4[7][1];
           else if (((hCount >= 10'd273) && (hCount <= 10'd336)) && ((vCount >= 10'd372) && (vCount <= 10'd419)))
               x = maze4[7][2];
           else if (((hCount >= 10'd337) && (hCount <= 10'd400)) && ((vCount >= 10'd372) && (vCount <= 10'd419)))
               x = maze4[7][3];
           else if (((hCount >= 10'd401) && (hCount <= 10'd464)) && ((vCount >= 10'd372) && (vCount <= 10'd419)))
               x = maze4[7][4];
           else if (((hCount >= 10'd465) && (hCount <= 10'd528)) && ((vCount >= 10'd372) && (vCount <= 10'd419)))
               x = maze4[7][5];
           else if (((hCount >= 10'd529) && (hCount <= 10'd592)) && ((vCount >= 10'd372) && (vCount <= 10'd419)))
               x = maze4[7][6];
           else if (((hCount >= 10'd593) && (hCount <= 10'd656)) && ((vCount >= 10'd372) && (vCount <= 10'd419)))
               x = maze4[7][7];
           else if (((hCount >= 10'd657) && (hCount <= 10'd720)) && ((vCount >= 10'd372) && (vCount <= 10'd419)))
               x = maze4[7][8];	   
           else if (((hCount >= 10'd721) && (hCount <= 10'd784)) && ((vCount >= 10'd372) && (vCount <= 10'd419)))
               x = maze4[7][9];
              
           else if(((hCount >= 10'd144) && (hCount <= 10'd208)) && ((vCount >= 10'd420) && (vCount <= 10'd467)))
               x = maze4[8][0];
           else if (((hCount >= 10'd209) && (hCount <= 10'd272)) && ((vCount >= 10'd420) && (vCount <= 10'd467)))
               x = maze4[8][1];
           else if (((hCount >= 10'd273) && (hCount <= 10'd336)) && ((vCount >= 10'd420) && (vCount <= 10'd467)))
               x = maze4[8][2];
           else if (((hCount >= 10'd337) && (hCount <= 10'd400)) && ((vCount >= 10'd420) && (vCount <= 10'd467)))
               x = maze4[8][3];
           else if (((hCount >= 10'd401) && (hCount <= 10'd464)) && ((vCount >= 10'd420) && (vCount <= 10'd467)))
               x = maze4[8][4];
           else if (((hCount >= 10'd465) && (hCount <= 10'd528)) && ((vCount >= 10'd420) && (vCount <= 10'd467)))
               x = maze4[8][5];
           else if (((hCount >= 10'd529) && (hCount <= 10'd592)) && ((vCount >= 10'd420) && (vCount <= 10'd467)))
               x = maze4[8][6];
           else if (((hCount >= 10'd593) && (hCount <= 10'd656)) && ((vCount >= 10'd420) && (vCount <= 10'd467)))
               x = maze4[8][7];
           else if (((hCount >= 10'd657) && (hCount <= 10'd720)) && ((vCount >= 10'd420) && (vCount <= 10'd467)))
               x = maze4[8][8];	   
           else if (((hCount >= 10'd721) && (hCount <= 10'd784)) && ((vCount >= 10'd420) && (vCount <= 10'd467)))
               x = maze4[8][9];
           
           else if(((hCount >= 10'd144) && (hCount <= 10'd208)) && ((vCount >= 10'd468) && (vCount <= 10'd516)))
               x = maze4[9][0];
           else if (((hCount >= 10'd209) && (hCount <= 10'd272)) && ((vCount >= 10'd468) && (vCount <= 10'd516)))
               x = maze4[9][1];
           else if (((hCount >= 10'd273) && (hCount <= 10'd336)) && ((vCount >= 10'd468) && (vCount <= 10'd516)))
               x = maze4[9][2];
           else if (((hCount >= 10'd337) && (hCount <= 10'd400)) && ((vCount >= 10'd468) && (vCount <= 10'd516)))
               x = maze4[9][3];
           else if (((hCount >= 10'd401) && (hCount <= 10'd464)) && ((vCount >= 10'd468) && (vCount <= 10'd516)))
               x = maze4[9][4];
           else if (((hCount >= 10'd465) && (hCount <= 10'd528)) && ((vCount >= 10'd468) && (vCount <= 10'd516)))
               x = maze4[9][5];
           else if (((hCount >= 10'd529) && (hCount <= 10'd592)) && ((vCount >= 10'd468) && (vCount <= 10'd516)))
               x = maze4[9][6];
           else if (((hCount >= 10'd593) && (hCount <= 10'd656)) && ((vCount >= 10'd468) && (vCount <= 10'd516)))
               x = maze4[9][7];
           else if (((hCount >= 10'd657) && (hCount <= 10'd720)) && ((vCount >= 10'd468) && (vCount <= 10'd516)))
               x = maze4[9][8];	   
           else if (((hCount >= 10'd721) && (hCount <= 10'd784)) && ((vCount >= 10'd468) && (vCount <= 10'd516)))
               x = maze4[9][9];
           else
               x = 3;
       end
	        
	   if (( (hCount < (xpos - 100)) || (hCount > (xpos + 100)) || (vCount < (ypos - 100)) || (vCount > (ypos + 100 )) ))
	       x = 1;
	   
	   if ((hCount == xpos) && (vCount == ypos)) begin
	       if(x == 0)begin
	           go = 1;
	           end_of_maze <= 0;
	       end
	       else if (x == 3) begin
	           go = 0;
	           end_of_maze <= 1;
	       end
	       else
	           go = 0;
	   end
	end
	
	assign mazewall = x;

	
	
endmodule
