`timescale 1ns / 1ps

module PipelineDeliver #(parameter WIDTH = 1) (
    input                   clk,
    input                   rst,
    input                   flush,
    input                   stall_current_stage,
    input                   stall_next_stage,
    input   [WIDTH - 1:0]   in,
    output  [WIDTH - 1:0]   out
);

    reg[WIDTH - 1:0] last_status;
    assign out = last_status;

    always @(posedge clk) begin
        if (!rst) begin
            last_status <= 0;
        end
        else if (flush) begin
            last_status <= 0;
        end
        else if (stall_current_stage && !stall_next_stage) begin
            last_status <= 0;
        end
        else if (!stall_current_stage) begin
            last_status <= in;
        end
    end

endmodule // PipelineDeliver
