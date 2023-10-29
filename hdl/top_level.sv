`timescale 1ns / 1ps
`default_nettype none // prevents system from inferring an undeclared logic (good practice)
 
module top_level(
    input wire clk_100mhz,
    input wire sys_rst,
    input wire [8:0] sw,
    output logic [2:0] rgb0, //rgb led
    output logic [2:0] rgb1 //rgb led
	);

    assign rgb1 = 0;
    assign rgb0 = 0;

    logic oscillator;
    logic fd_prop_1;
    logic bk_prop_1;
    logic [531440:0] fin_1;
    logic [531440:0] bin_1;
    logic [531440:0] fout_1;
    logic [531440:0] bout_1;
    logic [1:0][2186:0] control_out_1;

    logic fd_prop_2;
    logic bk_prop_2;
    logic [531440:0] fin_2;
    logic [531440:0] bin_2;
    logic [531440:0] fout_2;
    logic [531440:0] bout_2;
    logic [1:0][2186:0] control_out_2;

    assign fin_1 = sw;
    assign fin_2 = fout_1;
    assign oscillator = !oscillator;
    
    fc #(.N(531441)) fc_1(
    .rst_in(sys_rst),
    .clk_in(clk_100mhz),
    .oscillator(oscillator),
    .fd_prop(fd_prop_1),
    .bk_prop(bk_prop_1),
    .fin(fin_1),
    .bin(bout_2),
    .fout(fout_1),
    .bout(bout_1),
    .control_out(control_out_1)
  );

  fc #(.N(531441)) fc_2(
    .rst_in(sys_rst),
    .clk_in(clk_100mhz),
    .oscillator(oscillator),
    .fd_prop(fd_prop_2),
    .bk_prop(bk_prop_2),
    .fin(fd_prop_1),
    .bin(bin_2),
    .fout(fout_2),
    .bout(bout_2),
    .control_out(control_out_2)
  );
 
endmodule // top_level
/* I usually add a comment to associate my endmodule line with the module name
 * this helps when if you have multiple module definitions in a file
 */
 
// reset the default net type to wire, sometimes other code expects this.
`default_nettype wire