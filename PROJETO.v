//MÓDULO EXPRESSO 
module expresso(clk, money, sen_borra, sen_grao, sen_temp, nvl_agua, sel_ciclos, rst, coffee, balance,clock1hz,busy);
input clk, money, sen_borra, sen_grao, sen_temp, nvl_agua, rst,clock1hz;
input [2:0] sel_ciclos;
output reg coffee, balance, busy;

	//parametros utilizando codificação gray
	
	parameter [3:0] S1contagem_money=4'b0001; //contagem do dinheiro
	parameter [3:0] S2verifica_agua=4'b0011; //verificação do nível de água
	parameter [3:0] S3verifica_borra=4'b0010; //verifica do nível de borra
	parameter [3:0] S4sel_ciclos=4'b0110; // espera de 10 seg para a seleçao do numero de ciclos de moagem
	parameter [3:0] S5verifica_temp=4'b0111; //verifica a temperatura da agua
	parameter [3:0] S6ciclo_moagem=4'b0101; //ciclo de moagem
	parameter [3:0] S7verifica_graos=4'b0100; //verifica a qtd de graos a cada ciclo de moagem
	parameter [3:0] S8espera=4'b1100; //espera de 10seg caso não haja grãos suficientes
	parameter [3:0] S9cafe=4'b1101; //despeja a água para a produção de cafe

	reg [3:0] next_state;
	reg [3:0] current_state;
	reg [3:0] contador=0;
	reg [2:0] n_ciclos;
	reg enable=1'b0;
	reg aux;
	
	//contador 10 segundos
	always@(posedge clock1hz)   
        begin
				enable=aux;
            if(enable)
                contador=contador+1;
				if(contador==10)begin
				enable=0;
				contador=0;
				end
        end


	always @(posedge clk)
		begin
			if(rst) begin
				current_state<=S1contagem_money;
				busy= 0;
				end
			else begin
				current_state<=next_state;
				busy= 1;
				end
		end


	always @(current_state or sen_borra or sen_grao or sen_temp or nvl_agua or sel_ciclos)begin
			case(current_state)
			S1contagem_money: begin
							 if(money== 50)
								next_state<=S2verifica_agua; //se o dinheiro estiver correto passa para o próximo estado
							 else if(money< 50)
							 	next_state<=S1contagem_money; //se o dinheiro for menos que o esperado mantém no estado até que haja o valor correto
							 else begin
							 	next_state<=S2verifica_agua; //se o dinheiro for maior que o esperado passa para o próximo estado e devolve o troco
								balance = money - 50;
								end
							 end
			S2verifica_agua: begin 
							 if(nvl_agua)
								next_state<=S3verifica_borra; //se o nível de água for o mínimo necessário passa para o próximo estado
							 else 
							 	next_state<=S2verifica_agua; //se não mantém o estado e aguarda a adição de água
								end
			S3verifica_borra: begin 
								if(!sen_borra)
								next_state<=S4sel_ciclos; //se a borra não estiver cheia passa para o próximo estado
							  else 
							  	next_state<=S3verifica_borra; //se estiver mantém o estado
								end
			S4sel_ciclos: begin 
								aux=1'b1;
								case(sel_ciclos)
								3'b000: n_ciclos<=1;
								3'b001: n_ciclos<=2;
								3'b010: n_ciclos<=3;
								3'b011: n_ciclos<=4;
								3'b100: n_ciclos<=5;
								3'b101: n_ciclos<=6;
								3'b110: n_ciclos<=7;
								3'b111: n_ciclos<=8;
								endcase
								if(contador==10)
									next_state<=S5verifica_temp; //Espera 10 segundos para a escolha da quantidade de ciclos
								aux=1'b0;
								end
			S5verifica_temp: begin
									if(sen_temp)
									next_state<=S6ciclo_moagem; //Verifica se a temperatura esta ideal e passa para o proximo estado
									else
									next_state<=S5verifica_temp; //Continua esperando a temperatura ideal
									end
			S6ciclo_moagem: begin
									case(n_ciclos)
                                0: begin
                                    end
                                1: begin                          
											  next_state <= S7verifica_graos;
                                    end
                                2: begin
                                   n_ciclos <= (n_ciclos-1);
											  next_state <= S7verifica_graos;
                                    end
                                3: begin     
                                   n_ciclos <= (n_ciclos-1);
											  next_state <= S7verifica_graos;
                                    end
                                4: begin
                                   n_ciclos <= (n_ciclos-1);
											  next_state <= S7verifica_graos;
                                    end
                                5: begin
                                   n_ciclos <= (n_ciclos-1);
											  next_state <= S7verifica_graos;
                                    end
                                6: begin
                                   n_ciclos <= (n_ciclos-1);
											  next_state <= S7verifica_graos;
                                    end
                                7: begin
                                   n_ciclos <= (n_ciclos-1);
											  next_state <= S7verifica_graos;
                                    end
                                8: begin
                                   n_ciclos <= (n_ciclos-1);
											  next_state <= S7verifica_graos;
                                    end
										  default: next_state<=S7verifica_graos;
                            endcase
								end
			S7verifica_graos: begin //verifica se possui grãos
									if(sen_grao)
										next_state<=S6ciclo_moagem; //se possuir continua o ciclo de moagem
									else
										next_state<=S8espera; //caso não possua vai para o estado de espera
									end
			S8espera: begin
						 aux=1'b1;
						 if(contador==10)begin //aguarda 10 segundos para a inserção de grãos
								aux=1'b0;
								if(sen_grao) //se após 10 segundos houver grãos suficientes
										next_state<=S6ciclo_moagem; //continua a moagem
								 else
										next_state<=S4sel_ciclos; // se não volta para a seleção do número de ciclos
												end
							end
			S9cafe: next_state<=S1contagem_money;				
					endcase
			end

	always@ (current_state)begin
		case(current_state)
			S1contagem_money: coffee=0;
			S2verifica_agua: coffee=0;
			S3verifica_borra: coffee=0;
			S4sel_ciclos: coffee=0;
			S5verifica_temp: coffee=0;
			S6ciclo_moagem: coffee=0;
			S7verifica_graos: coffee= 0;
			S8espera: coffee=0;
			S9cafe: coffee=1;
		endcase
		end
endmodule 


//MÓDULO CAFÉ MÉDIO

module medio(clk, money, sen_borra, sen_grao, sen_temp, nvl_agua, sel_ciclos, rst, coffee, balance,clock1hz,busy);
input clk, money, sen_borra, sen_grao, sen_temp, nvl_agua, rst,clock1hz;
input [2:0] sel_ciclos;
output reg coffee, balance, busy;

	//parametros utilizando codificação gray
	
	parameter [3:0] S1contagem_money=4'b0001; //contagem do dinheiro
	parameter [3:0] S2verifica_agua=4'b0011; //verificação do nível de água
	parameter [3:0] S3verifica_borra=4'b0010; //verifica do nível de borra
	parameter [3:0] S4sel_ciclos=4'b0110; // espera de 10 seg para a seleçao do numero de ciclos de moagem
	parameter [3:0] S5verifica_temp=4'b0111; //verifica a temperatura da agua
	parameter [3:0] S6ciclo_moagem=4'b0101; //ciclo de moagem
	parameter [3:0] S7verifica_graos=4'b0100; //verifica a qtd de graos a cada ciclo de moagem
	parameter [3:0] S8espera=4'b1100; //espera de 10seg caso não haja grãos suficientes
	parameter [3:0] S9cafe=4'b1101; //despeja a água para a produção de cafe

	reg [3:0] next_state;
	reg [3:0] current_state;
	reg [3:0] contador=0;
	reg [2:0] n_ciclos;
	reg enable=1'b0;
	reg aux;
	always@(posedge clock1hz)   
        begin
				enable=aux;
            if(enable)
                contador=contador+1;
				if(contador==10)begin
				enable=0;
				contador=0;
				end
        end


	always @(posedge clk)
		begin
			if(rst) begin
				current_state<=S1contagem_money;
				busy= 0;
				end
			else begin
				current_state<=next_state;
				busy= 1;
				end
		end


	always @(current_state or sen_borra or sen_grao or sen_temp or nvl_agua or sel_ciclos)begin
			case(current_state)
			S1contagem_money: begin
							 if(money== 50)
								next_state<=S2verifica_agua; //se o dinheiro estiver correto passa para o próximo estado
							 else if(money< 50)
							 	next_state<=S1contagem_money; //se o dinheiro for menos que o esperado mantém no estado até que haja o valor correto
							 else begin
							 	next_state<=S2verifica_agua; //se o dinheiro for maior que o esperado passa para o próximo estado e devolve o troco
								balance = money - 50;
								end
							 end
			S2verifica_agua: begin 
							 if(nvl_agua)
								next_state<=S3verifica_borra; //se o nível de água for o mínimo necessário passa para o próximo estado
							 else 
							 	next_state<=S2verifica_agua; //se não mantém o estado e aguarda a adição de água
								end
			S3verifica_borra: begin 
								if(!sen_borra)
								next_state<=S4sel_ciclos; //se a borra não estiver cheia passa para o próximo estado
							  else 
							  	next_state<=S3verifica_borra; //se estiver mantém o estado
								end
			S4sel_ciclos: begin 
								aux=1'b1;
								case(sel_ciclos)
								3'b000: n_ciclos<=1;
								3'b001: n_ciclos<=2;
								3'b010: n_ciclos<=3;
								3'b011: n_ciclos<=4;
								3'b100: n_ciclos<=5;
								3'b101: n_ciclos<=6;
								3'b110: n_ciclos<=7;
								3'b111: n_ciclos<=8;
								endcase
								if(contador==10)
									next_state<=S5verifica_temp; //Espera 10 segundos para a escolha da quantidade de ciclos
								aux=1'b0;
								end
			S5verifica_temp: begin
									if(sen_temp)
									next_state<=S6ciclo_moagem; //Verifica se a temperatura esta ideal e passa para o proximo estado
									else
									next_state<=S5verifica_temp; //Continua esperando a temperatura ideal
									end
			S6ciclo_moagem: begin
									case(n_ciclos)
                                0: begin
                                    end
                                1: begin                          
											  next_state <= S7verifica_graos;
                                    end
                                2: begin
                                   n_ciclos <= (n_ciclos-1);
											  next_state <= S7verifica_graos;
                                    end
                                3: begin     
                                   n_ciclos <= (n_ciclos-1);
											  next_state <= S7verifica_graos;
                                    end
                                4: begin
                                   n_ciclos <= (n_ciclos-1);
											  next_state <= S7verifica_graos;
                                    end
                                5: begin
                                   n_ciclos <= (n_ciclos-1);
											  next_state <= S7verifica_graos;
                                    end
                                6: begin
                                   n_ciclos <= (n_ciclos-1);
											  next_state <= S7verifica_graos;
                                    end
                                7: begin
                                   n_ciclos <= (n_ciclos-1);
											  next_state <= S7verifica_graos;
                                    end
                                8: begin
                                   n_ciclos <= (n_ciclos-1);
											  next_state <= S7verifica_graos;
                                    end
										  default: next_state<=S7verifica_graos;
                            endcase
								end
			S7verifica_graos: begin
									if(sen_grao)
										next_state<=S6ciclo_moagem;
									else
										next_state<=S8espera;
									end
			S8espera: begin
						 aux=1'b1;
						 if(contador==10)begin
								aux=1'b0;
								if(sen_grao)
										next_state<=S6ciclo_moagem;
								 else
										next_state<=S4sel_ciclos;
												end
							end
			S9cafe: next_state<=S1contagem_money;				
					endcase
			end

	always@ (current_state)begin
		case(current_state)
			S1contagem_money: coffee=0;
			S2verifica_agua: coffee=0;
			S3verifica_borra: coffee=0;
			S4sel_ciclos: coffee=0;
			S5verifica_temp: coffee=0;
			S6ciclo_moagem: coffee=0;
			S7verifica_graos: coffee= 0;
			S8espera: coffee=0;
			S9cafe: coffee=1;
		endcase
		end
endmodule 

// MÓDULO CAFÉ CHEIO

module cheio(clk, money, sen_borra, sen_grao, sen_temp, nvl_agua, sel_ciclos, rst, coffee, balance,clock1hz,busy);
input clk, money, sen_borra, sen_grao, sen_temp, nvl_agua, rst,clock1hz;
input [2:0] sel_ciclos;
output reg coffee, balance, busy;

	//parametros utilizando codificação gray
	
	parameter [3:0] S1contagem_money=4'b0001; //contagem do dinheiro
	parameter [3:0] S2verifica_agua=4'b0011; //verificação do nível de água
	parameter [3:0] S3verifica_borra=4'b0010; //verifica do nível de borra
	parameter [3:0] S4sel_ciclos=4'b0110; // espera de 10 seg para a seleçao do numero de ciclos de moagem
	parameter [3:0] S5verifica_temp=4'b0111; //verifica a temperatura da agua
	parameter [3:0] S6ciclo_moagem=4'b0101; //ciclo de moagem
	parameter [3:0] S7verifica_graos=4'b0100; //verifica a qtd de graos a cada ciclo de moagem
	parameter [3:0] S8espera=4'b1100; //espera de 10seg caso não haja grãos suficientes
	parameter [3:0] S9cafe=4'b1101; //despeja a água para a produção de cafe

	reg [3:0] next_state;
	reg [3:0] current_state;
	reg [3:0] contador=0;
	reg [2:0] n_ciclos;
	reg enable=1'b0;
	reg aux;
	always@(posedge clock1hz)   
        begin
				enable=aux;
            if(enable)
                contador=contador+1;
				if(contador==10)begin
				enable=0;
				contador=0;
				end
        end

	always @(posedge clk)
		begin
			if(rst) begin
				current_state<=S1contagem_money;
				busy= 0;
				end
			else begin
				current_state<=next_state;
				busy= 1;
				end
		end


	always @(current_state or sen_borra or sen_grao or sen_temp or nvl_agua or sel_ciclos)begin
			case(current_state)
			S1contagem_money: begin
							 if(money== 50)
								next_state<=S2verifica_agua; //se o dinheiro estiver correto passa para o próximo estado
							 else if(money< 50)
							 	next_state<=S1contagem_money; //se o dinheiro for menos que o esperado mantém no estado até que haja o valor correto
							 else begin
							 	next_state<=S2verifica_agua; //se o dinheiro for maior que o esperado passa para o próximo estado e devolve o troco
								balance = money - 50;
								end
							 end
			S2verifica_agua: begin 
							 if(nvl_agua)
								next_state<=S3verifica_borra; //se o nível de água for o mínimo necessário passa para o próximo estado
							 else 
							 	next_state<=S2verifica_agua; //se não mantém o estado e aguarda a adição de água
								end
			S3verifica_borra: begin 
								if(!sen_borra)
								next_state<=S4sel_ciclos; //se a borra não estiver cheia passa para o próximo estado
							  else 
							  	next_state<=S3verifica_borra; //se estiver mantém o estado
								end
			S4sel_ciclos: begin 
								aux=1'b1;
								case(sel_ciclos)
								3'b000: n_ciclos<=1;
								3'b001: n_ciclos<=2;
								3'b010: n_ciclos<=3;
								3'b011: n_ciclos<=4;
								3'b100: n_ciclos<=5;
								3'b101: n_ciclos<=6;
								3'b110: n_ciclos<=7;
								3'b111: n_ciclos<=8;
								endcase
								if(contador==10)
									next_state<=S5verifica_temp; //Espera 10 segundos para a escolha da quantidade de ciclos
								aux=1'b0;
								end
			S5verifica_temp: begin
									if(sen_temp)
									next_state<=S6ciclo_moagem; //Verifica se a temperatura esta ideal e passa para o proximo estado
									else
									next_state<=S5verifica_temp; //Continua esperando a temperatura ideal
									end
			S6ciclo_moagem: begin
									case(n_ciclos)
                                0: begin
                                    end
                                1: begin                          
											  next_state <= S7verifica_graos;
                                    end
                                2: begin
                                   n_ciclos <= (n_ciclos-1);
											  next_state <= S7verifica_graos;
                                    end
                                3: begin     
                                   n_ciclos <= (n_ciclos-1);
											  next_state <= S7verifica_graos;
                                    end
                                4: begin
                                   n_ciclos <= (n_ciclos-1);
											  next_state <= S7verifica_graos;
                                    end
                                5: begin
                                   n_ciclos <= (n_ciclos-1);
											  next_state <= S7verifica_graos;
                                    end
                                6: begin
                                   n_ciclos <= (n_ciclos-1);
											  next_state <= S7verifica_graos;
                                    end
                                7: begin
                                   n_ciclos <= (n_ciclos-1);
											  next_state <= S7verifica_graos;
                                    end
                                8: begin
                                   n_ciclos <= (n_ciclos-1);
											  next_state <= S7verifica_graos;
                                    end
										  default: next_state<=S7verifica_graos;
                            endcase
								end
			S7verifica_graos: begin
									if(sen_grao)
										next_state<=S6ciclo_moagem;
									else
										next_state<=S8espera;
									end
			S8espera: begin
						 aux=1'b1;
						 if(contador==10)begin
								aux=1'b0;
								if(sen_grao)
										next_state<=S6ciclo_moagem;
								 else
										next_state<=S4sel_ciclos;
												end
							end
			S9cafe: next_state<=S1contagem_money;
				
					endcase
			end
			
	always@ (current_state)begin
		case(current_state)
			S1contagem_money: coffee=0;
			S2verifica_agua: coffee=0;
			S3verifica_borra: coffee=0;
			S4sel_ciclos: coffee=0;
			S5verifica_temp: coffee=0;
			S6ciclo_moagem: coffee=0;
			S7verifica_graos: coffee= 0;
			S8espera: coffee=0;
			S9cafe: coffee=1;
		endcase
		end
endmodule 

//MODULO PRINCIPAL
/*module Cafeteira (clk, money, sen_borra, sen_grao, sen_temp, nvl_agua, sel_ciclos, rst,clock1hz, botao1, botao2, botao3, botao4, coffee);
input clk, money, sen_borra, sen_grao, sen_temp, nvl_agua, sel_ciclos, rst,clock1hz, botao1, botao2, botao3, botao4;
output coffee, balance;

wire busy;
wire agua_ligada= 0;

	if (botao1 && !busy && !agua_ligada)
			expresso u1(.clk(clk), .money(money), .sen_borra(sen_borra), .sen_grao(sen_grao), .sen_temp(sen_temp), .nvl_agua(nvl_agua), .sel_ciclos(sel_ciclos), .rst(rst),
			.clk1hz(clk1hz), .balance(balance), .busy(busy), .coffee(coffee));
			
	else if (botao1 && agua_ligada)
		agua_ligada=0;
		
	else if(botao2 && !busy)
		medio u1(.clk(clk), .money(money), .sen_borra(sen_borra), .sen_grao(sen_grao), .sen_temp(sen_temp), .nvl_agua(nvl_agua), .sel_ciclos(sel_ciclos), .rst(rst),.clk1hz(clk1hz), .balance(balance), .busy(busy), .coffee(coffee));
		
	else if(botao3 && !busy)
		cheio u1(.clk(clk), .money(money), .sen_borra(sen_borra), .sen_grao(sen_grao), .sen_temp(sen_temp), .nvl_agua(nvl_agua), .sel_ciclos(sel_ciclos), .rst(rst),
		.clk1hz(clk1hz), .balance(balance), .busy(busy), .coffee(coffee));
		
	else if(botao4 && !busy)begin
		agua_ligada = 1;
		busy=1;
			end

		endmodule
		*/