module keyboard_get (CLOCK_50, KEY, PS2_CLK, PS2_DAT, HEX0, HEX1, SIGNAL);
    input wire CLOCK_50;
    input wire [0:0] KEY;
    inout wire PS2_CLK, PS2_DAT;    
    output wire [6:0] HEX0;
    output wire [6:0] HEX1;             
    output wire [7:0] SIGNAL;

    wire Resetn, negedge_ps2_clk;
    reg [10:0] Serial;            
                                  
    reg prev_ps2_clk;             

    assign Resetn = KEY[0];

    always @(posedge CLOCK_50)
        prev_ps2_clk <= PS2_CLK;

    assign negedge_ps2_clk = (prev_ps2_clk & !PS2_CLK);

    always @(posedge CLOCK_50) begin    
        if (Resetn == 0)
            Serial <= 33'b0;
        else if (negedge_ps2_clk) begin
            Serial[9:0] <= Serial[10:1];
            Serial[10] <= PS2_DAT;
        end
    end
    assign SIGNAL = Serial[8:1];
    hex7seg H0 (Serial[4:1], HEX0);
    hex7seg H1 (Serial[8:5], HEX1);
endmodule

module hex7seg (hex, display);
    input wire [3:0] hex;
    output reg [6:0] display;
    always @ (hex)
        case (hex)
            4'h0: display = 7'b1000000;
            4'h1: display = 7'b1111001;
            4'h2: display = 7'b0100100;
            4'h3: display = 7'b0110000;
            4'h4: display = 7'b0011001;
            4'h5: display = 7'b0010010;
            4'h6: display = 7'b0000010;
            4'h7: display = 7'b1111000;
            4'h8: display = 7'b0000000;
            4'h9: display = 7'b0011000;
            4'hA: display = 7'b0001000;
            4'hb: display = 7'b0000011;
            4'hC: display = 7'b1000110;
            4'hd: display = 7'b0100001;
            4'hE: display = 7'b0000110;
            4'hF: display = 7'b0001110;
        endcase
endmodule

module keybard_translate (RAWSIG,TRANCODE);
input  wire [7:0] RAWSIG,
output reg  [32:0] TRANCODE  
always @(*) begin
    case (RAWSIG)
        8'h1C: TRANCODE =33'b000000000000000000000000000000001; // A
        8'h32: TRANCODE =33'b000000000000000000000000000000010; // B
        8'h21: TRANCODE =33'b000000000000000000000000000000100; // C
        8'h23: TRANCODE =33'b000000000000000000000000000001000; // D
        8'h24: TRANCODE =33'b000000000000000000000000000010000; // E
        8'h2B: TRANCODE =33'b000000000000000000000000000100000; // F
        8'h34: TRANCODE =33'b000000000000000000000000001000000; // G
        8'h33: TRANCODE =33'b000000000000000000000000010000000; // H
        8'h43: TRANCODE =33'b000000000000000000000000100000000; // I
        8'h3B: TRANCODE =33'b000000000000000000000001000000000; // J
        8'h42: TRANCODE =33'b000000000000000000000010000000000; // K
        8'h4B: TRANCODE =33'b000000000000000000000100000000000; // L
        8'h3A: TRANCODE =33'b000000000000000000001000000000000; // M
        8'h31: TRANCODE =33'b000000000000000000010000000000000; // N
        8'h44: TRANCODE =33'b000000000000000000100000000000000; // O
        8'h4D: TRANCODE =33'b000000000000000001000000000000000; // P
        8'h15: TRANCODE =33'b000000000000000010000000000000000; // Q
        8'h2D: TRANCODE =33'b000000000000000100000000000000000; // R
        8'h1B: TRANCODE =33'b000000000000001000000000000000000; // S
        8'h2C: TRANCODE =33'b000000000000010000000000000000000; // T
        8'h3C: TRANCODE =33'b000000000000100000000000000000000; // U
        8'h2A: TRANCODE =33'b000000000001000000000000000000000; // V
        8'h1D: TRANCODE =33'b000000000010000000000000000000000; // W
        8'h22: TRANCODE =33'b000000000100000000000000000000000; // X
        8'h35: TRANCODE =33'b000000001000000000000000000000000; // Y
        8'h1A: TRANCODE =33'b000000010000000000000000000000000; // Z
        8'h0c: TRANCODE =33'b000000100000000000000000000000000; // F4
        8'h04: TRANCODE =33'b000001000000000000000000000000000; // F3
        8'h29: TRANCODE =33'b000010000000000000000000000000000; // Space
        8'h5A: TRANCODE =33'b000100000000000000000000000000000; // Enter
        8'h66: TRANCODE =33'b001000000000000000000000000000000; // Backspace
        8'h12: TRANCODE =33'b01000000000000000000000000000000; // Left Shift
        8'h14: TRANCODE =33'b100000000000000000000000000000000; // Left Ctrl
        default: TRANCODE =33'b000000000000000000000000000000000; // Other
    endcase
end
endmodule



module keybard_lock(CLOCK_50, KEY, PS2_CLK, PS2_DAT, HEX0, HEX1, TRANCODE,OTRANSCODE);
    input wire CLOCK_50;
    input wire [0:0] KEY;
    inout wire PS2_CLK, PS2_DAT;    
    output wire [6:0] HEX0;
    output wire [6:0] HEX1;             
    input wire [32:0] TRANCODE;
    output wire [32:0] OTRANCODE;

    wire Resetn;
    assign Resetn = KEY[0];

    reg [32:0] Q;
    
    always @(posedge CLOCK_50) begin
        if (!Resetn)
            Q<=33'b0;
        else begin
        if(Q[30:0]==31'b0) Q<=TRANCODE[30:0];
        else if ((Q[30:0]!=31'b0) && (Q[30:0]==TRANCODE[30:0])) Q[30:0] <=31'b0;
        else if ((Q[30:0]!=31'b0) && (Q[30:0]!=TRANCODE[30:0])) Q[30:0] <=Q[30:0];

        if(Q[32:31]==2'b0) Q[32:31]<=TRANCODE[32:31];
        else if ((Q[32:31]!=2'b0) && (Q[32:31]==TRANCODE[32:31])) Q[32:31] <=2'b0;
        else if ((Q[32:31]!=2'b0) && (Q[32:31]!=TRANCODE[32:31])) Q[32:31] <=Q[32:31];
        end
    end


    //Output
    assign OTRANSCODE = Q;
endmodule




