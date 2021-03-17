ENTITY apostila6pag5 IS     -- som_1a 
	PORT (a, b, ve: IN BIT; -- a, b, ve input binario
		  s, vs: OUT BIT);  -- s, vs output binario
END apostila6pag5;

ARCHITECTURE testeapostila6pag5 OF apostila6pag5 IS
BEGIN 
	s <= a XOR b XOR ve;                        -- soma
	vs<= (a AND b) OR (a AND ve) OR (b AND ve); -- vai um (overflow)
END testeapostila6pag5;