module uart_tx(
    input clk, rst,
    input tx_active,
    output tx
);
parameter clk_rate = 27000000;
parameter baud_rate = 115200;
parameter clk_div = clk_rate / baud_rate; // clock division according to baud rate

parameter IDLE = 0, START = 1, DATA = 2, STOP = 3; // FSM states for TX

reg[7:0] data = 65; // start from character 'A'
reg[2:0] data_index; // keep track of the bits sent
reg[9:0] clk_count;
reg[1:0] state;

reg tx_state; 
reg btn_state;
reg[23:0] btn_counter;

always@(posedge clk) begin
    if (tx_active == 0) btn_counter <= btn_counter + 1;
    else btn_counter <= 0;

    if (btn_counter >= 13500000) btn_state <= 1'b1;
    else btn_state <= 0;
end

always@(posedge clk, negedge rst) begin
    if (!rst) begin
        data <= 65;
        state <= IDLE;
        data_index <= 0;
        clk_count <= 0;
        tx_state <= 1'b1; // idle state when tx is pulled high
    end
    else begin
        case (state) 
        IDLE: begin
            tx_state <= 1'b1;
            clk_count <= 0;
            data_index <= 0;
            data <= 65;

            if (btn_state) state <= START;
        end

        START: begin
            tx_state <= 1'b0; // pull low for one clock cycle
            if (clk_count < clk_div) clk_count <= clk_count + 1;
            else begin
                state <= DATA; 
                clk_count <= 0;
            end
        end

        DATA: begin
            if (clk_count < clk_div) begin
                clk_count <= clk_count + 1;
                tx_state <= data[data_index];
            end
            else begin
                if (data_index == 3'b111) begin
                    state <= STOP; 
                    clk_count <= 0;
                end
                else begin
                    clk_count <= 0; 
                    data_index <= data_index + 1;
                end
            end
        end

        STOP: begin
            tx_state <= 1'b0;
            if (clk_count < clk_div) clk_count <= clk_count + 1;
            else begin
                if (data != 90) begin
                    data <= data + 1;
                    state <= START;
                end
                else state <= IDLE;

                tx_state <= 1'b1;
                data_index <= 0;
                clk_count <= 0;
            end
        end
        endcase
    end
end

assign tx = tx_state;
endmodule