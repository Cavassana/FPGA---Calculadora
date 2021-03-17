library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.ALL;
use IEEE.std_logic_unsigned.ALL;

ENTITY decodificador7segmentosCalcUnid IS 
    PORT(entrada_display		: IN STD_LOGIC_VECTOR(5 downto 0);
			a, b, c, d, e, f, g 	: OUT STD_LOGIC);
END decodificador7segmentosCalcUnid;

ARCHITECTURE teste_decodificador7segmentosCalcUnid OF decodificador7segmentosCalcUnid IS 

BEGIN 	

PROCESS(entrada_display)
	VARIABLE segmentos : STD_LOGIC_VECTOR(0 TO 6); 
BEGIN
	CASE entrada_display IS 
		WHEN "000000" => segmentos := "1111110";--00
		WHEN "000001" => segmentos := "0110000";--01
		WHEN "000010" => segmentos := "1101101";--02
		WHEN "000011" => segmentos := "1111001";--03
		WHEN "000100" => segmentos := "0110011";--04
		WHEN "000101" => segmentos := "1011011";--05
		WHEN "000110" => segmentos := "1011111";--06
		WHEN "000111" => segmentos := "1110000";--07
		WHEN "001000" => segmentos := "1111111";--08
		WHEN "001001" => segmentos := "1110011";--09
		WHEN "001010" => segmentos := "1111110";--10
		WHEN "001011" => segmentos := "0110000";--11
		WHEN "001100" => segmentos := "1101101";--12
		WHEN "001101" => segmentos := "1111001";--13
		WHEN "001110" => segmentos := "0110011";--14
		WHEN "001111" => segmentos := "1011011";--15
		WHEN "010000" => segmentos := "1011111";--16
		WHEN "010001" => segmentos := "1110000";--17
		WHEN "010010" => segmentos := "1111111";--18
		WHEN "010011" => segmentos := "1110011";--19
		WHEN "010100" => segmentos := "1111110";--20
		WHEN "010101" => segmentos := "0110000";--21
		WHEN "010110" => segmentos := "1101101";--22
		WHEN "010111" => segmentos := "1111001";--23
		WHEN "011000" => segmentos := "0110011";--24
		WHEN "011001" => segmentos := "1011011";--25
		WHEN "011010" => segmentos := "1011111";--26
		WHEN "011011" => segmentos := "1110000";--27
		WHEN "011100" => segmentos := "1111111";--28
		WHEN "011101" => segmentos := "1110011";--29
		WHEN "011110" => segmentos := "1111110";--30
		WHEN "011111" => segmentos := "0110000";--31
		WHEN "100000" => segmentos := "1101101";--32
		WHEN "100001" => segmentos := "1111001";--33
		WHEN "100010" => segmentos := "0110011";--34
		WHEN "100011" => segmentos := "1011011";--35
		WHEN "100100" => segmentos := "1011111";--36
		WHEN "100101" => segmentos := "1110000";--37
		WHEN "100110" => segmentos := "1111111";--38
		WHEN "100111" => segmentos := "1110011";--39
		WHEN "101000" => segmentos := "1111110";--40
		WHEN "101001" => segmentos := "0110000";--41
		WHEN "101010" => segmentos := "1101101";--42
		WHEN "101011" => segmentos := "1111001";--43
		WHEN "101100" => segmentos := "0110011";--44
		WHEN "101101" => segmentos := "1011011";--45
		WHEN "101110" => segmentos := "1011111";--46
		WHEN "101111" => segmentos := "1110000";--47
		WHEN "110000" => segmentos := "1111111";--48
		WHEN "110001" => segmentos := "1110011";--49
		WHEN "110010" => segmentos := "1111110";--50
		WHEN "110011" => segmentos := "0110000";--51
		WHEN "110100" => segmentos := "1101101";--52
		WHEN "110101" => segmentos := "1111001";--53
		WHEN "110110" => segmentos := "0110011";--54
		WHEN "110111" => segmentos := "1011011";--55
		WHEN "111000" => segmentos := "1011111";--56
		WHEN "111001" => segmentos := "1110000";--57
		WHEN "111010" => segmentos := "1111111";--58
		WHEN "111011" => segmentos := "1110011";--59
		WHEN "111100" => segmentos := "1111110";--60
		WHEN "111101" => segmentos := "0110000";--61
		WHEN "111110" => segmentos := "1101101";--62
		WHEN "111111" => segmentos := "1111001";--63
		WHEN OTHERS   => segmentos := "0000000";-- null
	END CASE;
	a <= segmentos(0);
	b <= segmentos(1);
	c <= segmentos(2);
	d <= segmentos(3);
	e <= segmentos(4);
	f <= segmentos(5);
    g <= segmentos(6);
END PROCESS;

END teste_decodificador7segmentosCalcUnid;