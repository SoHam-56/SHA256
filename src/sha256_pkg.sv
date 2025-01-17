`timescale 1ns / 100ps

package sha256_pkg;
    
    localparam BLOCK_SIZE = 256;
    localparam ROUNDS = 64, WORD_SIZE = 32, PARALLEL = 6;
    
    // K constants
    localparam [WORD_SIZE-1:0] K [0:63] = '{
        32'h428a2f98, 32'h71374491, 32'hb5c0fbcf, 32'he9b5dba5,
        32'h3956c25b, 32'h59f111f1, 32'h923f82a4, 32'hab1c5ed5,
        32'hd807aa98, 32'h12835b01, 32'h243185be, 32'h550c7dc3,
        32'h72be5d74, 32'h80deb1fe, 32'h9bdc06a7, 32'hc19bf174,
        32'he49b69c1, 32'hefbe4786, 32'h0fc19dc6, 32'h240ca1cc,
        32'h2de92c6f, 32'h4a7484aa, 32'h5cb0a9dc, 32'h76f988da,
        32'h983e5152, 32'ha831c66d, 32'hb00327c8, 32'hbf597fc7,
        32'hc6e00bf3, 32'hd5a79147, 32'h06ca6351, 32'h14292967,
        32'h27b70a85, 32'h2e1b2138, 32'h4d2c6dfc, 32'h53380d13,
        32'h650a7354, 32'h766a0abb, 32'h81c2c92e, 32'h92722c85,
        32'ha2bfe8a1, 32'ha81a664b, 32'hc24b8b70, 32'hc76c51a3,
        32'hd192e819, 32'hd6990624, 32'hf40e3585, 32'h106aa070,
        32'h19a4c116, 32'h1e376c08, 32'h2748774c, 32'h34b0bcb5,
        32'h391c0cb3, 32'h4ed8aa4a, 32'h5b9cca4f, 32'h682e6ff3,
        32'h748f82ee, 32'h78a5636f, 32'h84c87814, 32'h8cc70208,
        32'h90befffa, 32'ha4506ceb, 32'hbef9a3f7, 32'hc67178f2
    };
    
    // Initial Hash Values
    localparam [WORD_SIZE-1:0] H [0:7] = '{
        32'h6a09e667, 32'hbb67ae85, 32'h3c6ef372, 32'ha54ff53a,
        32'h510e527f, 32'h9b05688c, 32'h1f83d9ab, 32'h5be0cd19
    };
    
    function automatic [WORD_SIZE-1:0] sigma0 (input [WORD_SIZE-1:0] x);
        return ({x[6:0], x[WORD_SIZE-1:7]} ^ {x[17:0], x[WORD_SIZE-1:18]} ^ (x >> 3));
    endfunction
    
    function automatic [WORD_SIZE-1:0] sigma1 (input [WORD_SIZE-1:0] x);
        return ({x[16:0], x[WORD_SIZE-1:17]} ^ {x[18:0], x[WORD_SIZE-1:19]} ^ (x >> 10));
    endfunction
    
    function automatic [WORD_SIZE-1:0] sum0 (input [WORD_SIZE-1:0] x);
        return ({x[1:0], x[WORD_SIZE-1:2]} ^ {x[12:0], x[WORD_SIZE-1:13]} ^ {x[21:0], x[WORD_SIZE-1:22]});
    endfunction
    
    function automatic [WORD_SIZE-1:0] sum1 (input [WORD_SIZE-1:0] x);
        return ({x[5:0], x[WORD_SIZE-1:6]} ^ {x[10:0], x[WORD_SIZE-1:11]} ^ {x[24:0], x[WORD_SIZE-1:25]});
    endfunction
    
    function automatic [WORD_SIZE-1:0] Ch (input [WORD_SIZE-1:0] x, y, z);
        return (x & y) ^ (~x & z);
    endfunction
    
    function automatic [WORD_SIZE-1:0] Maj (input [WORD_SIZE-1:0] x, y, z);
        return (x & y) ^ (x & z) ^ (y & z);
    endfunction
    
endpackage
    
