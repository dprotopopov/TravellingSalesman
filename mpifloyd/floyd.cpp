#define _CRT_SECURE_NO_WARNINGS

char *title = "Floyd's algorithm";
char *description = "Алгоритм Флойда - поиск всех кратчайших путей в графе";
/*
Алгоритм Флойда является одним из методов поиска кратчайших путей в графе. 
В отличии от алгоритма Дейкстры, который позволяет при доведении до конца построить 
ориентированное дерево кратчайших путей от некоторой вершины, метод Флойда позволяет 
найти длины всех кратчайших путей в графе. Конечно эта задача может быть решена 
и многократным применением алгоритма Дейкстры (каждый раз последовательно выбираем 
вершину от первой до N-ной, пока не получим кратчайшие пути от всех вершин графа), 
однако реализация подобной процедуры потребовала бы значительных вычислительных затрат.

Прежде чем представлять алгоритмы, необходимо ввести некоторые обозначения. 
Перенумеруем вершины исходного графа целыми числами от 1 до N. Обозначим через di,jm длину кратчайшего пути 
из вершинм i в вершину j, который в качестве промежуточных может содержать только первые m вершин графа. 
(Напомним, что промежуточной вершиной пути является любая принадлежащая ему вершина, не совпадающая 
с его начальной или конечной вершинами.) Если между вершинами i и j не существует ни одного пути указанного типа, 
то условно будем считать, что di,jm=∞. Из данного определения величин di,jm следует, что величина di,j0, 
представляет длину кратчайшего пути из вершины i в вершину j, не имеющего промежуточных вершин, 
т. е. длину кратчайшей дуги, соединяющей i с j (если такие дуги присутствуют в графе). 
для любой вершины i положим di,im= 0. Отметим далее, что величина di,jmпредставляет длину кратчайшего пути 
между вершинами i и j.

Обозначим через Dm матрицу размера NxN, элемент (i, j) которой совпадает с di,jm. 
Если в исходном графе нам известна длина каждой дуги, то мы можем сформировать матрицу D0. 
Наша цель состоит в определении матрицы DN, представляющей кратчайшие пути между всеми вершинами рассматриваемого графа.

В алгоритме Флойда в качестве исходной выступает матрица D0. 
Вначале из этой матрицы вычисляется матрица D1. 
Затем по матрице D1 вычисляется матрицав D2 и т. д. 
Процесс повторяется до тех пор, пока по матрице DN-1 не будет вычислена матрица DN.

Рассмотрим основную идею, лежащую в основе алгоритма Флойда. 
Суть алгоритма Флойда заключается в проверке того, не окажется ли путь из вершины i в вершину j короче, 
если он будет проходить через некоторую промежуточную вершину m. Предположим, что нам известны:

кратчайший путь из вершины i в вершину m, в котором в качестве промежуточных допускается использование только первых (m - 1) вершин;
кратчайший путь из вершины m в вершину j, в котором в качестве промежуточных допускается использование только первых (m - 1) вершин;
кратчайший путь из вершины i в вершину j, в котором в качестве промежуточных допускается использование только первых (m - 1) вершин.

Поскольку по предположению исходный граф не может содержать контуров отрицательной длины, 
один из двух путей — путь, совпадающий с представленным в пункте 3, или путь, являющийся объединением 
путей из пунктов 1 и 2 — должен быть кратчайшим путем из вершины i в вершину j, 
в котором в качестве промежуточных допускается использование только первых m вершин. Таким образом,

di,jm=min{ di,mm-1+ dm,jm-1; di,jm-1}

Из соотношения видно, что для вычисления элементов матрицы Dm необходимо располагать лишь элементами матрицы Dm-1. 
Более того, соответствующие вычисления могут быть проведены без обращения к исходному графу. 
Теперь мм в состоянии дать формальное описание алгоритма Флойда для нахождения на графе кратчайших путей 
между всеми парами вершин. 

Алгоритм

Перенумеровать вершины графа от 1 до N целыми числами, определить матрицу D0, каждый элемент di,j  
которой есть длина кратчайшей дуги между вершинами i и j. Если такой дуги нет, положить значение элемента 
равным ∞. Кроме того, положить значения диагонального элемента di,iравным 0.
Для целого m, последовательно принимающего значения 1...N определить по элементам матрицы Dm-1 элементы Dm
Алгоритм заканчивается получением матрицы всех кратчайших путей DN, N – число вершин графа.
 
Напомним, для определения по известным элементам матрицы Dm-1 элементов матрицы  Dm 
в алгоритме Флойда применяется рекурсивное соотношение:

di,jm=min{ di,mm-1+ dm,jm-1; di,jm-1}

di,jm – элемент матрицы Dm, di,jm-1 – элементы матрицы Dm-1 найденой на предыдущем шаге алгоритма.
*/

#include <stdio.h>
#include <string.h>
#include <ctype.h>
#include <stdlib.h>
#include <limits.h>
#include <mpi.h> 

int strempty(const char *p)
{
	if (!p)
		return (1);
	for (; *p; p++)
		if (!isspace (*p))
			return (0);
	return (1);
}
char *mystrtok(char **m, char *s, char c)
{
	char *p = s ? s : *m;
	if (!*p)
		return 0;
	*m = strchr(p, c);
	if (*m)
		*(*m)++ = 0;
	else
		*m=p+strlen(p);
	return p;
}
#ifndef max
#define max( a, b ) ( ((a) > (b)) ? (a) : (b) )
#endif

#ifndef min
#define min( a, b ) ( ((a) < (b)) ? (a) : (b) )
#endif

#define DATA_TAG 1

void _mpi_init(long *prev, long *next, int *intermedian, int m, int n, int myrank, int nrank, MPI_Status *status){
	memset(intermedian, -1, n*n*sizeof(int));
}
void _mpi_floyd(long *prev, long *next, int *intermedian, int m, int n, int myrank, int nrank, MPI_Status *status){
	int id; for (id = (int)(myrank*n*n / nrank); id < (int)((myrank + 1)*n*n / nrank); id++) {
		int i = id/n;
		int j = id%n;
		if(i != j && prev[i*n+m] != LONG_MAX && prev[m*n+j] != LONG_MAX && (prev[i*n+m] + prev[m*n+j]) < prev[i*n+j]){
			next[id] = prev[i*n+m] + prev[m*n+j];
			intermedian[id] = m;
		}
		else {
			next[id] = prev[id];
		}
	}
	/* Собираем последовательным опросом дочерних процессов суммы в хост-процессе */
	if (myrank == 0) {
		int i; for (i = 1; i < nrank; i++){
			int j = (int)(i*n*n / nrank); /* Начиная с индекса */
			int k = (int)(((i + 1)*n*n + nrank - 1) / nrank); /* До индекса ( не включтельно ) */
			if(j==k) continue;
			MPI_Recv(&next[j], k - j, MPI_LONG, i, DATA_TAG, MPI_COMM_WORLD, status);
			MPI_Recv(&intermedian[j], k - j, MPI_INT, i, DATA_TAG, MPI_COMM_WORLD, status);
		}
	}
	else {
		int j = (int)(myrank*n*n / nrank); /* Начиная с индекса */
		int k = (int)(((myrank + 1)*n*n + nrank - 1) / nrank); /* До индекса ( не включтельно ) */
		if (k > j) {
			MPI_Send(&next[j], k - j, MPI_LONG, 0, DATA_TAG, MPI_COMM_WORLD);
			MPI_Send(&intermedian[j], k - j, MPI_INT, 0, DATA_TAG, MPI_COMM_WORLD);
		}
	}
	/* Копируем брэдкастом значения в дочерние процессы */
	MPI_Bcast(next, n*n, MPI_LONG, 0, MPI_COMM_WORLD);
	MPI_Bcast(intermedian, n*n, MPI_INT, 0, MPI_COMM_WORLD);
}

int main(int argc, char *argv[])
{ 
	int n;         /* Ранг исходного массива */
	int nrank;     /* Общее количество процессов */
	int myrank;    /* Номер текущего процесса */ 
	long *prev = NULL;  /* массивов элементов */
	long *next = NULL;  /* массивов элементов */
	int *intermedian = NULL;    /* Массив промежуточных точек */
	int i, j;

	MPI_Status status; 

	/* Иницилизация MPI */ 
	MPI_Init(&argc, &argv); 
	MPI_Comm_size(MPI_COMM_WORLD, &nrank); 
	MPI_Comm_rank(MPI_COMM_WORLD, &myrank); 

	if (myrank == 0 && argc < 4) {
		printf("Usage :\t%s <inputfilename> <outputfilename> <intermedianfilename>\n", argv[0]); fflush(stdout);
		printf("\tinputfilename - source matrix of path prices or empty\n"); fflush(stdout);
		printf("\toutputfilename - output floyd's matrix of path prices\n"); fflush(stdout);
		printf("\tintermedianfilename - output matrix of intermedian points or empty\n"); fflush(stdout);
		exit(-1);
	}

	char *inputFileName = argv[1];
	char *outputFileName = argv[2];
	char *intermedianFileName = argv[3];

	if (myrank == 0) {

		printf("Title :\t%s\n", title); fflush(stdout);
		printf("Number Of Process :\t%d\n", nrank);	fflush(stdout);
		printf("Input File Name :\t%s\n", inputFileName); fflush(stdout);
		printf("Output File Name :\t%s\n", outputFileName); fflush(stdout);
		printf("Intermedian File Name :\t%s\n", intermedianFileName); fflush(stdout);

		char buffer[4096];
		char *tok;
		char *p;


		FILE *fs = fopen(inputFileName, "r");
		if (fs == NULL) {
			fprintf(stderr, "File open error (%s)\n", inputFileName); fflush(stderr);
			exit(-1);
		}

		n = 0;

		/* Заполняем массив числами из файла */ 
		/* Операция выполняетя только на хост процессе */
		/* Операция выполняетя в два прохода по файлу */
		/* На первом проходе определяется ранг матрицы */
		/* На втором проходе считываются данные */
		for (i = 0; (tok = fgets(buffer, sizeof(buffer), fs)) != NULL; i++)
		{
			 j = 0;
			 for (tok = mystrtok(&p, tok, ';'); tok != NULL; tok = mystrtok(&p, NULL, ';'))
			 {
				 j++;
			 }
			 n = max(n, j);
		}
		n = max(n, i);

		prev = (long *)malloc(n*n*sizeof(long));
		next = (long *)malloc(n*n*sizeof(long));

		fseek(fs, 0, SEEK_SET);

		for (i = 0; (tok = fgets(buffer, sizeof(buffer), fs)) != NULL; i++)
		{
			j = 0;
			for (tok = mystrtok(&p, tok, ';'); tok != NULL; tok = mystrtok(&p, NULL, ';'))
			{
				/* Пустые элементы - это запрещённые пути */
				prev[n*i + j++] = strempty(tok) ? LONG_MAX : atol(tok);
			}
			for (; j < n; j++) prev[n*i + j] = LONG_MAX;
		}
		for (i = 0; i < n; i++) prev[n*i + i] = LONG_MAX; /* Запрещаем петли */

		fclose(fs);

		printf("Matrix rank :\t%d\n", n);
		for (i = 0; i < n; i++){
			for (j = 0; j < n; j++){
				printf("%ld%s", prev[i*n+j], ((j == n-1) ? "\n" : "\t"));
			}
		}
	}

	/* Копируем брэдкастом ранг матрицы в дочерние процессы */
	MPI_Bcast(&n, 1, MPI_INT, 0, MPI_COMM_WORLD);

	if (myrank != 0) {
		prev = (long *)malloc(n*n*sizeof(long));
		next = (long *)malloc(n*n*sizeof(long));
	}

	/* Копируем брэдкастом исходную матрицу в дочерние процессы */
	MPI_Bcast(prev, n*n, MPI_LONG, 0, MPI_COMM_WORLD);

	intermedian = (int *)malloc(n*n*sizeof(int));

	_mpi_init(prev, next, intermedian, -1, n, myrank, nrank, &status);

	for(int m = 0; m < n ; m++){
		_mpi_floyd(prev, next, intermedian, m, n, myrank, nrank, &status);
		if (myrank == 0) {
			for (int i = 0; i < n; i++){
				for (int j = 0; j < n; j++){
					printf("%ld%s", next[i*n + j], ((j == n - 1) ? "\n" : ";"));
				}
			}
			printf("\n");
		}
		long * t = prev; prev = next; next = t;
	}

	/* Bыводим результаты */
	if (myrank == 0) {
		FILE *fs = fopen(outputFileName, "w");
		if (fs == NULL) {
			fprintf(stderr, "File open error (%s)\n", outputFileName); fflush(stderr);
			exit(-1);
		}
		for (i = 0; i < n; i++){
			for (j = 0; j < n; j++){
				if (prev[i*n + j] != LONG_MAX)
					fprintf(fs, "%ld%s", prev[i*n + j], ((j == n - 1) ? "\n" : ";"));
				else
					fprintf(fs, "%s", ((j == n - 1) ? "\n" : ";"));
			}
		}
		fclose(fs);
	}

	/* Bыводим результаты */
	if (myrank == 0) {
		FILE *fs = fopen(intermedianFileName, "w");
		if (fs == NULL) {
			fprintf(stderr, "File open error (%s)\n", intermedianFileName); fflush(stderr);
			exit(-1);
		}
		for (i = 0; i < n; i++){
			for (j = 0; j < n; j++){
				if (intermedian[i*n + j] >= 0)
					fprintf(fs, "%d%s", intermedian[i*n + j], ((j == n - 1) ? "\n" : ";"));
				else
					fprintf(fs, "%s", ((j == n - 1) ? "\n" : ";"));
			}
		}
		fclose(fs);
	}

	/* Освобождаем ранее выделенные ресурсы */
	free(prev);
	free(next);
	free(intermedian);

	MPI_Finalize(); 

	exit(0);
} 


