library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.ALL;
use IEEE.std_logic_unsigned.ALL;

LIBRARY lpm;
USE lpm.all;

ENTITY calcRev1 IS 
GENERIC(frequencia	: NATURAL := 250000); -- 250khz p/validação e teste
    PORT(clk						: IN STD_LOGIC; 							-- não utilizado
			rst						: IN STD_LOGIC;							-- rst em ALTO
			a, b						: IN STD_LOGIC_VECTOR(3 DOWNTO 0);  -- 4 bits de entrada para os operandos
			sel_1,sel_2				: IN STD_LOGIC; 							-- seleciona operação
			overflow					: OUT STD_LOGIC;							
			res_negativo			: OUT STD_LOGIC;							-- quando nº< 0 => (-)
			led						: OUT STD_LOGIC_VECTOR(1 TO 8);		-- leds p/ teste e verificação
			sa,sb,sc,sd,se,sf,sg	: OUT STD_LOGIC_VECTOR(2 downto 0));-- saída p/ displays de 7 segm.
END calcRev1;

ARCHITECTURE teste_calcRev1 OF calcRev1 IS 

-- aprimorar em revisão: unificar decodificadores
COMPONENT decod7segSomaUnid -- 
	PORT (seletor					: IN STD_LOGIC_VECTOR(1 downto 0);
			entrada_display		: IN STD_LOGIC_VECTOR(5 downto 0);
			a, b, c, d, e, f, g 	: OUT STD_LOGIC);
END COMPONENT;
	
COMPONENT decod7segSomaDez2
	PORT (seletor					: IN STD_LOGIC_VECTOR(1 downto 0);
			entrada_display		: IN STD_LOGIC_VECTOR(5 downto 0);
			a, b, c, d, e, f, g 	: OUT STD_LOGIC);		
END COMPONENT;

COMPONENT apostila6pag6 -- somador_3bits
GENERIC (n 		: INTEGER);
	PORT (x, y	: IN STD_LOGIC_VECTOR(n-1 DOWNTO 0);
         cin	: IN STD_LOGIC;  
			soma 	: OUT STD_LOGIC_VECTOR(n-1 DOWNTO 0); 
			cout	: OUT STD_LOGIC);
END COMPONENT;

-- megafunction criada pelo wizard para a multiplicaçao
COMPONENT multiplicacao IS
	PORT(	dataa		: IN STD_LOGIC_VECTOR (2 DOWNTO 0);
			datab		: IN STD_LOGIC_VECTOR (2 DOWNTO 0);
			result	: OUT STD_LOGIC_VECTOR (5 DOWNTO 0));
END COMPONENT;

SIGNAL res_soma_bin			: STD_LOGIC_VECTOR(3 downto 0):= (OTHERS => '0'); 	-- resultado + ou -
SIGNAL res_multi				: STD_LOGIC_VECTOR(5 downto 0):= (OTHERS => '0'); 	-- resultado .
SIGNAL res_divi_quo			: STD_LOGIC_VECTOR(5 downto 0):= (OTHERS => '0'); 	-- quociente /
SIGNAL res_divi_resto		: STD_LOGIC_VECTOR(5 downto 0):= (OTHERS => '0'); 	-- resto 		/
SIGNAL res_display			: STD_LOGIC_VECTOR(5 downto 0):= (OTHERS => '0'); 	-- entrada do display de 7 segm.
SIGNAL sel_mux					: STD_LOGIC_VECTOR(1 DOWNTO 0):= (OTHERS => '0'); 	-- define operaçao
SIGNAL overflow_soma			: STD_LOGIC;												  	-- overflow da soma
SIGNAL comple2_a, comple2_b: STD_LOGIC_VECTOR(3 downto 0):= (OTHERS => '0'); 	-- complemento de 2
SIGNAL acompanha				: STD_LOGIC_VECTOR(1 downto 0):= (OTHERS => '0'); 	-- inclui dois bits quando soma/sub
SIGNAL pulso1s					: STD_LOGIC; 												  	-- pulso de 1hz (não utilizado)
SIGNAL numerador				: INTEGER RANGE 0 TO 99; 									-- num da divisão
SIGNAL denominador			: INTEGER RANGE 0 TO 99;									-- dem. ...
SIGNAL quociente				: INTEGER RANGE 0 TO 99;									-- resultado da divisão
SIGNAL resto					: INTEGER RANGE 0 TO 99;									-- resto ...

BEGIN
sel_mux <= sel_2 & sel_1;
-- cria complemento 2 e define o sinal
compl_2: PROCESS(a,b,sel_mux) 
VARIABLE a_x, b_y	: UNSIGNED(3 downto 0):= (OTHERS => '0');
VARIABLE t_a, t_b : UNSIGNED(2 downto 0):= (OTHERS => '0');
	BEGIN
	-- conversão de a e b de STD_LOGIC_VECTOR p/ UNSIGNED
	t_a := UNSIGNED(a(2 downto 0));
	t_b := UNSIGNED(b(2 downto 0));
		IF (a(3) = '1') THEN 								-- quando informado que o nº é negativo
			a_x := NOT (UNSIGNED('0'&a(2 downto 0))); -- complemento de 1: inverte-se os bits
			a_x := a_x+1;										-- complemento de 2: soma-se 1
		ELSE 
			a_x := UNSIGNED(a);													
			acompanha <= "00";								-- 2 bits incluídos para complementar a largura de entrada do display
		END IF;
		IF (b(3) = '1') THEN 
			b_y := NOT (UNSIGNED('0'&b(2 downto 0)));	-- idem a, a_x
			b_y := b_y+1;
		ELSE 
			b_y := UNSIGNED(b);
		END IF;	
-- Rotina que determina se o sinal é negativo e também define o SIGNAL acompanha
		IF (t_a = 0 OR t_b = 0) THEN 
			acompanha <= "00";
			res_negativo<='0';
		ELSIF ((a(3) = '0' AND b(3) = '0') AND (sel_mux = "10" OR sel_mux = "11")) THEN 
			acompanha <= "00";
			res_negativo<='0';
		ELSIF (a(3) = '1' AND b(3) = '1' AND (sel_mux = "10" OR sel_mux = "11")) THEN 
			acompanha <= "00";
			res_negativo<='0';
		ELSIF ((a(3) = '1' OR b(3) = '1') AND (sel_mux = "10" OR sel_mux = "11")) THEN 
			acompanha <= "11";
			res_negativo<='1';	-- multiplicação ou divisão por um operando > 0 e outro < 0 
		ELSIF (a(3) = '1' AND b(3) = '1' AND sel_mux = "01") THEN 
			acompanha <= "11";
			res_negativo<='1';	-- soma de nº(s) negativos
		ELSIF ((a(3) = '1' OR b(3) = '1') AND sel_mux ="01") THEN 
			IF (a(3) = '1' AND t_a>t_b) THEN
				acompanha <= "11";
				res_negativo<='1';	-- soma de operando de sinais opostos com negativo de maior módulo
			ELSIF (b(3) = '1' AND t_b>t_a) THEN	
				acompanha <= "11";	-- idem anterior
				res_negativo<='1';
			ELSE 
				acompanha <= "00";
				res_negativo<='0';
			END IF;
		END IF;
		comple2_a<= STD_LOGIC_VECTOR(a_x); 	-- converte a_x de UNSIGNED para STD_LOGIC_VECTOR
		comple2_b<= STD_LOGIC_VECTOR(b_y);	-- idem anterior
END PROCESS compl_2;
-- LEDS - mostram em dois conjutos de 4 leds, as entradas do usuário
-- sinal b	b(2)		b(1)		b(0)		sinal a	a(2)		a(1)		a(0)
-- led(8)	led(7)	led(6)	led(5)	led(4)	led(3)	led(2)	led(1)
PROCESS(a,b,res_soma_bin)
	BEGIN 
	FOR i IN a'RANGE LOOP
		IF a(i)='1' THEN 
			led(i+1) <= '1'; 
		ELSE led(i+1) <= '0';	
		END IF;
	END LOOP;
	FOR j IN b'RANGE LOOP
		IF b(j)='1' THEN 
			led(j+5) <= '1'; 
		ELSE led(j+5) <= '0';	
		END IF;
	END LOOP;
END PROCESS;
-- Realiza operações
soma:	apostila6pag6 GENERIC MAP (4) PORT MAP	(comple2_a,comple2_b,'0',res_soma_bin,overflow_soma); -- soma ou sub
multi: multiplicacao PORT MAP (a(2 DOWNTO 0),b(2 DOWNTO 0),res_multi);										-- multplica
-- Rotina para divisão (aprimorar em revisão: colocar em bloco, procedimento ou criar um componente)
	numerador 	<= to_integer(UNSIGNED(a(2 DOWNTO 0))); 	-- converte para inteiro
	denominador <= to_integer(UNSIGNED(b(2 DOWNTO 0)));	-- idem anterior
	quociente 	<=  numerador/denominador; -- a/b			-- quociente de a/b
	resto <= numerador MOD denominador;							-- rest de a/b
	res_divi_quo 	<= std_logic_vector(to_unsigned(quociente, res_divi_quo'length)); -- converte de inteiro para STD_LOGIC_VECTOR
-- Define o que aparece no display de 7 segmentos reservado para resto de divisões
PROCESS(a,b,sel_mux)
	BEGIN
		IF sel_mux = "11" THEN 				-- seleção para divisão 
			res_divi_resto <= std_logic_vector(to_unsigned(resto, res_divi_resto'length)); -- converte
		ELSE res_divi_resto <= "000000";	-- (aprimorar em Revisão => não mostrar nada ao invés de 0)				 
		END IF;
END PROCESS;
-- Determina qual a entrada no display de 7 segmentos	
mux: PROCESS(sel_mux,a,b) 
	BEGIN
		CASE sel_mux IS
			WHEN "01" => res_display <= STD_LOGIC_VECTOR(acompanha&res_soma_bin); 	-- resultado da soma/sub
			WHEN "10" => res_display <= STD_LOGIC_VECTOR(res_multi); 					-- resultado da multiplicação
			WHEN "11" => res_display <= STD_LOGIC_VECTOR(res_divi_quo); 				-- resultado da divisão
			WHEN OTHERS => res_display <= "000000";	-- (aprimorar em Revisão => não mostrar nada ao invés de 0)	
		END CASE;
	END PROCESS;
-- Decodificadores e displays de 7 segmentos
u_u:	decod7segSomaUnid 	-- display da unidade (bit menos significativo)
	PORT MAP(sel_mux,res_display, sa(0), sb(0), sc(0), sd(0), se(0), sf(0), sg(0));
u_d:	decod7segSomaDez2  	-- display da dezena (bit mais significativo)
	PORT MAP(sel_mux,res_display, sa(1), sb(1), sc(1), sd(1), se(1), sf(1), sg(1));
u_meg:	decod7segSomaUnid -- display que mostra o resto divisão
	PORT MAP(sel_mux,res_divi_resto, sa(2), sb(2), sc(2), sd(2), se(2), sf(2), sg(2));
END teste_calcRev1;
