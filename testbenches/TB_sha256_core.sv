`timescale 1ns / 100ps

module TB_sha256_core;
    import sha256_pkg::*;
    
    logic clk, rstn;
    logic start;
    logic [(2*BLOCK_SIZE)-1:0] msg;
    logic [BLOCK_SIZE-1:0] md;
    logic valid;
    
    integer tests_passed, tests_failed;
    
    sha256_core u_sha256_core 
    (
        .clk_i      (clk),
        .rstn_i     (rstn),
        .start_i    (start),
        .msg_i      (msg),
        .md_o       (md),
        .valid_o    (valid) 
    );
    
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end
    
    typedef struct {
        logic [(2*BLOCK_SIZE)-1:0] in;
        logic [BLOCK_SIZE-1:0] out;
    } test_case_t;
    
    test_case_t test_case[] = '{
        // Test Case 1: Empty string
       '{
            in:  512'h80000000_00000000_00000000_00000000_00000000_00000000_00000000_00000000_00000000_00000000_00000000_00000000_00000000_00000000_00000000_00000000,
            out: 256'he3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855
        },

        // Test Case 2: "abc"
        '{
            in:  512'h61626380_00000000_00000000_00000000_00000000_00000000_00000000_00000000_00000000_00000000_00000000_00000000_00000000_00000000_00000000_00000018,
            out: 256'hba7816bf8f01cfea414140de5dae2223b00361a396177a9cb410ff61f20015ad
        },

        // Test Case 3: "hello I am Soham"
        '{
            in:  512'h68656c6c_6f204920_616d2053_6f68616d_80000000_00000000_00000000_00000000_00000000_00000000_00000000_00000000_00000000_00000000_00000000_00000080,
            out: 256'h9603bc1b03046fa9c869ea9edf2e2f91cab8d063154cff6036612125cea4be10
        },
        
        // Test Case 4: "hello I am Soham, this verifies my assignment"
        '{
            in:  512'h68656c6c_6f204920_616d2053_6f68616d_2c207468_69732076_65726966_69657320_6d792061_73736967_6e6d656e_74800000_00000000_00000000_00000000_00000168,
            out: 256'hdbe2e78fbfe236eef9872cc4b1718e8baf85776255cfe362ec821afdb55956fc
        },
        
         // Test Case 5: "Hi hello I am Soham, this verifies my assignment. bye"
        '{
            in:  512'h48692068_656c6c6f_20492061_6d20536f_68616d2c_20746869_73207665_72696669_6573206d_79206173_7369676e_6d656e74_2e206279_65800000_00000000_000001a8,
            out: 256'h8d29622349a4eb32c2bf425a3e64a347cb77b8efd313d9e7d5661b1282277e31
        }
    };
    
    task reset_sequence;
        begin
            rstn = 1'b1;
            start = 1'b0;
            msg = 1'b0;
            repeat(2) @(posedge clk);
            rstn = 1'b0;
            repeat(2) @(posedge clk);
            rstn = 1'b1;
            repeat(2) @(posedge clk);
        end
    endtask
    
    task msg_process;
        input logic [(2*BLOCK_SIZE)-1:0] msg_task;
        begin
            msg = msg_task;
            start = 1'b1; 
            repeat(2) @(posedge clk);
            start = 1'b0;
            wait(valid);
            @(posedge clk);
        end
    endtask
    
    task hash_verify;
        input logic [(BLOCK_SIZE)-1:0] actual, expected;
        begin
            if (actual === expected) begin
                $display("PASS");
                tests_passed++;
            end else begin
                $display("FAIL");
                $display("Expected: %h", expected);
                $display("Got: %h", actual);
                tests_failed++;
            end
        end
    endtask
    
    initial begin
        tests_passed = 0;
        tests_failed = 0;
        
        reset_sequence();
        
        for (int i = 0; i < test_case.size(); i++) begin
            msg_process(test_case[i].in);
            hash_verify(md, test_case[i].out);
        end
        
        $display("\nTest Summary at time %t: ", $time);
        $display("Test Passed: %0d", tests_passed);
        $display("Test Failed: %0d", tests_failed);
        
        $finish; 
    end
    
    initial begin
        repeat(10000) @(posedge clk);
        $display("\nWatch Dog Timed Out, Fix the Design hahahaha");
        $finish;
    end

    // Waveform dumping
    initial begin
        $dumpfile("TB_sha256_core.vcd");
        $dumpvars(0, TB_sha256_core);
    end
    
endmodule
