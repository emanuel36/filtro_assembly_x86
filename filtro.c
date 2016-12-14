#include <stdio.h>
#include <time.h>
#include <poll.h>
#include <unistd.h>

int filtro_assembly(int tfiltro, int tsinal);
void fim();
int recebeFiltro();
struct pollfd mypoll = {STDIN_FILENO, POLLIN|POLLPRI};
time_t inicio, fim_p;
double resultado;

int main(){
		int tsinal, tfiltro;
		inicio = time(NULL);

		printf("Tamanho do filtro: \n");
		recebe_tamanho_filtro:
		    if(poll(&mypoll, 1, 5000)){
		      	scanf("%d", &tfiltro);
		    }else{
			puts("\nDIGITE O TAMANHO DO FILTRO!");
		        goto recebe_tamanho_filtro;
		    }
	
		printf("Tamanho do sinal: \n");
		recebe_tamanho_sinal:
		    if(poll(&mypoll, 1, 5000)){
		      	scanf("%d", &tsinal);
		    }else{
			puts("\nDIGITE O TAMANHO DO SINAL!");
		        goto recebe_tamanho_sinal;
		    }	

		filtro_assembly(tfiltro, tsinal);

}

void fim(){
		fim_p = time(NULL);

		resultado = (fim_p - inicio);
		printf("\n%2.0f segundos\n", (resultado));		
}

int recebeFiltro(){
	printf("DIGITE OS VALORES DO FILTRO!\n");
	int valor;
    
	recebe_tamanho:
	    if(poll(&mypoll, 1, 5000)){
  	      	scanf("%d", &valor);
	    }else{
			puts("\nDIGITE O VALOR!");
	        goto recebe_tamanho;
	    }
	return valor;
}
