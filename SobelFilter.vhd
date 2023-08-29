----------------------------------------------------------------------------------
-- Creator: 		Marzieh Ghayour
-- Student ID: 	98242112
-- Module Name:   SobelFilter - Behavioral 
-- Project Name: 	Edge Ditection
-- Description: 	FPGA Project
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use std.textio.all;

entity SobelFilter is
		generic(PicSize : integer := 128);
		port(
				clk	 : in std_logic;
				rst	 : in std_logic
				);
end SobelFilter;

architecture arch of SobelFilter is
type Matrix is array(0 to PicSize+1, Picsize+1 downto 0) of integer;
type state is (read_file, calculate_kernel, sum_kernels, filter_pic, write_file);
signal pr_state, nx_state : state := read_file;
signal Picture, Xkernel, Ykernel, filtered_pic : Matrix;
file inputpic : text;
file outputpic : text;

begin
lower:		process(clk)--rst
				begin
					if(rst = '1') then
						pr_state <= read_file;
					elsif(rising_edge(clk)) then
						pr_state <= nx_state;
					end if;
				end process lower;	
				
upper:		process(pr_state)

				--file specifications
				variable pixeldata,pixeldata2 : integer;
				variable txtline,txtline2 : line;
				
				begin
					case pr_state is
					--read image from txt file
						when read_file =>
							file_open(inputpic,"values1.txt",read_mode); --flower picture(pic1)
							--file_open(inputpic,"values2.txt",read_mode); --dog picture(pic2)

							for y_c in 0 to PicSize+1 loop
								for x_c in 0 to PicSize+1 loop
									if(y_c = 0 or y_c = PicSize+1 or x_c = 0 or x_c = PicSize+1) then
										Picture(y_c,x_c) <= 0;	
									else
										readline(inputpic, txtline);
										read(txtline, pixeldata);
										Picture(y_c,x_c) <= pixeldata;
									end if;
								end loop;
							end loop;
							file_close(inputpic);
							nx_state <= calculate_kernel;
							
						--find Xkernel and Ykernel of each pixel 
						when calculate_kernel =>
							for y_c in 1 to PicSize loop
								for x_c in 1 to PicSize loop
									--Xkernel
									Xkernel(y_c,x_c) <= (-1*Picture(y_c-1,x_c-1)
									 -2*Picture(y_c,x_c-1)
									 -1*Picture(y_c+1,x_c-1)
									 +1*Picture(y_c-1,x_c+1)
									 +2*Picture(y_c,x_c+1)
									 +1*Picture(y_c+1,x_c+1));
								end loop;
							end loop;
							for y_c in 1 to PicSize loop
								for x_c in 1 to PicSize loop
									--Ykernel
									Ykernel(y_c,x_c) <= (-1*Picture(y_c-1,x_c-1)
									 -2*Picture(y_c-1,x_c)
									 -1*Picture(y_c-1,x_c+1)
									 +1*Picture(y_c+1,x_c-1)
									 +2*Picture(y_c+1,x_c)
									 +1*Picture(y_c+1,x_c+1));
								end loop;
							end loop;
							nx_state <= sum_kernels;
							
						--sum them up	
						when sum_kernels =>
							for y_c in 1 to PicSize loop
								for x_c in 1 to PicSize loop
									filtered_pic(y_c,x_c) <= abs(Xkernel(y_c,x_c)) + abs(Ykernel(y_c,x_c));
								end loop;
							end loop;
							nx_state <= filter_pic;
							
							
						when filter_pic =>
							for y_c in 1 to PicSize loop
								for x_c in 1 to PicSize loop
									if(filtered_pic(y_c,x_c) >= 254) then
										filtered_pic(y_c,x_c) <= 255;
									elsif(filtered_pic(y_c,x_c) <= 50) then
										filtered_pic(y_c,x_c) <= 0;
									end if;
								end loop;
							end loop;
							nx_state <= write_file;
						
						--write file
						when write_file =>
							file_open(outputpic, "write1.txt", write_mode);  --flower picture(pic1)
							--file_open(outputpic,"write2.txt",write_mode); --dog picture(pic2)

							for y_c in 1 to PicSize loop
								for x_c in 1 to PicSize loop
									pixeldata2 := filtered_pic(y_c,x_c);
									write(txtline2,pixeldata2);
									writeline(outputpic,txtline2);
								end loop;
							end loop;
--							file_close(outputpic);
							nx_state <= read_file;
								
						end case;
			end process upper;
				

end arch;

