char *title = "Little's algorithm";
char *description = "Алгоритм Литтла - метод решения задачи коммивояжера";
/*
Алгоритм Литтла применяют для поиска решения задачи коммивояжера в виде гамильтонова контура.
Данный алгоритм используется для поиска оптимального гамильтонова контура в графе, имеющем N вершин,
причем каждая вершина i связана с любой другой вершиной j двунаправленной дугой.
Каждой дуге приписан вес Сi,j, причем веса дуг строго положительны (Сi,j≥0).
Веса дуг образуют матрицу стоимости. Все элементы по диагонали матрицы приравнивают
к бесконечности (Сj,j=∞).

В случае, если пара вершин i и j не связана между собой (граф не полносвязный), то соответствующему элементу
матрицы стоимости приписываем вес, равный длине минимального пути между вершинами i и j.
Если в итоге дуга (i, j) войдет в результирующий контур, то ее необходимо заменить соответствующим ей путем.
Матрицу оптимальных путей между всеми вершинами графа можно получить применив алгоритм Данцига или Флойда.

Алгоритм Литтала является частным случаем применения метода "ветвей и границ" для конкретной задачи.
Общая идея тривиальна: нужно разделить огромное число перебираемых вариантов на классы и получить оценки
(снизу – в задаче минимизации, сверху – в задаче максимизации) для этих классов, чтобы иметь возможность
отбрасывать варианты не по одному, а целыми классами.
Трудность состоит в том, чтобы найти такое разделение на классы (ветви) и такие оценки (границы),
чтобы процедура была эффективной.

Алгоритм Литтла

В каждой строке матрицы стоимости найдем минимальный элемент и вычтем его из всех элементов строки.
Сделаем это и для столбцов.
Получим матрицу стоимости, каждая строка и каждый столбец которой содержат хотя бы один нулевой элемент.
Для каждого нулевого элемента матрицы cij  рассчитаем коэффициент Гi,j, который равен сумме наименьшего элемента i строки
(исключая элемент Сi,j=0) и наименьшего элемента j столбца.
Проверяем, что не существует однозначных путей - то есть с одним входом и выходом
Если такой путь есть, то выбираем его
иначе Из всех коэффициентов  Гi,j выберем такой, который является максимальным Гk,m=max{Гi,j}.
В гамильтонов контур вносится соответствующая дуга (k,m).
Удаляем k-тую строку и столбец m. 
Поменяем на бесконечность значение элемент Сr,l для всех путей (l,...,k,m,...r) из добавленных дуг, 
содежащих дугу (k,m) (иначе может образоваться простой цикл).
Повторяем алгоритм шага 1, пока порядок матрицы не станет равным одному.
Получаем гамильтонов контур.
В ходе решения ведется постоянный подсчет текущего значения нижней границы.
Нижняя граница равна сумме всех вычтенных элементов в строках и столбцах.
Итоговое значение нижней границы должно совпасть с длиной результирующего контура.
*/

#include <iostream>
#include <cstdio>
#include <cstdlib>
#include <stdio.h>
#include <string.h>
#include <time.h>
#include <ctype.h>
#include <limits.h>
#include <cuda.h>
#include <cuda_runtime.h>
#include <device_launch_parameters.h>

#define assert( bool ) 
int strempty(const char *p)
{
	if (!p)
		return (1);
	for (; *p; p++)
		if (!isspace(*p))
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
		*m = p + strlen(p);
	return p;
}
#ifndef max
#define max( a, b ) ( ((a) > (b)) ? (a) : (b) )
#endif

#ifndef min
#define min( a, b ) ( ((a) < (b)) ? (a) : (b) )
#endif

__global__ void global_queue_oneway_a(int *queue, int *qsize, long *lbound, long *gamma, int *islice, long *lslice, long *matrix_1, long *matrix, int *rows, int *cols, int *from, int *to, int *im, long *lm, int n, int rank){
	for (int id = blockDim.x*blockIdx.x + threadIdx.x; id < 2*n; id += blockDim.x*gridDim.x) {
		islice[id] = 0;
		if (id < n){
			for (int i = 0; islice[id] < 2 && i < n; i++) {
				if (matrix[i*n + id] != LONG_MAX) {
					islice[id]++;
				}
			}
		}
		else {
			for (int j = 0; im[0] < 2 && j < n; j++) {
				if (matrix[(id - n)*n + j] != LONG_MAX) {
					islice[id]++;
				}
			}
		}
	}
}
__global__ void global_queue_oneway_b(int *queue, int *qsize, long *lbound, long *gamma, int *islice, long *lslice, long *matrix_1, long *matrix, int *rows, int *cols, int *from, int *to, int *im, long *lm, int n, int rank){
	for (int id = blockDim.x*blockIdx.x + threadIdx.x; id < 1; id += blockDim.x*gridDim.x) {
		for (int k = 0; k < 2 * n; k++){
			if (islice[k] == 1){
				if (k < n){
					int i; for (i = 0; i < n; i++){
						if (matrix[i*n + k] != LONG_MAX)
							break;
					}
					queue[--qsize[n]] = i*n + k;
				}
				else {
					int j; for (j = 0; j < n; j++){
						if (matrix[(k - n)*n + j] != LONG_MAX) 
							break;
					}
					queue[--qsize[n]] = (k - n)*n + j;
				}
			}
		}
	}
}
/*
Добавление запрещённых переходов.
	Шаг первый.
		Последнюю добавленную дугу помещаем в середину массива.
		Массив нарашиваем слева и справа.
	Шаг второй.
		Запрещаем все дуги ведущие из правой половины массива в левую половину массива.
*/
__global__ void global_add_forbidden_a(int *queue, int *qsize, long *lbound, long *gamma, int *islice, long *lslice, long *matrix_1, long *matrix, int *rows, int *cols, int *from, int *to, int *im, long *lm, int n, int rank){
	for (int id = blockDim.x*blockIdx.x + threadIdx.x; id < 1; id += blockDim.x*gridDim.x) {
		im[0] = im[1] = rank;
		islice[--im[0]] = islice[im[1]++] = n;
		while(1==1){
			int id1; for(id1 = rank; id1-->n ; ) if (to[id1]==from[islice[im[0]]]) break;
			if (id1>n) islice[--im[0]] = id1; else break;
		}
		while(1==1){
			int id2; for(id2 = rank; id2-->n ; ) if (from[id2]==to[islice[im[1]-1]]) break;
			if (id2>n) islice[im[1]++] = id2; else break;
		}
	}
}
__global__ void global_add_forbidden_b(int *queue, int *qsize, long *lbound, long *gamma, int *islice, long *lslice, long *matrix_1, long *matrix, int *rows, int *cols, int *from, int *to, int *im, long *lm, int n, int rank){
	for (int id = blockDim.x*blockIdx.x + threadIdx.x; id < (rank-im[0])*(im[1]-rank); id += blockDim.x*gridDim.x) {
		int id1 = islice[rank - (id%(rank-im[0])) - 1];
		int id2 = islice[rank + (id/(rank-im[0]))];
		int i; for (i = n; i-- > 0;) if (rows[i] == to[id2]) break; /* Номер строки */
		int j; for (j = n; j-- > 0;) if (cols[j] == from[id1]) break; /* Номер столбца */
		if (i != -1 && j != -1) matrix[i*n + j] = LONG_MAX;
	}
}
/*
Удаление строки im[0] и столбца im[1], соответствующих последней добавленной дуге (im[0],im[1])
*/
__global__ void global_matrix_trunc(int *queue, int *qsize, long *lbound, long *gamma, int *islice, long *lslice, long *matrix_1, long *matrix, int *rows, int *cols, int *from, int *to, int *im, long *lm, int n, int rank){
	/* Удаляем строку и столбец параллельно в процессах */
	for (int id = blockDim.x*blockIdx.x + threadIdx.x; id < (n - 1)*(n - 1); id += blockDim.x*gridDim.x) {
		int i = id / (n - 1); /* Номер строки */
		int j = id % (n - 1); /* Номер столбца */
		if (i < im[0] && j < im[1]) matrix_1[id] = matrix[(i + 0)*n + j + 0];
		else if (i >= im[0] && j < im[1]) matrix_1[id] = matrix[(i + 1)*n + j + 0];
		else if (i < im[0] && j >= im[1]) matrix_1[id] = matrix[(i + 0)*n + j + 1];
		else if (i >= im[0] && j >= im[1]) matrix_1[id] = matrix[(i + 1)*n + j + 1];
	}
}
__global__ void global_queue_indexes_of_max(int *queue, int *qsize, long *lbound, long *gamma, int *islice, long *lslice, long *matrix_1, long *matrix, int *rows, int *cols, int *from, int *to, int *im, long *lm, int n, int rank){
	/* Находим все индексы максимального коэффициента параллельно в процессах */
	for (int id = blockDim.x*blockIdx.x + threadIdx.x; id < 1; id += blockDim.x*gridDim.x) {
		for (int i = 0; i < (im[0] + 1); i++) {
			if (lm[1] == gamma[i]) queue[--qsize[n]] = i;
		}
	}
}
/*
Нахождение максимального индекса максимального элемента массива gamma
Возвращаемые значения:
	im[0] - индекс максимального элемента
	lm[1] - значение максимального элемента
*/
__global__ void global_gamma_max_index_of_max_a(int *queue, int *qsize, long *lbound, long *gamma, int *islice, long *lslice, long *matrix_1, long *matrix, int *rows, int *cols, int *from, int *to, int *im, long *lm, int n, int rank){
	for (int id = blockDim.x*blockIdx.x + threadIdx.x; id < n; id += blockDim.x*gridDim.x) {
		islice[id] = id*n; 
		lslice[n + id] = gamma[islice[id]];
		for (int i = 1; i < n; i++) {
			if (lslice[n + id] <= gamma[id*n + i]) {
				islice[id] = id*n + i;
				lslice[n + id] = gamma[islice[id]];
			}
		}
	}
}
__global__ void global_gamma_max_index_of_max_b(int *queue, int *qsize, long *lbound, long *gamma, int *islice, long *lslice, long *matrix_1, long *matrix, int *rows, int *cols, int *from, int *to, int *im, long *lm, int n, int rank){
	for (int id = blockDim.x*blockIdx.x + threadIdx.x; id < 1; id += blockDim.x*gridDim.x) {
		im[0] = islice[0]; 
		lm[1] = lslice[n];
		for (int i = 1; i < n; i++) {
			if ((lm[1]  < lslice[n + i]) || ((lm[1] == lslice[n + i]) && (im[0] < islice[i]))) {
				im[0] = islice[i];
				lm[1] = lslice[n + i];
			}
		}
	}
}
/*
Для каждого нулевого элемента матрицы cij  рассчитаем коэффициент Гi,j, 
который равен сумме наименьшего элемента i строки (исключая элемент Сi,j=0) 
и наименьшего элемента j столбца.
Возвращаемые значения:
	gamma - массив рассчитанных коэффициентов

Массив gamma представляет собой расчёт минимальной цены въезда и выезда из города
*/
__global__ void global_calc_gamma(int *queue, int *qsize, long *lbound, long *gamma, int *islice, long *lslice, long *matrix_1, long *matrix, int *rows, int *cols, int *from, int *to, int *im, long *lm, int n, int rank){
	/* Расчитываем коэффициенты параллельно в процессах */
	for (int id = blockDim.x*blockIdx.x + threadIdx.x; id < n*n; id += blockDim.x*gridDim.x) {
		if (matrix[id] == 0) {
			int i = id / n; /* Номер строки */
			int j = id % n; /* Номер столбца */
			long x = matrix[i*n + ((j + 1) % n)]; /* Берём следующий элемент в качестве начального */
			long y = matrix[((i + 1) % n)*n + j]; /* Берём следующий элемент в качестве начального */
			for (int k = 2; k < n; k++){
				x = min(x, matrix[i*n + ((j + k) % n)]);
				y = min(y, matrix[((i + k) % n)*n + j]);
			}
			if ((x == LONG_MAX) && (y == LONG_MAX)) gamma[id] = LONG_MAX; /* Из города не въехать и не выехать */
			else if (x == LONG_MAX) gamma[id] = y; /* Из города не въехать */
			else if (y == LONG_MAX) gamma[id] = x; /* Из города не выехать */
			else gamma[id] = x + y;
		}
		else gamma[id] = LONG_MIN;
	}
}
__global__ void global_sub_by_row(int *queue, int *qsize, long *lbound, long *gamma, int *islice, long *lslice, long *matrix_1, long *matrix, int *rows, int *cols, int *from, int *to, int *im, long *lm, int n, int rank){
	/* Находим минимальные значения в строках матрицы параллельно в процессах */
	for (int id = blockDim.x*blockIdx.x + threadIdx.x; id < n*n; id += blockDim.x*gridDim.x) {
		int i = id / n; /* Номер строки */
		if (matrix[id] != LONG_MAX) 
			matrix[id] -= lslice[i];
	}
}
__global__ void global_sub_by_col(int *queue, int *qsize, long *lbound, long *gamma, int *islice, long *lslice, long *matrix_1, long *matrix, int *rows, int *cols, int *from, int *to, int *im, long *lm, int n, int rank){
	/* Находим минимальные значения в строках матрицы параллельно в процессах */
	for (int id = blockDim.x*blockIdx.x + threadIdx.x; id < n*n; id += blockDim.x*gridDim.x) {
		int j = id % n; /* Номер столбца */
		if (matrix[id] != LONG_MAX) 
			matrix[id] -= lslice[j];
	}
}
__global__ void global_min_by_col(int *queue, int *qsize, long *lbound, long *gamma, int *islice, long *lslice, long *matrix_1, long *matrix, int *rows, int *cols, int *from, int *to, int *im, long *lm, int n, int rank){
	/* Находим минимальные значения в колонках матрицы параллельно в процессах */
	for (int id = blockDim.x*blockIdx.x + threadIdx.x; id < n; id += blockDim.x*gridDim.x) {
		lslice[id] = matrix[id];
		for (int i = 1; i < n; i++) {
			lslice[id] = min(lslice[id], matrix[i*n + id]);
		}
	}
}
__global__ void global_min_by_row(int *queue, int *qsize, long *lbound, long *gamma, int *islice, long *lslice, long *matrix_1, long *matrix, int *rows, int *cols, int *from, int *to, int *im, long *lm, int n, int rank){
	/* Находим минимальные значения в строках матрицы параллельно в процессах */
	for (int id = blockDim.x*blockIdx.x + threadIdx.x; id < n; id += blockDim.x*gridDim.x) {
		lslice[id] = matrix[id*n];
		for (int j = 1; j < n; j++) {
			lslice[id] = min(lslice[id], matrix[id*n + j]);
		}
	}
}
__global__ void global_next_by_row(int *queue, int *qsize, long *lbound, long *gamma, int *islice, long *lslice, long *matrix_1, long *matrix, int *rows, int *cols, int *from, int *to, int *im, long *lm, int n, int rank){
	for (int id = blockDim.x*blockIdx.x + threadIdx.x; id < n; id += blockDim.x*gridDim.x) {
		for (int i = 0; i < n; i++) {
			if (matrix[i*n + id] != LONG_MAX) {
				lslice[id] = max(lslice[id], lslice[i+n]);
				islice[id] = max(islice[id], islice[i+n]);
			}
		}
	}
}
__global__ void global_prev_by_col(int *queue, int *qsize, long *lbound, long *gamma, int *islice, long *lslice, long *matrix_1, long *matrix, int *rows, int *cols, int *from, int *to, int *im, long *lm, int n, int rank){
	for (int id = blockDim.x*blockIdx.x + threadIdx.x; id < n; id += blockDim.x*gridDim.x) {
		for (int j = 0; j < n; j++) {
			if (matrix[id*n + j] != LONG_MAX){
				lslice[id] = max(lslice[id], lslice[j+n]);
				islice[id] = max(islice[id], islice[j+n]);
			}
		}
	}
}

__global__ void global_min_by_dim(int *queue, int *qsize, long *lbound, long *gamma, int *islice, long *lslice, long *matrix_1, long *matrix, int *rows, int *cols, int *from, int *to, int *im, long *lm, int n, int rank){
	for (int id = blockDim.x*blockIdx.x + threadIdx.x; id < 1; id += blockDim.x*gridDim.x) {
		lm[0] = lslice[0];
		im[0] = islice[0];
		for (int i = 1; i < n; i++){
			lm[0] = min(lm[0], lslice[i]);
			im[0] = min(im[0], islice[i]);
		}
	}
}
__global__ void global_sum_lbound(int *queue, int *qsize, long *lbound, long *gamma, int *islice, long *lslice, long *matrix_1, long *matrix, int *rows, int *cols, int *from, int *to, int *im, long *lm, int n, int rank){
	for (int id = blockDim.x*blockIdx.x + threadIdx.x; id < 1; id += blockDim.x*gridDim.x) {
		lm[0] = 0;
		for (int i = 1; i < n; i++) {
			lbound[i] = matrix[(n - 1)*i];
		}
		for (int i = 1; i <= rank; i++){
			lm[0] += lbound[i];
		}
	}
}
__global__ void global_add_lbound(int *queue, int *qsize, long *lbound, long *gamma, int *islice, long *lslice, long *matrix_1, long *matrix, int *rows, int *cols, int *from, int *to, int *im, long *lm, int n, int rank){
	for (int id = blockDim.x*blockIdx.x + threadIdx.x; id < 1; id += blockDim.x*gridDim.x) {
		lbound[n] += matrix[queue[qsize[n]]];
	}
}
__global__ void global_sum_lbound_begin(int *queue, int *qsize, long *lbound, long *gamma, int *islice, long *lslice, long *matrix_1, long *matrix, int *rows, int *cols, int *from, int *to, int *im, long *lm, int n, int rank){
	for (int id = blockDim.x*blockIdx.x + threadIdx.x; id < 1; id += blockDim.x*gridDim.x) {
		lbound[n] = 0;
	}
}
__global__ void global_sum_lbound_step(int *queue, int *qsize, long *lbound, long *gamma, int *islice, long *lslice, long *matrix_1, long *matrix, int *rows, int *cols, int *from, int *to, int *im, long *lm, int n, int rank){
	for (int id = blockDim.x*blockIdx.x + threadIdx.x; id < 1; id += blockDim.x*gridDim.x) {
		for (int i = 0; i < n; i++) lbound[n] += lslice[i];
	}
}
__global__ void global_slice_clear(int *queue, int *qsize, long *lbound, long *gamma, int *islice, long *lslice, long *matrix_1, long *matrix, int *rows, int *cols, int *from, int *to, int *im, long *lm, int n, int rank){
	for (int id = blockDim.x*blockIdx.x + threadIdx.x; id < n; id += blockDim.x*gridDim.x) {
		islice[id] = 0;
		lslice[id] = 0;
	}
}
__global__ void global_sum_lbound_end(int *queue, int *qsize, long *lbound, long *gamma, int *islice, long *lslice, long *matrix_1, long *matrix, int *rows, int *cols, int *from, int *to, int *im, long *lm, int n, int rank){
}
__global__ void global_check_infinity(int *queue, int *qsize, long *lbound, long *gamma, int *islice, long *lslice, long *matrix_1, long *matrix, int *rows, int *cols, int *from, int *to, int *im, long *lm, int n, int rank){
	for (int id = blockDim.x*blockIdx.x + threadIdx.x; id < 1; id += blockDim.x*gridDim.x) {
		im[0] = 0; for (int i = 0; im[0] == 0 && i < n; i++) if (lslice[i] == LONG_MAX) im[0] = 1;
	}
}
__global__ void global_initialize(int *queue, int *qsize, long *lbound, long *gamma, int *islice, long *lslice, long *matrix_1, long *matrix, int *rows, int *cols, int *from, int *to, int *im, long *lm, int n, int rank){
	for (int id = blockDim.x*blockIdx.x + threadIdx.x; id < 1; id += blockDim.x*gridDim.x) {
		lbound[0] = 0;
		for (int i = 0; i < n; i++) rows[i] = i;
		for (int i = 0; i < n; i++) cols[i] = i;
		qsize[n + 1] = n*n*n;
		qsize[n] = qsize[n + 1];
	}
}
/*
	В случае неправильных параметров возвращённая лучшая цена имеет LONG_MAX значение
*/
__host__ void host_little(int gridSize, int blockSize, long *data, int *bestFrom, int *bestTo, long *bestPrice, int rank)
{
	cudaError_t err;
	int n;         /* Ранг текущего массива */
	long **matrix;  /* Стек массивов элементов */
	int **rows;  /* Стек массивов элементов */
	int **cols;  /* Стек массивов элементов */
	long *gamma;    /* Массив коэффициентов */
	int *queue;    /* Стек очередей индексов элементов */
	int *qsize;    /* Размер очередей индексов элементов */
	long *lbound;   /* Стек вычисленных нижних границ */
	/* Стеки дуг (индексов) хранятся в порядке их удаления из матрицы */
	/* Индексы записаны в соответствии с текущим размером матрицы */
	/* и требуют пересчёта в исходный размер матрицы */
	int *from; /* Стек дуг (индексов) в порядке их удаления из матрицы */
	int *to;   /* Стек дуг (индексов) в порядке их удаления из матрицы */
	int *im;
	long *lm;
	int *islice;
	long *lslice;
	int ivalue[2];
	long lvalue[2];
	int *ibuffer;
	long *lbuffer;

	n = rank;

	ibuffer = (int*)malloc(n*n*sizeof(int));
	lbuffer = (long*)malloc(n*n*sizeof(long));
	matrix = (long**)malloc((n + 1)*sizeof(long*));
	rows = (int**)malloc((n + 1)*sizeof(int*));
	cols = (int**)malloc((n + 1)*sizeof(int*));
	for (int i = 1; i <= n; i++) err = cudaMalloc((void**)&matrix[i], i*i*sizeof(long));
	for (int i = 1; i <= n; i++) err = cudaMalloc((void**)&rows[i], i*sizeof(int));
	for (int i = 1; i <= n; i++) err = cudaMalloc((void**)&cols[i], i*sizeof(int));

	err = cudaMalloc((void**)&im, 2 * sizeof(int));
	err = cudaMalloc((void**)&lm, 2 * sizeof(long));
	err = cudaMalloc((void**)&islice, 2*n*sizeof(int));
	err = cudaMalloc((void**)&lslice, 2*n*sizeof(long));
	err = cudaMalloc((void**)&lbound ,(n + 1)*sizeof(long));
	err = cudaMalloc((void**)&from, n*sizeof(int));
	err = cudaMalloc((void**)&to, n*sizeof(int));
	err = cudaMalloc((void**)&queue, n*n*n * sizeof(int));
	err = cudaMalloc((void**)&qsize ,(n + 2)*sizeof(int));
	err = cudaMalloc((void**)&gamma,n*n*sizeof(long));

	cudaMemcpy(matrix[n], data, n*n*sizeof(long), cudaMemcpyHostToDevice);

	global_initialize <<< 1, 1 >>>(queue, qsize, lbound, gamma, islice, lslice, matrix[n-1], matrix[n], rows[n], cols[n], from, to, im, lm, n, rank);
	*bestPrice = LONG_MAX;

	int blocks = (gridSize > 0)? gridSize : min(max(1, (int)pow((double)rank, 0.333333333333333)), 15);
	int threads = (blockSize > 0)? blockSize : min(max(1, (int)pow((double)rank, 0.333333333333333)), 15);

	ivalue[1] = 1;
	printf(" Check Graph by rows \n");
	/* Проверяем граф на связанность по строкам */
	global_slice_clear <<< blocks, threads >>>(queue, qsize, lbound, gamma, islice, lslice, matrix[n-1], matrix[n], rows[n], cols[n], from, to, im, lm, n, rank);
	cudaMemcpy(islice, &ivalue[1], sizeof(int), cudaMemcpyHostToDevice);
	for (int i = 1; i <= n; i++)
	{
		cudaMemcpy(&islice[n], islice, n*sizeof(int), cudaMemcpyDeviceToDevice);
		global_slice_clear <<< blocks, threads >>>(queue, qsize, lbound, gamma, islice, lslice, matrix[n - 1], matrix[n], rows[n], cols[n], from, to, im, lm, n, rank);
		global_next_by_row <<< blocks, threads >>>(queue, qsize, lbound, gamma, islice, lslice, matrix[n - 1], matrix[n], rows[n], cols[n], from, to, im, lm, n, rank);
	}
	cudaMemcpy(ivalue, islice, sizeof(int), cudaMemcpyDeviceToHost);
	if (ivalue[0] == 0) {
		fprintf(stderr, "Wrong Graph\n"); fflush(stderr);
		goto the_end;
	}

	printf(" Check Graph by columns \n");
	/* Проверяем граф на связанность по столбцам */
	global_slice_clear <<< blocks, threads >>>(queue, qsize, lbound, gamma, islice, lslice, matrix[n-1], matrix[n], rows[n], cols[n], from, to, im, lm, n, rank);
	cudaMemcpy(islice, &ivalue[1], sizeof(int), cudaMemcpyHostToDevice);
	for (int i = 1; i <= n; i++) {
		cudaMemcpy(&islice[n], islice, n*sizeof(int), cudaMemcpyDeviceToDevice);
		global_slice_clear <<< blocks, threads >>>(queue, qsize, lbound, gamma, islice, lslice, matrix[n - 1], matrix[n], rows[n], cols[n], from, to, im, lm, n, rank);
		global_prev_by_col <<< blocks, threads >>>(queue, qsize, lbound, gamma, islice, lslice, matrix[n - 1], matrix[n], rows[n], cols[n], from, to, im, lm, n, rank);
	}
	cudaMemcpy(ivalue, islice, sizeof(int), cudaMemcpyDeviceToHost);
	if (ivalue[0] == 0) {
		fprintf(stderr, "Wrong Graph\n"); fflush(stderr);
		goto the_end;
	}
	printf(" Check Graph by rows \n");
	/* Проверяем граф на связанность по строкам */
	global_slice_clear <<< blocks, threads >>>(queue, qsize, lbound, gamma, islice, lslice, matrix[n - 1], matrix[n], rows[n], cols[n], from, to, im, lm, n, rank);
	cudaMemcpy(islice, &ivalue[1], sizeof(int), cudaMemcpyHostToDevice);
	for (int i = 1; i <= n; i++)
	{
		cudaMemcpy(&islice[n], islice, n*sizeof(int), cudaMemcpyDeviceToDevice);
		global_next_by_row <<< blocks, threads >>>(queue, qsize, lbound, gamma, islice, lslice, matrix[n - 1], matrix[n], rows[n], cols[n], from, to, im, lm, n, rank);
	}
	global_min_by_dim <<< 1, 1 >>>(queue, qsize, lbound, gamma, islice, lslice, matrix[n - 1], matrix[n], rows[n], cols[n], from, to, im, lm, n, rank);
	cudaMemcpy(ivalue, im, sizeof(int), cudaMemcpyDeviceToHost);
	if (ivalue[0] == 0) {
		fprintf(stderr, "Wrong Graph\n"); fflush(stderr);
		goto the_end;
	}

	printf(" Check Graph by columns \n");
	/* Проверяем граф на связанность по столбцам */
	global_slice_clear <<< blocks, threads >>>(queue, qsize, lbound, gamma, islice, lslice, matrix[n - 1], matrix[n], rows[n], cols[n], from, to, im, lm, n, rank);
	cudaMemcpy(islice, &ivalue[1], sizeof(int), cudaMemcpyHostToDevice);
	for (int i = 1; i <= n; i++) {
		cudaMemcpy(&islice[n], islice, n*sizeof(int), cudaMemcpyDeviceToDevice);
		global_prev_by_col <<< blocks, threads >>>(queue, qsize, lbound, gamma, islice, lslice, matrix[n - 1], matrix[n], rows[n], cols[n], from, to, im, lm, n, rank);
	}
	global_min_by_dim <<< 1, 1 >>>(queue, qsize, lbound, gamma, islice, lslice, matrix[n - 1], matrix[n], rows[n], cols[n], from, to, im, lm, n, rank);
	cudaMemcpy(ivalue, im, sizeof(int), cudaMemcpyDeviceToHost);
	if (ivalue[0] == 0) {
		fprintf(stderr, "Wrong Graph\n"); fflush(stderr);
		goto the_end;
	}

	printf("Graph is ok\n");

	while (n > 0 && n <= rank) {

		
		printf("Matrix rank :\t%d\n", n);
		cudaMemcpy(lbuffer, matrix[n], n*n*sizeof(long), cudaMemcpyDeviceToHost);
		for (int i = 0; i < n; i++){
			for (int j = 0; j < n; j++){
				printf("%ld%s", lbuffer[i*n + j], ((j == n - 1) ? "\n" : "\t"));
			}
		}

		int blocks0 = (gridSize > 0)? gridSize : min(max(1, (int)pow((double)(rank-n), 0.6666666666666)), 15);
		int threads0 = (blockSize > 0)? blockSize : min(max(1, (int)pow((double)(rank-n), 0.6666666666666)), 15);

		int blocks1 = (gridSize > 0)? gridSize : min(max(1, (int)pow((double)n, 0.333333333333333)), 15);
		int threads1 = (blockSize > 0)? blockSize : min(max(1, (int)pow((double)n, 0.333333333333333)), 15);

		int blocks2 = (gridSize > 0)? gridSize : min(max(1, (int)pow((double)n, 0.66666666666666)), 15);
		int threads2 = (blockSize > 0)? blockSize : min(max(1, (int)pow((double)n, 0.66666666666666)), 15);

		global_sum_lbound_begin <<< 1, 1 >>>(queue, qsize, lbound, gamma, islice, lslice, matrix[n - 1], matrix[n], rows[n], cols[n], from, to, im, lm, n, rank);

		if (n > 1)  {
			printf(" global_add_forbidden \n");
			/* Запрещаем обратные переходы */
			global_add_forbidden_a <<< 1, 1 >>>(queue, qsize, lbound, gamma, islice, lslice, matrix[n-1], matrix[n], rows[n], cols[n], from, to, im, lm, n, rank);
			global_add_forbidden_b <<< blocks0, threads0 >>>(queue, qsize, lbound, gamma, islice, lslice, matrix[n-1], matrix[n], rows[n], cols[n], from, to, im, lm, n, rank);

			cudaMemcpy(lbuffer, matrix[n], n*n*sizeof(long), cudaMemcpyDeviceToHost);
			for (int i = 0; i < n; i++){
				for (int j = 0; j < n; j++){
					printf("%ld%s", lbuffer[i*n + j], ((j == n - 1) ? "\n" : "\t"));
				}
			}

			cudaMemcpy(&qsize[n], &qsize[n + 1], sizeof(int), cudaMemcpyDeviceToDevice);

			printf(" global_min_by_row \n");
			/* Находим минимальные значения в строках матрицы параллельно в процессах */
			global_min_by_row <<< blocks1, threads1 >>>(queue, qsize, lbound, gamma, islice, lslice, matrix[n-1], matrix[n], rows[n], cols[n], from, to, im, lm, n, rank);
			global_check_infinity <<< 1, 1 >>>(queue, qsize, lbound, gamma, islice, lslice, matrix[n-1], matrix[n], rows[n], cols[n], from, to, im, lm, n, rank);
			cudaMemcpy(ivalue, im, sizeof(int), cudaMemcpyDeviceToHost);
			if (ivalue[0] == 0) {

				printf(" global_sub_by_row \n");
				/* Вычитаем минимальные значения из строк параллельно в процессах */
				global_sub_by_row <<< blocks2, threads2 >>>(queue, qsize, lbound, gamma, islice, lslice, matrix[n-1], matrix[n], rows[n], cols[n], from, to, im, lm, n, rank);

				cudaMemcpy(lbuffer, matrix[n], n*n*sizeof(long), cudaMemcpyDeviceToHost);
				for (int i = 0; i < n; i++){
					for (int j = 0; j < n; j++){
						printf("%ld%s", lbuffer[i*n + j], ((j == n - 1) ? "\n" : "\t"));
					}
				}

				printf(" global_sum_lbound_step \n");
				global_sum_lbound_step <<< 1, 1 >>>(queue, qsize, lbound, gamma, islice, lslice, matrix[n-1], matrix[n], rows[n], cols[n], from, to, im, lm, n, rank);
			}

			printf(" global_min_by_col \n");
			/* Находим минимальные значения в столбцах матрицы параллельно в процессах */
			global_min_by_col <<< blocks1, threads1 >>>(queue, qsize, lbound, gamma, islice, lslice, matrix[n-1], matrix[n], rows[n], cols[n], from, to, im, lm, n, rank);
			global_check_infinity <<< 1, 1 >>>(queue, qsize, lbound, gamma, islice, lslice, matrix[n-1], matrix[n], rows[n], cols[n], from, to, im, lm, n, rank);
			cudaMemcpy(ivalue, im, sizeof(int), cudaMemcpyDeviceToHost);
			if (ivalue[0] == 0) {

				printf(" global_sub_by_col \n");
				/* Вычитаем минимальные значения из столбцов параллельно в процессах */
				global_sub_by_col <<< blocks2, threads2 >>>(queue, qsize, lbound, gamma, islice, lslice, matrix[n-1], matrix[n], rows[n], cols[n], from, to, im, lm, n, rank);

				cudaMemcpy(lbuffer, matrix[n], n*n*sizeof(long), cudaMemcpyDeviceToHost);
				for (int i = 0; i < n; i++){
					for (int j = 0; j < n; j++){
						printf("%ld%s", lbuffer[i*n + j], ((j == n - 1) ? "\n" : "\t"));
					}
				}

				printf(" global_sum_lbound_step \n");
				global_sum_lbound_step <<< 1, 1 >>>(queue, qsize, lbound, gamma, islice, lslice, matrix[n-1], matrix[n], rows[n], cols[n], from, to, im, lm, n, rank);
			}

			printf(" global_sum_lbound_end \n");
			global_sum_lbound_end <<< 1, 1 >>>(queue, qsize, lbound, gamma, islice, lslice, matrix[n-1], matrix[n], rows[n], cols[n], from, to, im, lm, n, rank);

			cudaMemcpy(lbuffer, &lbound[n], sizeof(long), cudaMemcpyDeviceToHost);
			printf("%ld\n", lbuffer[0]);

			printf(" global_queue_oneway \n");
			/* Находим все индексы максимального коэффициента параллельно в процессах */
			global_queue_oneway_a <<< blocks1, threads1 >>>(queue, qsize, lbound, gamma, islice, lslice, matrix[n-1], matrix[n], rows[n], cols[n], from, to, im, lm, n, rank);
			global_queue_oneway_b <<< 1, 1 >>>(queue, qsize, lbound, gamma, islice, lslice, matrix[n-1], matrix[n], rows[n], cols[n], from, to, im, lm, n, rank);

			cudaMemcpy(ivalue, &qsize[n], 2 * sizeof(int), cudaMemcpyDeviceToHost);
			if (ivalue[1] > ivalue[0]) cudaMemcpy(ibuffer, &queue[ivalue[0]], (ivalue[1] - ivalue[0])*sizeof(int), cudaMemcpyDeviceToHost);
			for (int i = 0; i < (ivalue[1] - ivalue[0]); i++) printf("%d%s", ibuffer[i], (i == (ivalue[1] - ivalue[0]) - 1) ? "\n" : "\t");

			cudaMemcpy(ivalue, &qsize[n], 2 * sizeof(int), cudaMemcpyDeviceToHost);
			if (ivalue[0] == ivalue[1]) {
				printf(" global_calc_gamma \n");
				/* Расчитываем коэффициенты параллельно в процессах */
				global_calc_gamma <<< blocks2, threads2 >>>(queue, qsize, lbound, gamma, islice, lslice, matrix[n-1], matrix[n], rows[n], cols[n], from, to, im, lm, n, rank);

				cudaMemcpy(lbuffer, gamma, n*n*sizeof(long), cudaMemcpyDeviceToHost);
				for (int i = 0; i < n; i++){
					for (int j = 0; j < n; j++){
						printf("%ld%s", lbuffer[i*n + j], ((j == n - 1) ? "\n" : "\t"));
					}
				}

				/* Находим максимальный индекс максимального коэффициента параллельно в процессах */
				global_gamma_max_index_of_max_a <<< blocks1, threads1 >>>(queue, qsize, lbound, gamma, islice, lslice, matrix[n - 1], matrix[n], rows[n], cols[n], from, to, im, lm, n, rank);
				global_gamma_max_index_of_max_b <<< 1, 1 >>>(queue, qsize, lbound, gamma, islice, lslice, matrix[n - 1], matrix[n], rows[n], cols[n], from, to, im, lm, n, rank);

				cudaMemcpy(lvalue, lm, 2 * sizeof(long), cudaMemcpyDeviceToHost);
				if (lvalue[1] != LONG_MIN)
				{
					printf(" global_queue_indexes_of_max \n");
					/* Находим все индексы максимального коэффициента параллельно в процессах */
					global_queue_indexes_of_max <<< 1, 1 >>>(queue, qsize, lbound, gamma, islice, lslice, matrix[n-1], matrix[n], rows[n], cols[n], from, to, im, lm, n, rank);

					cudaMemcpy(ivalue, &qsize[n], 2 * sizeof(int), cudaMemcpyDeviceToHost);
					if (ivalue[1] > ivalue[0]) cudaMemcpy(ibuffer, &queue[ivalue[0]], (ivalue[1] - ivalue[0])*sizeof(int), cudaMemcpyDeviceToHost);
					for (int i = 0; i < (ivalue[1] - ivalue[0]); i++) printf("%d%s", ibuffer[i], (i == (ivalue[1] - ivalue[0]) - 1) ? "\n" : "\t");

				}
			}
			else {
				ivalue[0] = ivalue[1] - 1;
				cudaMemcpy(&qsize[n], ivalue, sizeof(int), cudaMemcpyHostToDevice);
				printf(" global_add_lbound \n");
				global_add_lbound <<< 1, 1 >>>(queue, qsize, lbound, gamma, islice, lslice, matrix[n - 1], matrix[n], rows[n], cols[n], from, to, im, lm, n, rank);
			}

			/* Теперь все индексы должны быть рекурсивно обработаны */
			/* Чтобы не делать рекурсивные обходы работаем только с объявленным стеком */
		}
		else {

			cudaMemcpy(lvalue, matrix[n], sizeof(long), cudaMemcpyDeviceToHost);
			if (lvalue[0] != LONG_MAX){
				cudaMemcpy(from, rows[n], n*sizeof(int), cudaMemcpyDeviceToDevice);
				cudaMemcpy(to, cols[n], n*sizeof(int), cudaMemcpyDeviceToDevice);

				printf(" global_sum_lbound \n");
				/* Суммируем Текущую Нижнюю Границу параллельно в процессах */
				global_sum_lbound <<< 1, 1 >>>(queue, qsize, lbound, gamma, islice, lslice, matrix[n - 1], matrix[n], rows[n], cols[n], from, to, im, lm, n, rank);


				/* Сравниваем текущую стоимость с ранее найденой лучшей стоимостью */
				cudaMemcpy(lvalue, lm, sizeof(long), cudaMemcpyDeviceToHost);
				if (lvalue[0] < bestPrice[0]){
					bestPrice[0] = lvalue[0];
					cudaMemcpy(bestFrom, from, rank * sizeof(int), cudaMemcpyDeviceToHost);
					cudaMemcpy(bestTo, to, rank * sizeof(int), cudaMemcpyDeviceToHost);
				}
				printf("Current Price\t: %ld\n", bestPrice[0]);
			}
			n++;
		}

		/* Возврат из "рекурсивного" вызова */
		/* Чтобы не делать рекурсивные обходы работаем только с объявленным стеком */
		while ((n <= rank)) {
			cudaMemcpy(ivalue, &qsize[n], 2 * sizeof(int), cudaMemcpyDeviceToHost);
			if (ivalue[0] == ivalue[1]) {

				printf(" Return from Recursion \n");
				n++;
				continue;
			}
			break;
		}
		if (n > rank) break;

		/* Перебираем значения из очереди */
		cudaMemcpy(ivalue, &qsize[n], sizeof(int), cudaMemcpyDeviceToHost);
		cudaMemcpy(&ivalue[1], &queue[ivalue[0]], sizeof(int), cudaMemcpyDeviceToHost);
		ivalue[0]++;
		cudaMemcpy(&qsize[n], ivalue, sizeof(int), cudaMemcpyHostToDevice);

		int id = ivalue[1];
		ivalue[0] = id / n; /* Номер строки */
		ivalue[1] = id % n; /* Номер столбца */

		cudaMemcpy(im, ivalue, 2 * sizeof(int), cudaMemcpyHostToDevice);

		cudaMemcpy(&from[n - 1], &rows[n][ivalue[0]], sizeof(int), cudaMemcpyDeviceToDevice);
		cudaMemcpy(&to[n - 1], &cols[n][ivalue[1]], sizeof(int), cudaMemcpyDeviceToDevice);

		printf(" global_matrix_trunc \n");
		/* Удаляем строку и столбец */
		if (ivalue[0] > 0) cudaMemcpy(rows[n - 1], rows[n], ivalue[0] * sizeof(int), cudaMemcpyDeviceToDevice);
		if (ivalue[0] < (n - 1)) cudaMemcpy(&rows[n - 1][ivalue[0]], &rows[n][ivalue[0] + 1], (n - ivalue[0] - 1) * sizeof(int), cudaMemcpyDeviceToDevice);
		if (ivalue[1] > 0) cudaMemcpy(cols[n - 1], cols[n], ivalue[1] * sizeof(int), cudaMemcpyDeviceToDevice);
		if (ivalue[1] < (n - 1)) cudaMemcpy(&cols[n - 1][ivalue[1]], &cols[n][ivalue[1] + 1], (n - ivalue[1] - 1) * sizeof(int), cudaMemcpyDeviceToDevice);

		global_matrix_trunc <<< blocks2, threads2 >>>(queue, qsize, lbound, gamma, islice, lslice, matrix[n-1], matrix[n], rows[n], cols[n], from, to, im, lm, n, rank);

		n--;
	}
	n--;

the_end:
	/* Освобождаем ранее выделенные ресурсы */

	free(ibuffer);
	free(lbuffer);
	for (int i = 1; i <= n; i++) err = cudaFree(matrix[i]);
	for (int i = 1; i <= n; i++) err = cudaFree(rows[i]);
	for (int i = 1; i <= n; i++) err = cudaFree(cols[i]);
	free(matrix);
	free(rows);
	free(cols);
	err = cudaFree(gamma);
	err = cudaFree(lbound);
	err = cudaFree(queue);
	err = cudaFree(qsize);
	err = cudaFree(from);
	err = cudaFree(to);
	err = cudaFree(islice);
	err = cudaFree(lslice);
	err = cudaFree(im);
	err = cudaFree(lm);

	err = err;
}

int main(int argc, char* argv[])
{
	int gridSize = 0;
	int blockSize = 0;

	printf("Title :\t%s\n", title); fflush(stdout);

	if (argc < 3) {
		printf("Usage :\t%s [-g <gridSize>] [-b <blockSize>] <inputfilename> <outputfilename>\n", argv[0]); fflush(stdout);
		printf("\tinputfilename - source matrix of path prices or empty\n"); fflush(stdout);
		printf("\toutputfilename - output best path point-to-point segments\n"); fflush(stdout);
		exit(-1);
	}

	int argId = 1;
	for(; argId < argc && argv[argId][0]=='-' ; argId++){
		switch(argv[argId][1]){
		case 'g':
			gridSize = atoi(argv[++argId]);
			break;
		case 'b':
			blockSize = atoi(argv[++argId]);
			break;
		}
	}

	char *inputFileName = argv[argId++];
	char *outputFileName = argv[argId++];

	char buffer[4096];
	char *tok;
	char *p;
	int n;         /* Ранг текущего массива */
	long *matrix;  /* Стек массивов элементов */
	int i, j;
	long bestPrice;
	int *bestFrom; /* Стек дуг (индексов) в порядке их удаления из матрицы */
	int *bestTo;   /* Стек дуг (индексов) в порядке их удаления из матрицы */

	printf("Input File Name :\t%s\n", inputFileName); fflush(stdout);
	printf("Output File Name :\t%s\n", outputFileName); fflush(stdout);

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

	matrix = (long *)malloc(n*n*sizeof(long));
	bestFrom = (int *)malloc((n + 1)*sizeof(int));
	bestTo = (int *)malloc((n + 1)*sizeof(int));

	fseek(fs, 0, SEEK_SET);

	for (i = 0; (tok = fgets(buffer, sizeof(buffer), fs)) != NULL; i++)
	{
		j = 0;
		for (tok = mystrtok(&p, tok, ';'); tok != NULL; tok = mystrtok(&p, NULL, ';'))
		{
			/* Пустые элементы - это запрещённые пути */
			matrix[n*i + j++] = strempty(tok) ? LONG_MAX : atol(tok);
		}
		for (; j < n; j++) matrix[n*i + j] = LONG_MAX;
	}
	for (j = 0; j < (n - i)*n; j++) matrix[n*i + j] = LONG_MAX;
	for (i = 0; i < n; i++) matrix[n*i + i] = LONG_MAX; /* Запрещаем петли */

	fclose(fs);

	printf("Matrix rank :\t%d\n", n);
	for (i = 0; i < n; i++){
		for (j = 0; j < n; j++){
			printf("%ld%s", matrix[i*n + j], ((j == n - 1) ? "\n" : "\t"));
		}
	}
	fflush(stdout);

	// Find/set the device.
	int device_size = 0;
	cudaGetDeviceCount(&device_size);
	for (i = 0; i < device_size; ++i)
	{
		cudaDeviceProp cudaDeviceProp;
		cudaGetDeviceProperties(&cudaDeviceProp, i);
		printf("Running on GPU %d (%s)\n", i, cudaDeviceProp.name); 

		printf("Device has ECC support enabled %d\n",cudaDeviceProp.ECCEnabled);
		printf("Number of asynchronous engines %d\n",cudaDeviceProp.asyncEngineCount);
		printf("Device can map host memory with cudaHostAlloc/cudaHostGetDevicePointer %d\n",cudaDeviceProp.canMapHostMemory);
		printf("Clock frequency in kilohertz %d\n",cudaDeviceProp.clockRate);
		printf("Compute mode (See cudaComputeMode) %d\n",cudaDeviceProp.computeMode);
		printf("Device can possibly execute multiple kernels concurrently %d\n",cudaDeviceProp.concurrentKernels);
		printf("Device can concurrently copy memory and execute a kernel. Deprecated. Use instead asyncEngineCount. %d\n",cudaDeviceProp.deviceOverlap);
		printf("Device is integrated as opposed to discrete %d\n",cudaDeviceProp.integrated);
		printf("Specified whether there is a run time limit on kernels %d\n",cudaDeviceProp.kernelExecTimeoutEnabled);
		printf("Size of L2 cache in bytes %d\n",cudaDeviceProp.l2CacheSize);
		printf("Major compute capability %d\n",cudaDeviceProp.major);
		printf("Maximum size of each dimension of a grid %d\n",cudaDeviceProp.maxGridSize[0]);
		printf("Maximum size of each dimension of a grid %d\n",cudaDeviceProp.maxGridSize[1]);
		printf("Maximum size of each dimension of a grid %d\n",cudaDeviceProp.maxGridSize[2]);
		printf("Maximum 1D surface size %d\n",cudaDeviceProp.maxSurface1D);
		printf("Maximum 1D layered surface dimensions %d\n",cudaDeviceProp.maxSurface1DLayered[0]);
		printf("Maximum 1D layered surface dimensions %d\n",cudaDeviceProp.maxSurface1DLayered[1]);
		printf("Maximum 2D surface dimensions %d\n",cudaDeviceProp.maxSurface2D[0]);
		printf("Maximum 2D surface dimensions %d\n",cudaDeviceProp.maxSurface2D[1]);
		printf("Maximum 2D layered surface dimensions %d\n",cudaDeviceProp.maxSurface2DLayered[0]);
		printf("Maximum 2D layered surface dimensions %d\n",cudaDeviceProp.maxSurface2DLayered[1]);
		printf("Maximum 2D layered surface dimensions %d\n",cudaDeviceProp.maxSurface2DLayered[2]);
		printf("Maximum 3D surface dimensions %d\n",cudaDeviceProp.maxSurface3D[0]);
		printf("Maximum 3D surface dimensions %d\n",cudaDeviceProp.maxSurface3D[1]);
		printf("Maximum 3D surface dimensions %d\n",cudaDeviceProp.maxSurface3D[2]);
		printf("Maximum Cubemap surface dimensions %d\n",cudaDeviceProp.maxSurfaceCubemap);
		printf("Maximum Cubemap layered surface dimensions %d\n",cudaDeviceProp.maxSurfaceCubemapLayered[0]);
		printf("Maximum Cubemap layered surface dimensions %d\n",cudaDeviceProp.maxSurfaceCubemapLayered[1]);
		printf("Maximum 1D texture size %d\n",cudaDeviceProp.maxTexture1D);
		printf("Maximum 1D layered texture dimensions %d\n",cudaDeviceProp.maxTexture1DLayered[0]);
		printf("Maximum 1D layered texture dimensions %d\n",cudaDeviceProp.maxTexture1DLayered[1]);
		printf("Maximum size for 1D textures bound to linear memory %d\n",cudaDeviceProp.maxTexture1DLinear);
		printf("Maximum 1D mipmapped texture size %d\n",cudaDeviceProp.maxTexture1DMipmap);
		printf("Maximum 2D texture dimensions %d\n",cudaDeviceProp.maxTexture2D[0]);
		printf("Maximum 2D texture dimensions %d\n",cudaDeviceProp.maxTexture2D[1]);
		printf("Maximum 2D texture dimensions if texture gather operations have to be performed %d\n",cudaDeviceProp.maxTexture2DGather[0]);
		printf("Maximum 2D texture dimensions if texture gather operations have to be performed %d\n",cudaDeviceProp.maxTexture2DGather[1]);
		printf("Maximum 2D layered texture dimensions %d\n",cudaDeviceProp.maxTexture2DLayered[0]);
		printf("Maximum 2D layered texture dimensions %d\n",cudaDeviceProp.maxTexture2DLayered[1]);
		printf("Maximum 2D layered texture dimensions %d\n",cudaDeviceProp.maxTexture2DLayered[2]);
		printf("Maximum dimensions (width, height, pitch) for 2D textures bound to pitched memory %d\n",cudaDeviceProp.maxTexture2DLinear[0]);
		printf("Maximum dimensions (width, height, pitch) for 2D textures bound to pitched memory %d\n",cudaDeviceProp.maxTexture2DLinear[1]);
		printf("Maximum dimensions (width, height, pitch) for 2D textures bound to pitched memory %d\n",cudaDeviceProp.maxTexture2DLinear[2]);
		printf("Maximum 2D mipmapped texture dimensions %d\n",cudaDeviceProp.maxTexture2DMipmap[0]);
		printf("Maximum 2D mipmapped texture dimensions %d\n",cudaDeviceProp.maxTexture2DMipmap[1]);
		printf("Maximum 3D texture dimensions %d\n",cudaDeviceProp.maxTexture3D[0]);
		printf("Maximum 3D texture dimensions %d\n",cudaDeviceProp.maxTexture3D[1]);
		printf("Maximum 3D texture dimensions %d\n",cudaDeviceProp.maxTexture3D[2]);
		printf("Maximum alternate 3D texture dimensions %d\n",cudaDeviceProp.maxTexture3DAlt[0]);
		printf("Maximum alternate 3D texture dimensions %d\n",cudaDeviceProp.maxTexture3DAlt[1]);
		printf("Maximum alternate 3D texture dimensions %d\n",cudaDeviceProp.maxTexture3DAlt[2]);
		printf("Maximum Cubemap texture dimensions %d\n",cudaDeviceProp.maxTextureCubemap);
		printf("Maximum Cubemap layered texture dimensions %d\n",cudaDeviceProp.maxTextureCubemapLayered[0]);
		printf("Maximum Cubemap layered texture dimensions %d\n",cudaDeviceProp.maxTextureCubemapLayered[1]);
		printf("Maximum size of each dimension of a block %d\n",cudaDeviceProp.maxThreadsDim[0]);
		printf("Maximum size of each dimension of a block %d\n",cudaDeviceProp.maxThreadsDim[1]);
		printf("Maximum size of each dimension of a block %d\n",cudaDeviceProp.maxThreadsDim[2]);
		printf("Maximum number of threads per block %d\n",cudaDeviceProp.maxThreadsPerBlock);
		printf("Maximum resident threads per multiprocessor %d\n",cudaDeviceProp.maxThreadsPerMultiProcessor);
		printf("Maximum pitch in bytes allowed by memory copies %d\n",cudaDeviceProp.memPitch);
		printf("Global memory bus width in bits %d\n",cudaDeviceProp.memoryBusWidth);
		printf("Peak memory clock frequency in kilohertz %d\n",cudaDeviceProp.memoryClockRate);
		printf("Minor compute capability %d\n",cudaDeviceProp.minor);
		printf("Number of multiprocessors on device %d\n",cudaDeviceProp.multiProcessorCount);
		printf("PCI bus ID of the device %d\n",cudaDeviceProp.pciBusID);
		printf("PCI device ID of the device %d\n",cudaDeviceProp.pciDeviceID);
		printf("PCI domain ID of the device %d\n",cudaDeviceProp.pciDomainID);
		printf("32-bit registers available per block %d\n",cudaDeviceProp.regsPerBlock);
		printf("Shared memory available per block in bytes %d\n",cudaDeviceProp.sharedMemPerBlock);
		printf("Device supports stream priorities %d\n",cudaDeviceProp.streamPrioritiesSupported);
		printf("Alignment requirements for surfaces %d\n",cudaDeviceProp.surfaceAlignment);
		printf("1 if device is a Tesla device using TCC driver, 0 otherwise %d\n",cudaDeviceProp.tccDriver);
		printf("Alignment requirement for textures %d\n",cudaDeviceProp.textureAlignment);
		printf("Pitch alignment requirement for texture references bound to pitched memory %d\n",cudaDeviceProp.texturePitchAlignment);
		printf("Constant memory available on device in bytes %d\n",cudaDeviceProp.totalConstMem);
		printf("Global memory available on device in bytes %d\n",cudaDeviceProp.totalGlobalMem);
		printf("Device shares a unified address space with the host %d\n",cudaDeviceProp.unifiedAddressing);
		printf("Warp size in threads %d\n",cudaDeviceProp.warpSize);

		fflush(stdout);
	}

	host_little(gridSize, blockSize, matrix, bestFrom, bestTo, &bestPrice, n);

	cudaDeviceReset();

	/* Bыводим результаты */
	if (bestPrice != LONG_MAX){
		printf("Best Path\t: "); for (int i = 0; i < n; i++) printf("(%d,%d)%s", bestFrom[i], bestTo[i], ((i < (n - 1)) ? "," : "\n"));
		printf("Best Price\t: %ld\n", bestPrice);

		fs = fopen(outputFileName, "w");
		if (fs == NULL) {
			fprintf(stderr, "File open error (%s)\n", outputFileName); fflush(stderr);
			exit(-1);
		}
		for (int i = 0; i < n; i++) fprintf(fs, "%d;%d\n", bestFrom[i], bestTo[i]);
		fclose(fs);
	}


	free(matrix);
	free(bestFrom);
	free(bestTo);

	fflush(stdout);

	if (bestPrice == LONG_MAX) exit(-1);
	exit(0);
}