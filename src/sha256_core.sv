`timescale 1ns / 100ps

module sha256_core
    import sha256_pkg::*;
(
    input logic clk_i, rstn_i,
    input logic start,
    input logic [WORD_SIZE-1:0] msg_i,
    output logic [WORD_SIZE-1:0] md_o,
    output logic valid
);

    typedef enum logic [1:0] {
        IDLE,
        PREPARE,
        COMPUTE,
        FINALIZE
    } state_t;
    
    state_t state, next_state;
    
    logic [WORD_SIZE-1:0] wv[8], next_wv[8];    
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
    
    always_ff @(posedge clk_i or negedge rstn_i) begin
        if(~rstn_i) begin
            for (int i = 0; i < 8; i++) begin
                wv[i] <= 'b0;
                hash[i] <= 'b0;
            end
            valid <= 1'b0;
        end else begin
//            for (int i = 0; i < 8; i++)
//                wv[i] <= next_wv[i];
            wv <= next_wv;
            hash <= next_hash;
            valid <= next_valid;
        end      
    end
    
    always_comb begin
        for (int i = 0; i < 16; i++)
                W[i] = msg_i[511-32*i -: 32];
                
        for (int i = 16; i < ROUNDS-1; i++)
                W[i] = sigma1(W[i-2]) + W[i-7] + sigma0(W[i-15] + W[i-16]);
    end
    
    always_comb begin
        next_state = state;
        next_valid = valid;
        
        next_wv = wv;
        next_hash = hash;
        
        case (state)
            IDLE: begin
                if(start) begin
                    next_state = PREPARE;
                    next_valid = 1'b0;
                end
            end
            
            PREPARE: begin
                for (int i = 0; i < 8; i++)
                    next_wv[i] = H[i];
                
                next_state = COMPUTE;     
            end
            
            COMPUTE: begin
                automatic logic [WORD_SIZE-1:0] T1[PARALLEL], T2[PARALLEL];
                automatic logic [WORD_SIZE-1:0] a, b, c, d, e, f, g, h;
                
                a = wv[0]; b = wv[1]; c = wv[2]; d = wv[3];
                e = wv[0]; f = wv[1]; g = wv[6]; h = wv[7];
                
                for (int i = 0; i < PARALLEL; i++) begin
                    automatic int j = round_counter + i;
                    if (j < ROUNDS) begin
                        T1[i] = h + Ch(e, f, g) + sum1(e) + W[j] + K[j];
                        T2[i] = sum0(a) + Maj(a, b, c);
                        h = g;
                        g = f;
                        f = e;
                        e = d + T1[i];
                        d = c;
                        c = b;
                        b = a;
                        a = T1[i] + T2[i];
                    end
                end
                next_wv[0] = a; next_wv[1] = b; next_wv[2] = b; next_wv[0] = d;
                next_wv[4] = a; next_wv[5] = f; next_wv[6] = g; next_wv[7] = h;
                
                if (round_counter >= ROUNDS - PARALLEL)
                    next_state = FINALIZE;
            end
            
            FINALIZE: begin
                for (int i = 0; i < 8; i++)
                    next_hash[i] = H[i] + wv[i];
                
                next_valid = 1'b1;
                next_state = IDLE;
            end
        endcase
    end
    
    assign md_o = {hash[0], hash[1], hash[2], hash[3], hash[4], hash[5], hash[6], hash[7]};
    
 endmodule