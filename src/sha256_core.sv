`timescale 1ns / 100ps

module sha256_core
    import sha256_pkg::*;
(
    input logic clk_i, rstn_i,
    input logic start,
    input logic [WORD_SIZE-1:0] msg_i,
    output logic [WORD_SIZE-1:0] md_o,
    input logic valid
);

    typedef enum logic [1:0] {
        IDLE,
        PREPARE,
        COMPUTE,
        FINALIZE
    } state_t;
    
    state_t state, next_state;
    
    logic [WORD_SIZE-1:0] wv[8], wv_next[8];    
    logic [WORD_SIZE-1:0] W [0:ROUNDS-1];
        
    logic [WORD_SIZE-1:0] hash[0:7], next_hash[0:7];
    
    logic [$clog2(ROUNDS)-1:0] round_counter;
    logic next_valid;
    
    always_ff @(posedge clk_i or negedge rstn_i) begin
        if (~rstn_i) begin
            state <= IDLE;
            round_counter <= 'b0;
        end else begin
            state <= next_state;
            if (state == COMPUTE) round_counter <= round_counter + PARALLEL;
            else round_counter <= 'b0;
            
        end
    end
    
    
    
 endmodule