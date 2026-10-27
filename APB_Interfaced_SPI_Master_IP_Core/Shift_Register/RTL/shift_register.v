module Shift_register(
    input pclk,
    input PRESET_n,
    input ss_i,
    input send_data_i,
    input lsbfe_i,
    input cpha_i,
    input cpol_i,
    input miso_receive_sclk,
    input miso_receive_sclk0,
    input mosi_send_sclk,
    input mosi_send_sclk0,
    input miso_i,
    input receive_data_i,
    input [7:0] data_mosi_i,
    output reg mosi_o,
    output [7:0] data_miso_o
);
reg [7:0] shift_reg;
reg [7:0] temp_reg;
reg [2:0] count;
reg [2:0] count1;
reg [2:0] count2;
reg [2:0] count3;
always @(posedge pclk or negedge PRESET_n)
begin
    if(!PRESET_n)
        shift_reg <= 8'b0;
    else
    begin
        if(send_data_i)
            shift_reg <= data_mosi_i;
        else
            shift_reg <= shift_reg;
    end
end
assign data_miso_o = receive_data_i ? temp_reg : 8'b0;
always @(posedge pclk or negedge PRESET_n)
begin
    if(!PRESET_n)
    begin
        mosi_o <= 1'b0;
        count <= 3'd0;
        count1 <= 3'd7;
    end
    else
    begin
        if(!ss_i)
        begin
            if((!cpha_i && cpol_i) || (cpha_i && !cpol_i))
            begin
                if(lsbfe_i)
                begin
                    if(count <= 3'd7)
                    begin
                        if(mosi_send_sclk0)
                        begin
                            mosi_o <= shift_reg[count];
                            count <= count + 1'b1;
                        end
                        else
                            count <= count;
                    end
                    else
                    begin
                        count <= 3'd0;
                    end
                end
                else
                begin
                    if(count1 >= 3'd0)
                    begin
                        if(mosi_send_sclk0)
                        begin
                            mosi_o <= shift_reg[count1];
                            count1 <= count1 - 1'b1;
                        end
                    end
                    else
                    begin
                        count1 <= 3'd7;
                    end
                end
            end

            else if((!cpha_i && !cpol_i) || (cpha_i && cpol_i))
            begin
                if(lsbfe_i)
                begin
                    if(count <= 3'd7)
                    begin
                        if(mosi_send_sclk)
                        begin
                            mosi_o <= shift_reg[count];
                            count <= count + 1'b1;
                        end
                    end
                    else
                    begin
                        count <= 3'd0;
                    end
                end
                else
                begin
                    if(count1 >= 3'd0)
                    begin
                        if(mosi_send_sclk)
                        begin
                            mosi_o <= shift_reg[count1];
                            count1 <= count1 - 1'b1;
                        end
                    end
                    else
                    begin
                        count1 <= 3'd7;
                    end
                end
            end
        end
    end
end
// MISO receive
always @(posedge pclk or negedge PRESET_n)
begin
    if(!PRESET_n)
    begin
        temp_reg <= 8'b0;
        count2 <= 3'd0;
        count3 <= 3'd7;
    end
    else
    begin
        if(!ss_i)
        begin
            if((!cpha_i && cpol_i) || (cpha_i && !cpol_i))
            begin
                if(lsbfe_i)
                begin
                    if(count2 <= 3'd7)
                    begin
                        if(miso_receive_sclk0)
                        begin
                            temp_reg[count2] <= miso_i;
                            count2 <= count2 + 1'b1;
                        end
                    end
                    else
                    begin
                        count2 <= 3'd0;
                    end
                end
                else
                begin
                    if(count3 >= 3'd0)
                    begin
                        if(miso_receive_sclk0)
                        begin
                            temp_reg[count3] <= miso_i;
                            count3 <= count3 - 1'b1;
                        end
                    end
                    else
                    begin
                        count3 <= 3'd7;
                    end
                end
            end

            else if((!cpha_i && !cpol_i) || (cpha_i && cpol_i))
            begin
                if(lsbfe_i)
                begin
                    if(count2 <= 3'd7)
                    begin
                        if(miso_receive_sclk)
                        begin
                            temp_reg[count2] <= miso_i;
                            count2 <= count2 + 1'b1;
                        end
                    end
                    else
                    begin
                        count2 <= 3'd0;
                    end
                end
                else
                begin
                    if(count3 >= 3'd0)
                    begin
                        if(miso_receive_sclk)
                        begin
                            temp_reg[count3] <= miso_i;
                            count3 <= count3 - 1'b1;
                        end
                    end
                    else
                    begin
                        count3 <= 3'd7;
                    end
                end
            end
        end
    end
end

endmodule