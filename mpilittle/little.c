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
Сделаем это и для столбцов, не содержащих нуля. 
Получим матрицу стоимости, каждая строка и каждый столбец которой содержат хотя бы один нулевой элемент.
Для каждого нулевого элемента матрицы cij  рассчитаем коэффициент Гi,j, который равен сумме наименьшего элемента i строки 
(исключая элемент Сi,j=0) и наименьшего элемента j столбца. 
Из всех коэффициентов  Гi,j выберем такой, который является максимальным Гk,l=max{Гi,j}. 
В гамильтонов контур вносится соответствующая дуга (k,l).
Удаляем k-тую строку и столбец l, поменяем на бесконечность значение элемента Сl,k (поскольку дуга (k,l) включена в контур, 
то обратный путь из l в k недопустим).
Повторяем алгоритм шага 1, пока порядок матрицы не станет равным двум.
Затем в текущий ориентированный граф вносим две недостающие дуги, определяющиеся однозначно матрицей прядка 2. 
Получаем гамильтонов контур.
В ходе решения ведется постоянный подсчет текущего значения нижней границы. 
Нижняя граница равна сумме всех вычтенных элементов в строках и столбцах. 
Итоговое значение нижней границы должно совпасть с длиной результирующего контура.*/

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

void _mpi_queue_oneway(int *queue, int *qsize, int *lbound, int *gamma, int *slice, int **matrix, int **rows, int **cols, int *from, int *to, int *m, int n, int rank, int myrank, int nrank, MPI_Status *status){
	int id; for (id = myrank*2*n / nrank; id < (int)((myrank + 1)*2*n / nrank); id++) {
		if (id < n){
			m[0] = 0;
			int i; for (i = 0; m[0] < 2 && i < n; i++)
				if (matrix[n][i*n + id] != INT_MAX) {
					m[0]++; m[1] = i*n + id;
				}
			if (m[0] == 1) queue[--qsize[n]] = m[1];
		}
		else {
			m[0] = 0;
			int j; for (j = 0; m[0] < 2 && j < n; j++)
				if (matrix[n][(id-n)*n + j] != INT_MAX) {
					m[0]++; m[1] = (id - n)*n + j;
				}
			if (m[0] == 1) queue[--qsize[n]] = m[1];
		}
	}
}
void _mpi_add_forbidden(int *queue, int *qsize, int *lbound, int *gamma, int *slice, int **matrix, int **rows, int **cols, int *from, int *to, int *m, int n, int rank, int myrank, int nrank, MPI_Status *status){
	int id; for (id = n; id < rank; id++) {
		int i; for (i = n; i-- > 0;) if (rows[n][i] == to[id]) break; /* Номер строки */
		int j; for (j = n; j-- > 0;) if (cols[n][j] == from[id]) break; /* Номер столбца */
		if (i != -1 && j != -1) matrix[n][i*n + j] = INT_MAX;
	}
}
void _mpi_rowscols_trunc(int *queue, int *qsize, int *lbound, int *gamma, int *slice, int **matrix, int **rows, int **cols, int *from, int *to, int *m, int n, int rank, int myrank, int nrank, MPI_Status *status){
	/* Удаляем строку и столбец в процессах */
	memmove(rows[n - 1], rows[n], m[0] * sizeof(int));
	memmove(&rows[n - 1][m[0]], &rows[n][m[0] + 1], (n - m[0] - 1) * sizeof(int));
	memmove(cols[n - 1], cols[n], m[1] * sizeof(int));
	memmove(&cols[n - 1][m[1]], &cols[n][m[1] + 1], (n - m[1] - 1) * sizeof(int));
}
void _mpi_matrix_trunc(int *queue, int *qsize, int *lbound, int *gamma, int *slice, int **matrix, int **rows, int **cols, int *from, int *to, int *m, int n, int rank, int myrank, int nrank, MPI_Status *status){
	/* Удаляем строку и столбец параллельно в процессах */
	int id; for (id = myrank*(n - 1)*(n - 1) / nrank; id < ((myrank + 1)*(n - 1)*(n - 1) / nrank); id++) {
		int i = id / (n - 1); /* Номер строки */
		int j = id % (n - 1); /* Номер столбца */
		if (i < m[0] && j < m[1]) matrix[n - 1][id] = matrix[n][(i + 0)*n + j + 0];
		else if (i >= m[0] && j < m[1]) matrix[n - 1][id] = matrix[n][(i + 1)*n + j + 0];
		else if (i < m[0] && j >= m[1]) matrix[n - 1][id] = matrix[n][(i + 0)*n + j + 1];
		else if (i >= m[0] && j >= m[1]) matrix[n - 1][id] = matrix[n][(i + 1)*n + j + 1];
	}
}
void _mpi_queue_indexes_of_max(int *queue, int *qsize, int *lbound, int *gamma, int *slice, int **matrix, int **rows, int **cols, int *from, int *to, int *m, int n, int rank, int myrank, int nrank, MPI_Status *status){
	/* Находим все индексы максимального коэффициента параллельно в процессах */
	/* Каждый процесс обрабатывает подмножество матрицы из m / nrank элементов */
	/* Список сохраняется в стеке индексов */
	int id; for (id = (myrank*(m[0] + 1) / nrank); id < ((myrank + 1)*(m[0] + 1) / nrank); id++) {
		if (m[1] == gamma[id]) queue[--qsize[n]] = id;
	}
}
void _mpi_join_queue(int *queue, int *qsize, int *lbound, int *gamma, int *slice, int **matrix, int **rows, int **cols, int *from, int *to, int *m, int n, int rank, int myrank, int nrank, MPI_Status *status){
	/* Собираем последовательным опросом дочерних процессов все индексы максимального коэффициента в хост-процессе */
	/* Список сохраняется в стеке индексов */
	if (myrank == 0) {
		int i; for (i = 1; i < nrank; i++) {
			MPI_Recv(&m[1], 1, MPI_INT, i, DATA_TAG, MPI_COMM_WORLD, status);
			qsize[n] = qsize[n] - m[1];
			if (m[1] > 0) MPI_Recv(&queue[qsize[n]], m[1], MPI_INT, i, DATA_TAG, MPI_COMM_WORLD, status);
		}
	}
	else {
		m[1] = qsize[n + 1] - qsize[n];
		MPI_Send(&m[1], 1, MPI_INT, 0, DATA_TAG, MPI_COMM_WORLD);
		if (m[1] > 0) MPI_Send(&queue[qsize[n]], m[1], MPI_INT, 0, DATA_TAG, MPI_COMM_WORLD);
	}

	/* Копируем брэдкастом все индексы максимального коэффициента в дочерние процессы */
	MPI_Bcast(&qsize[n], 1, MPI_INT, 0, MPI_COMM_WORLD);
	if (qsize[n + 1] > qsize[n]) MPI_Bcast(&queue[qsize[n]], (qsize[n + 1] - qsize[n]), MPI_INT, 0, MPI_COMM_WORLD);
}
void _mpi_gamma_max_index_of_max(int *queue, int *qsize, int *lbound, int *gamma, int *slice, int **matrix, int **rows, int **cols, int *from, int *to, int *m, int n, int rank, int myrank, int nrank, MPI_Status *status){
	/* Находим максимальный индекс максимального коэффициента параллельно в процессах */
	/* Каждый процесс обрабатывает подмножество матрицы из n*n / nrank элементов */
	m[0] = (int)(myrank*n*n / nrank); m[1] = gamma[m[0]];
	int id; for (id = m[0] + 1; id < ((myrank + 1)*n*n / nrank); id++) {
		if (m[1] <= gamma[id]) {
			m[0] = id; m[1] = gamma[m[0]];
		}
	}

	/* Собираем последовательным опросом дочерних процессов максимальный индекс максимального коэффициента в хост-процессе */
	if (myrank == 0) {
		int i; for (i = 1; i < nrank; i++) {
			MPI_Recv(&m[1], 1, MPI_INT, i, DATA_TAG, MPI_COMM_WORLD, status);
			if ((gamma[m[0]] < gamma[m[1]]) || ((gamma[m[0]] == gamma[m[1]]) && (m[0] < m[1]))) m[0] = m[1];
		}
	}
	else {
		MPI_Send(&m[0], 1, MPI_INT, 0, DATA_TAG, MPI_COMM_WORLD);
	}

	/* Копируем брэдкастом максимальный индекс максимального коэффициента в дочерние процессы */
	MPI_Bcast(&m[0], 1, MPI_INT, 0, MPI_COMM_WORLD);
	m[1] = gamma[m[0]];
}
void _mpi_calc_gamma(int *queue, int *qsize, int *lbound, int *gamma, int *slice, int **matrix, int **rows, int **cols, int *from, int *to, int *m, int n, int rank, int myrank, int nrank, MPI_Status *status){
	/* Расчитываем коэффициенты параллельно в процессах */
	/* Каждый процесс обрабатывает подмножество матрицы из n*n / nrank элементов */
	int id; for (id = ((int)(myrank*n*n / nrank)); id < (int)((myrank + 1)*n*n / nrank); id++) {
		if (matrix[n][id] == 0) {
			int i = id / n; /* Номер строки */
			int j = id % n; /* Номер столбца */
			int x = matrix[n][i*n + ((j + 1) % n)]; /* Берём следующий элемент в качестве начального */
			int y = matrix[n][((i + 1) % n)*n + j]; /* Берём следующий элемент в качестве начального */
			int k; for (k = 2; k < n; k++){
				x = min(x, matrix[n][(i*n) + ((j + k) % n)]);
				y = min(y, matrix[n][((i + k) % n)*n + j]);
			}
			if ((x == INT_MAX) && (y == INT_MAX)) gamma[id] = INT_MAX; /* Из города не въехать и не выехать */
			else if (x == INT_MAX) gamma[id] = y; /* Из города не въехать */
			else if (y == INT_MAX) gamma[id] = x; /* Из города не выехать */
			else gamma[id] = x + y;
		}
		else gamma[id] = INT_MIN;
	}
}
void _mpi_sub_by_row(int *queue, int *qsize, int *lbound, int *gamma, int *slice, int **matrix, int **rows, int **cols, int *from, int *to, int *m, int n, int rank, int myrank, int nrank, MPI_Status *status){
	/* Находим минимальные значения в строках матрицы параллельно в процессах */
	/* Каждый процесс обрабатывает подмножество матрицы из n*n / nrank элементов */
	int id; for (id = ((int)(myrank*n*n / nrank)); id < ((myrank + 1)*n*n / nrank); id++) {
		int i = id / n; /* Номер строки */
		if (matrix[n][id] != INT_MAX) matrix[n][id] = matrix[n][id]-slice[i];
	}
}
void _mpi_sub_by_col(int *queue, int *qsize, int *lbound, int *gamma, int *slice, int **matrix, int **rows, int **cols, int *from, int *to, int *m, int n, int rank, int myrank, int nrank, MPI_Status *status){
	/* Находим минимальные значения в строках матрицы параллельно в процессах */
	/* Каждый процесс обрабатывает подмножество матрицы из n*n / nrank элементов */
	int id; for (id = ((int)(myrank*n*n / nrank)); id < ((myrank + 1)*n*n / nrank); id++) {
		int j = id % n; /* Номер столбца */
		if (matrix[n][id] != INT_MAX) matrix[n][id] = matrix[n][id]-slice[j];
	}
}
void _mpi_join_matrix(int *queue, int *qsize, int *lbound, int *gamma, int *slice, int **matrix, int **rows, int **cols, int *from, int *to, int *m, int n, int rank, int myrank, int nrank, MPI_Status *status){
	/* Собираем последовательным опросом дочерних процессов уменьшенные значения в хост-процессе */
	if (myrank == 0) {
		int i; for (i = 1; i < nrank; i++) {
			int j = (int)(i*n*n / nrank); /* Начиная с индекса */
			int k = (int)((i + 1)*n*n / nrank); /* До индекса ( не включтельно ) */
			if (k > j) MPI_Recv(&matrix[n][j], k - j, MPI_INT, i, DATA_TAG, MPI_COMM_WORLD, status);
		}
	}
	else {
		int j = (int)(myrank*n*n / nrank); /* Начиная с индекса */
		int k = (int)((myrank + 1)*n*n / nrank); /* До индекса ( не включтельно ) */
		if (k > j) MPI_Send(&matrix[n][j], k - j, MPI_INT, 0, DATA_TAG, MPI_COMM_WORLD);
	}

	/* Копируем брэдкастом матрицу с уменьшенными значениями в дочерние процессы */
	MPI_Bcast(matrix[n], n*n, MPI_INT, 0, MPI_COMM_WORLD);
}
void _mpi_join_gamma(int *queue, int *qsize, int *lbound, int *gamma, int *slice, int **matrix, int **rows, int **cols, int *from, int *to, int *m, int n, int rank, int myrank, int nrank, MPI_Status *status){
	/* Собираем последовательным опросом дочерних процессов уменьшенные значения в хост-процессе */
	if (myrank == 0) {
		int i; for (i = 1; i < nrank; i++) {
			int j = (int)(i*n*n / nrank); /* Начиная с индекса */
			int k = (int)((i + 1)*n*n / nrank); /* До индекса ( не включтельно ) */
			if (k > j) MPI_Recv(&gamma[j], k - j, MPI_INT, i, DATA_TAG, MPI_COMM_WORLD, status);
		}
	}
	else {
		int j = (int)(myrank*n*n / nrank); /* Начиная с индекса */
		int k = (int)((myrank + 1)*n*n / nrank); /* До индекса ( не включтельно ) */
		if (k > j) MPI_Send(&gamma[j], k - j, MPI_INT, 0, DATA_TAG, MPI_COMM_WORLD);
	}

	/* Копируем брэдкастом матрицу с уменьшенными значениями в дочерние процессы */
	MPI_Bcast(gamma, n*n, MPI_INT, 0, MPI_COMM_WORLD);
}
void _mpi_join_min_slice(int *queue, int *qsize, int *lbound, int *gamma, int *slice, int **matrix, int **rows, int **cols, int *from, int *to, int *m, int n, int rank, int myrank, int nrank, MPI_Status *status){
	/* Собираем последовательным опросом дочерних процессов минимальные значения в хост-процессе */
	if (myrank == 0) {
		int i; for (i = 1; i < nrank; i++){
			int j = ((int)(i*n*n / nrank)) / n; /* Начиная с индекса */
			int k = ((int)(((i + 1)*n*n + nrank - 1) / nrank) + n - 1) / n; /* До индекса ( не включтельно ) */
			if (k > j) MPI_Recv(&slice[n + j], k - j, MPI_INT, i, DATA_TAG, MPI_COMM_WORLD, status);
			for (; j < k; j++) slice[j] = min(slice[j], slice[n + j]);
		}
	}
	else {
		int j = ((int)(myrank*n*n / nrank)) / n; /* Начиная с индекса */
		int k = ((int)(((myrank + 1)*n*n + nrank - 1) / nrank) + n - 1) / n; /* До индекса ( не включтельно ) */
		if (k > j) MPI_Send(&slice[j], k - j, MPI_INT, 0, DATA_TAG, MPI_COMM_WORLD);
	}

	/* Копируем брэдкастом минимальные значения в дочерние процессы */
	MPI_Bcast(slice, n, MPI_INT, 0, MPI_COMM_WORLD);
}
void _mpi_join_max_slice(int *queue, int *qsize, int *lbound, int *gamma, int *slice, int **matrix, int **rows, int **cols, int *from, int *to, int *m, int n, int rank, int myrank, int nrank, MPI_Status *status){
	/* Собираем последовательным опросом дочерних процессов минимальные значения в хост-процессе */
	if (myrank == 0) {
		int i; for (i = 1; i < nrank; i++){
			int j = ((int)(i*n*n / nrank)) / n; /* Начиная с индекса */
			int k = ((int)(((i + 1)*n*n + nrank - 1) / nrank) + n - 1) / n; /* До индекса ( не включтельно ) */
			if (k > j) MPI_Recv(&slice[n + j], k - j, MPI_INT, i, DATA_TAG, MPI_COMM_WORLD, status);
			for (; j < k; j++) slice[j] = max(slice[j], slice[n + j]);
		}
	}
	else {
		int j = ((int)(myrank*n*n / nrank)) / n; /* Начиная с индекса */
		int k = ((int)(((myrank + 1)*n*n + nrank - 1) / nrank) + n - 1) / n; /* До индекса ( не включтельно ) */
		if (k > j) MPI_Send(&slice[j], k - j, MPI_INT, 0, DATA_TAG, MPI_COMM_WORLD);
	}

	/* Копируем брэдкастом минимальные значения в дочерние процессы */
	MPI_Bcast(slice, n, MPI_INT, 0, MPI_COMM_WORLD);
}
void _mpi_min_by_col(int *queue, int *qsize, int *lbound, int *gamma, int *slice, int **matrix, int **rows, int **cols, int *from, int *to, int *m, int n, int rank, int myrank, int nrank, MPI_Status *status){
	/* Находим минимальные значения в колонках матрицы параллельно в процессах */
	/* Каждый процесс обрабатывает подмножество матрицы из n*n / nrank элементов */
	int j; for (j = 0; j < n; j++) slice[j] = matrix[n][j];
	int id; for (id = (int)(myrank*n*n / nrank); id < (int)((myrank + 1)*n*n / nrank); id++) {
		int i = id % n; /* Номер строки */
		int j = id / n; /* Номер столбца */
		slice[j] = min(slice[j], matrix[n][i*n+j]);
	}
}
void _mpi_min_by_row(int *queue, int *qsize, int *lbound, int *gamma, int *slice, int **matrix, int **rows, int **cols, int *from, int *to, int *m, int n, int rank, int myrank, int nrank, MPI_Status *status){
	/* Находим минимальные значения в строках матрицы параллельно в процессах */
	/* Каждый процесс обрабатывает подмножество матрицы из n*n / nrank элементов */
	int i; for (i = 0; i < n; i++) slice[i] = matrix[n][n*i];
	int id; for (id = (int)(myrank*n*n / nrank); id < (int)((myrank + 1)*n*n / nrank); id++) {
		int i = id / n;
		slice[i] = min(slice[i], matrix[n][id]);
	}
}
void _mpi_next_by_row(int *queue, int *qsize, int *lbound, int *gamma, int *slice, int **matrix, int **rows, int **cols, int *from, int *to, int *m, int n, int rank, int myrank, int nrank, MPI_Status *status){
	int id; for (id = (int)(myrank*n*n / nrank); id < (int)((myrank + 1)*n*n / nrank); id++) {
		int i = id / n; /* Номер строки */
		int j = id % n; /* Номер столбца */
		if (matrix[n][id] != INT_MAX){
			slice[j] = max(slice[j], slice[i]);
		}
		if (i == j) slice[j] = 1;
	}
}
void _mpi_prev_by_col(int *queue, int *qsize, int *lbound, int *gamma, int *slice, int **matrix, int **rows, int **cols, int *from, int *to, int *m, int n, int rank, int myrank, int nrank, MPI_Status *status){
	int id; for (id = (int)(myrank*n*n / nrank); id < (int)((myrank + 1)*n*n / nrank); id++) {
		int i = id % n; /* Номер строки */
		int j = id / n; /* Номер столбца */
		if (matrix[n][i*n + j] != INT_MAX) slice[j] = max(slice[j], slice[i]);
		if (i == j) slice[j] = 1;
	}
}
void _mpi_check_infinity(int *queue, int *qsize, int *lbound, int *gamma, int *slice, int **matrix, int **rows, int **cols, int *from, int *to, int *m, int n, int rank, int myrank, int nrank, MPI_Status *status){
	m[0] = 0;
	int id; for (id = (int)(myrank*n / nrank); (m[0] == 0) && (id < (int)((myrank + 1)*n / nrank)); id++) {
		if (slice[id] == INT_MAX) m[0] = 1;
	}
	/* Собираем последовательным опросом дочерних процессов суммы в хост-процессе */
	if (myrank == 0) {
		int i; for (i = 1; i < nrank; i++){
			MPI_Recv(&m[1], 1, MPI_INT, i, DATA_TAG, MPI_COMM_WORLD, status);
			m[0] = max(m[0], m[1]);
		}
	}
	else {
		MPI_Send(&m[0], 1, MPI_INT, 0, DATA_TAG, MPI_COMM_WORLD);
	}
	MPI_Bcast(&m[0], 1, MPI_INT, 0, MPI_COMM_WORLD);
}

void _mpi_min_by_dim(int *queue, int *qsize, int *lbound, int *gamma, int *slice, int **matrix, int **rows, int **cols, int *from, int *to, int *m, int n, int rank, int myrank, int nrank, MPI_Status *status){
	m[0] = n;
	int id; for (id = (int)(myrank*n / nrank); (m[0] != 0) && (id < (int)((myrank + 1)*n / nrank)); id++) {
		m[0] = min(m[0], slice[id]);
	}
	/* Собираем последовательным опросом дочерних процессов суммы в хост-процессе */
	if (myrank == 0) {
		int i; for (i = 1; i < nrank; i++){
			MPI_Recv(&m[1], 1, MPI_INT, i, DATA_TAG, MPI_COMM_WORLD, status);
			m[0] = min(m[0], m[1]);
		}
	}
	else {
		MPI_Send(&m[0], 1, MPI_INT, 0, DATA_TAG, MPI_COMM_WORLD);
	}
}
void _mpi_sum_lbound(int *queue, int *qsize, int *lbound, int *gamma, int *slice, int **matrix, int **rows, int **cols, int *from, int *to, int *m, int n, int rank, int myrank, int nrank, MPI_Status *status){
	
	m[0] = 0;

	int i; for (i = 1; i < n; i++) lbound[i] = matrix[n][(n - 1)*i];

	int id; for (id = (int)(myrank*rank / nrank); id < (int)((myrank + 1)*rank / nrank); id++) {
		m[0] += lbound[id+1];
	}
	/* Собираем последовательным опросом дочерних процессов сумму в хост-процессе */
	if (myrank == 0) {
		int i; for (i = 1; i < nrank; i++){
			MPI_Recv(&m[1], 1, MPI_INT, i, DATA_TAG, MPI_COMM_WORLD, status);
			m[0] += m[1];
		}
	}
	else {
		MPI_Send(&m[0], 1, MPI_INT, 0, DATA_TAG, MPI_COMM_WORLD);
	}
	/* Копируем брэдкастом сумму в дочерние процессы */
	MPI_Bcast(&m[0], 1, MPI_INT, 0, MPI_COMM_WORLD);
}
void _mpi_sum_lbound_begin(int *queue, int *qsize, int *lbound, int *gamma, int *slice, int **matrix, int **rows, int **cols, int *from, int *to, int *m, int n, int rank, int myrank, int nrank, MPI_Status *status){
	lbound[n] = 0;
}
void _mpi_sum_lbound_step(int *queue, int *qsize, int *lbound, int *gamma, int *slice, int **matrix, int **rows, int **cols, int *from, int *to, int *m, int n, int rank, int myrank, int nrank, MPI_Status *status){
	/* Каждый процесс обрабатывает подмножество из n / nrank элементов */
	int id; for (id = myrank*n / nrank; id < ((myrank + 1)*n / nrank); id++) {
		lbound[n] += slice[id];
	}
}
void _mpi_sum_lbound_end(int *queue, int *qsize, int *lbound, int *gamma, int *slice, int **matrix, int **rows, int **cols, int *from, int *to, int *m, int n, int rank, int myrank, int nrank, MPI_Status *status){
	/* Собираем последовательным опросом дочерних процессов Текущую Нижнюю Границу в хост-процессе */
	if (myrank == 0) {
		int i; for (i = 1; i < nrank; i++) {
			MPI_Recv(&m[0], 1, MPI_INT, i, DATA_TAG, MPI_COMM_WORLD, status);
			lbound[n] += m[0];
		}
	}
	else {
		MPI_Send(&lbound[n], 1, MPI_INT, 0, DATA_TAG, MPI_COMM_WORLD);
	}

	/* Копируем брэдкастом Текущую Нижнюю Границу в дочерние процессы */
	MPI_Bcast(&lbound[n], 1, MPI_INT, 0, MPI_COMM_WORLD);
}

main(int argc, char *argv[])
{ 
	int rank;         /* Ранг исходного массива */
	int n;         /* Ранг текущего массива */
	int nrank;     /* Общее количество процессов */
	int myrank;    /* Номер текущего процесса */ 
	int **matrix;  /* Стек массивов элементов */
	int *gamma;    /* Массив коэффициентов */
	int *queue;    /* Стек очередей индексов элементов */
	int *qsize;    /* Размер очередей индексов элементов */
	int *lbound;   /* Стек вычисленных нижних границ */
	int **rows;		/* Стек текущих координат строк */
	int **cols;		/* Стек текущих координат столцов */
	/* Стеки дуг (индексов) хранятся в порядке их удаления из матрицы */
	/* Индексы записаны в соответствии с текущим размером матрицы */
	/* и требуют пересчёта в исходный размер матрицы */
	int *from; /* Стек дуг (индексов) в порядке их удаления из матрицы */
	int *to;   /* Стек дуг (индексов) в порядке их удаления из матрицы */
	int *bestFrom; /* Стек дуг (индексов) в порядке их удаления из матрицы */
	int *bestTo;   /* Стек дуг (индексов) в порядке их удаления из матрицы */
	int bestPrice;
	int *m;
	int *slice;
	int i, j, id;

	MPI_Status status; 

	/* Иницилизация MPI */ 
	MPI_Init(&argc, &argv); 
	MPI_Comm_size(MPI_COMM_WORLD, &nrank); 
	MPI_Comm_rank(MPI_COMM_WORLD, &myrank); 

	if (myrank == 0) {

		printf("Название :\t%s\n", title);
		printf("Описание :\t%s\n", description);
		printf("Число процессов :\t%d\n", nrank);

		if (argc < 2) {
			printf("Инструкция по применению :\t%s <filename>\n", argv[0]);
			exit(-1);
		}
		char *fileName = argv[1]; 
		char buffer[4096] ;
		char *tok;
		char *p;

		printf("Имя файла :\t%s\n", fileName);

		FILE *fs = fopen(fileName, "r"); 
		if (fs == NULL) {
			printf("Ошибка открытия файла (%s)\n", argv[1]);
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

		matrix = (int **)malloc((n + 1)*sizeof(int*));
		for (i = 1; i <= n; i++) matrix[i] = (int *)malloc(i*i*sizeof(int));

		fseek(fs, 0, SEEK_SET);

		for (i = 0; (tok = fgets(buffer, sizeof(buffer), fs)) != NULL; i++)
		{
			j = 0;
			for (tok = mystrtok(&p, tok, ';'); tok != NULL; tok = mystrtok(&p, NULL, ';'))
			{
				/* Пустые элементы - это запрещённые пути */
				matrix[n][n*i + j++] = strempty(tok) ? INT_MAX : atoi(tok);
			}
			for (; j < n; j++) matrix[n][n*i + j] = INT_MAX;
		}
		for (j = 0; j < (n - i)*n; j++) matrix[n][n*i + j] = INT_MAX;
		for (i = 0; i < n; i++) matrix[n][n*i + i] = INT_MAX; /* Запрещаем петли */

		fclose(fs);

		printf("Ранг матрицы :\t%d\n", n);
		for (i = 0; i < n; i++){
			for (j = 0; j < n; j++){
				printf("%d%s", matrix[n][i*n+j], ((j == n-1) ? "\n" : "\t"));
			}
		}
	}

	/* Копируем брэдкастом ранг матрицы в дочерние процессы */
	MPI_Bcast(&n, 1, MPI_INT, 0, MPI_COMM_WORLD);
	rank = n;

	if (myrank != 0) {
		matrix = (int **)malloc((n + 1)*sizeof(int*));
		for (i = 1; i <= n; i++) matrix[i] = (int *)malloc(i*i*sizeof(int));
	}

	/* Копируем брэдкастом исходную матрицу в дочерние процессы */
	MPI_Bcast(matrix[n], n*n, MPI_INT, 0, MPI_COMM_WORLD);

	m = (int *)malloc(2*sizeof(int));
	slice = (int *)malloc(2*n*sizeof(int*));

	lbound = (int *)malloc((n + 1)*sizeof(int));
	rows = (int **)malloc((n + 1)*sizeof(int*));
	cols = (int **)malloc((n + 1)*sizeof(int*));
	for (i = 1; i <= n; i++) rows[i] = (int *)malloc(i*sizeof(int));
	for (i = 1; i <= n; i++) cols[i] = (int *)malloc(i*sizeof(int));

	lbound[0] = 0;
	for (i = 0; i < n; i++) rows[n][i] = i;
	for (i = 0; i < n; i++) cols[n][i] = i;

	from = (int *)malloc(n*sizeof(int));
	to = (int *)malloc(n*sizeof(int));
	bestFrom = (int *)malloc(n*sizeof(int));
	bestTo = (int *)malloc(n*sizeof(int));

	bestPrice = INT_MAX;

	queue = (int *)malloc(n*n*n * sizeof(int));
	qsize = (int *)malloc((n + 2)*sizeof(int));
	qsize[n + 1] = n*n*n;
	qsize[n] = qsize[n + 1];

	gamma = (int *)malloc(n*n*sizeof(int));

	if (myrank == 0) printf(" Проверяем граф на связанность по строкам \n");
	/* Проверяем граф на связанность по строкам */
	/* Каждый процесс обрабатывает подмножество матрицы из n*n / nrank элементов */
	memset(slice, 0, 2*n*sizeof(int));
	slice[0] = 1;
	for (i = 1; i <= n; i++){
		_mpi_next_by_row(queue, qsize, lbound, gamma, slice, matrix, rows, cols, from, to, m, n, rank, myrank, nrank, &status);
		_mpi_join_max_slice(queue, qsize, lbound, gamma, slice, matrix, rows, cols, from, to, m, n, rank, myrank, nrank, &status);
	}
	_mpi_min_by_dim(queue, qsize, lbound, gamma, slice, matrix, rows, cols, from, to, m, n, rank, myrank, nrank, &status);
	if (myrank == 0 && m[0] == 0) {
		printf("Граф не связанный\n");
		exit(-1);
	}

	if (myrank == 0) printf(" Проверяем граф на связанность по столбцам \n");
	/* Проверяем граф на связанность по столбцам */
	/* Каждый процесс обрабатывает подмножество матрицы из n*n / nrank элементов */
	memset(slice, 0, 2 * n*sizeof(int));
	slice[0] = 1;
	for (i = 1; i <= n; i++){
		_mpi_prev_by_col(queue, qsize, lbound, gamma, slice, matrix, rows, cols, from, to, m, n, rank, myrank, nrank, &status);
		_mpi_join_max_slice(queue, qsize, lbound, gamma, slice, matrix, rows, cols, from, to, m, n, rank, myrank, nrank, &status);
	}
	_mpi_min_by_dim(queue, qsize, lbound, gamma, slice, matrix, rows, cols, from, to, m, n, rank, myrank, nrank, &status);
	if (myrank == 0 && m[0] == 0) {
		printf("Граф не связанный\n");
		exit(-1);
	}

	if (myrank == 0) {
		printf("Граф ok\n");
	}

	while ( n > 0 && n <= rank ) {
		if (myrank == 0) printf("Ранг матрицы :\t%d\n", n);
		if (myrank == 0) for (i = 0; i < n; i++){
			for (j = 0; j < n; j++){
				printf("%d%s", matrix[n][i*n + j], ((j == n - 1) ? "\n" : "\t"));
			}
		}

		_mpi_sum_lbound_begin(queue, qsize, lbound, gamma, slice, matrix, rows, cols, from, to, m, n, rank, myrank, nrank, &status);
		
		if (myrank == 0) printf(" Запрещаем обратные переходы \n");
		/* Запрещаем обратные переходы */
		_mpi_add_forbidden(queue, qsize, lbound, gamma, slice, matrix, rows, cols, from, to, m, n, rank, myrank, nrank, &status);

		if (myrank == 0) for (i = 0; i < n; i++){
			for (j = 0; j < n; j++){
				printf("%d%s", matrix[n][i*n + j], ((j == n - 1) ? "\n" : "\t"));
			}
		}

		if (n > 1)  {
			qsize[n] = qsize[n + 1];

			if (myrank == 0) printf(" Находим минимальные значения в строках матрицы параллельно в процессах \n");
			/* Находим минимальные значения в строках матрицы параллельно в процессах */
			/* Каждый процесс обрабатывает подмножество матрицы из n*n / nrank элементов */
			/* Собираем последовательным опросом дочерних процессов уменьшенные значения в хост-процессе */
			/* Копируем брэдкастом минимальные значения в дочерние процессы */
			_mpi_min_by_row(queue, qsize, lbound, gamma, slice, matrix, rows, cols, from, to, m, n, rank, myrank, nrank, &status);
			_mpi_join_min_slice(queue, qsize, lbound, gamma, slice, matrix, rows, cols, from, to, m, n, rank, myrank, nrank, &status);
			_mpi_check_infinity(queue, qsize, lbound, gamma, slice, matrix, rows, cols, from, to, m, n, rank, myrank, nrank, &status);
			if (m[0] == 0) {

				if (myrank == 0) printf(" Вычитаем минимальные значения из строк параллельно в процессах \n");
				/* Вычитаем минимальные значения из строк параллельно в процессах */
				/* Каждый процесс обрабатывает подмножество матрицы из n*n / nrank элементов */
				/* Собираем последовательным опросом дочерних процессов уменьшенные значения в хост-процессе */
				/* Копируем брэдкастом матрицу с уменьшенными значениями в дочерние процессы */
				_mpi_sub_by_row(queue, qsize, lbound, gamma, slice, matrix, rows, cols, from, to, m, n, rank, myrank, nrank, &status);
				_mpi_join_matrix(queue, qsize, lbound, gamma, slice, matrix, rows, cols, from, to, m, n, rank, myrank, nrank, &status);

				if (myrank == 0) for (i = 0; i < n; i++){
					for (j = 0; j < n; j++){
						printf("%d%s", matrix[n][i*n + j], ((j == n - 1) ? "\n" : "\t"));
					}
				}

				if (myrank == 0) printf(" Находим сумму минимальных значений в строках матрицы параллельно в процессах \n");
				/* Находим сумму минимальных значений в строках матрицы параллельно в процессах */
				/* Каждый процесс обрабатывает подмножество из n / nrank элементов */
				_mpi_sum_lbound_step(queue, qsize, lbound, gamma, slice, matrix, rows, cols, from, to, m, n, rank, myrank, nrank, &status);
			}

			if (myrank == 0) printf(" Находим минимальные значения в столбцах матрицы параллельно в процессах \n");
			/* Находим минимальные значения в столбцах матрицы параллельно в процессах */
			/* Каждый процесс обрабатывает подмножество матрицы из n*n / nrank элементов */
			/* Собираем последовательным опросом дочерних процессов уменьшенные значения в хост-процессе */
			/* Копируем брэдкастом минимальные значения в дочерние процессы */
			_mpi_min_by_col(queue, qsize, lbound, gamma, slice, matrix, rows, cols, from, to, m, n, rank, myrank, nrank, &status);
			_mpi_join_min_slice(queue, qsize, lbound, gamma, slice, matrix, rows, cols, from, to, m, n, rank, myrank, nrank, &status);
			_mpi_check_infinity(queue, qsize, lbound, gamma, slice, matrix, rows, cols, from, to, m, n, rank, myrank, nrank, &status);
			if (m[0] == 0) {

				if (myrank == 0) printf(" Вычитаем минимальные значения из столбцов параллельно в процессах \n");
				/* Вычитаем минимальные значения из столбцов параллельно в процессах */
				/* Каждый процесс обрабатывает подмножество матрицы из n*n / nrank элементов */
				/* Собираем последовательным опросом дочерних процессов уменьшенные значения в хост-процессе */
				/* Копируем брэдкастом матрицу с уменьшенными значениями в дочерние процессы */
				_mpi_sub_by_col(queue, qsize, lbound, gamma, slice, matrix, rows, cols, from, to, m, n, rank, myrank, nrank, &status);
				_mpi_join_matrix(queue, qsize, lbound, gamma, slice, matrix, rows, cols, from, to, m, n, rank, myrank, nrank, &status);

				if (myrank == 0) for (i = 0; i < n; i++){
					for (j = 0; j < n; j++){
						printf("%d%s", matrix[n][i*n + j], ((j == n - 1) ? "\n" : "\t"));
					}
				}

				if (myrank == 0) printf(" Находим сумму минимальных значений в столбцах матрицы параллельно в процессах \n");
				/* Находим сумму минимальных значений в столбцах матрицы параллельно в процессах */
				/* Каждый процесс обрабатывает подмножество из n / nrank элементов */
				_mpi_sum_lbound_step(queue, qsize, lbound, gamma, slice, matrix, rows, cols, from, to, m, n, rank, myrank, nrank, &status);
			}

			if (myrank == 0) printf(" Находим сумму минимальных значений в столбцах матрицы параллельно в процессах \n");
			/* Собираем последовательным опросом дочерних процессов Текущую Нижнюю Границу в хост-процессе */
			/* Копируем брэдкастом Текущую Нижнюю Границу в дочерние процессы */
			_mpi_sum_lbound_end(queue, qsize, lbound, gamma, slice, matrix, rows, cols, from, to, m, n, rank, myrank, nrank, &status);
			if (myrank == 0) printf("%d\n", lbound[n]);

			if (myrank == 0) printf(" Находим однозначные пути \n");
			/* Находим все индексы максимального коэффициента параллельно в процессах */
			/* Каждый процесс обрабатывает подмножество матрицы из n / nrank элементов */
			_mpi_queue_oneway(queue, qsize, lbound, gamma, slice, matrix, rows, cols, from, to, m, n, rank, myrank, nrank, &status);

			if (myrank == 0) for (i = qsize[n]; i < qsize[n + 1]; i++) printf("%d%s", queue[i], (i == qsize[n + 1] - 1) ? "\n" : "\t");

			/* Собираем последовательным опросом дочерних процессов все индексы максимального коэффициента в хост-процессе */
			/* Список сохраняется в стеке индексов */
			/* Копируем брэдкастом все индексы максимального коэффициента в дочерние процессы */
			_mpi_join_queue(queue, qsize, lbound, gamma, slice, matrix, rows, cols, from, to, m, n, rank, myrank, nrank, &status);

			if (qsize[n] == qsize[n + 1]){
				if (myrank == 0) printf(" Расчитываем коэффициенты параллельно в процессах \n");
				/* Расчитываем коэффициенты параллельно в процессах */
				/* Каждый процесс обрабатывает подмножество матрицы из n*n / nrank элементов */
				/* Собираем последовательным опросом дочерних процессов коэффициенты в хост-процессе */
				/* Копируем брэдкастом коэффициенты в дочерние процессы */
				_mpi_calc_gamma(queue, qsize, lbound, gamma, slice, matrix, rows, cols, from, to, m, n, rank, myrank, nrank, &status);
				_mpi_join_gamma(queue, qsize, lbound, gamma, slice, matrix, rows, cols, from, to, m, n, rank, myrank, nrank, &status);

				if (myrank == 0) for (i = 0; i < n; i++){
					for (j = 0; j < n; j++){
						printf("%d%s", gamma[i*n + j], ((j == n - 1) ? "\n" : "\t"));
					}
				}

				/* Находим максимальный индекс максимального коэффициента параллельно в процессах */
				/* Каждый процесс обрабатывает подмножество матрицы из n*n / nrank элементов */
				/* Собираем последовательным опросом дочерних процессов максимальный индекс максимального коэффициента в хост-процессе */
				/* Копируем брэдкастом максимальный индекс максимального коэффициента в дочерние процессы */
				_mpi_gamma_max_index_of_max(queue, qsize, lbound, gamma, slice, matrix, rows, cols, from, to, m, n, rank, myrank, nrank, &status);

				if (m[1] != INT_MIN)
				{
					if (myrank == 0) printf(" Находим все индексы максимального коэффициента параллельно в процессах \n");
					/* Находим все индексы максимального коэффициента параллельно в процессах */
					/* Каждый процесс обрабатывает подмножество матрицы из m / nrank элементов */
					/* Собираем последовательным опросом дочерних процессов все индексы максимального коэффициента в хост-процессе */
					/* Список сохраняется в стеке индексов */
					/* Копируем брэдкастом все индексы максимального коэффициента в дочерние процессы */
					_mpi_queue_indexes_of_max(queue, qsize, lbound, gamma, slice, matrix, rows, cols, from, to, m, n, rank, myrank, nrank, &status);

					/* Собираем последовательным опросом дочерних процессов все индексы максимального коэффициента в хост-процессе */
					/* Список сохраняется в стеке индексов */
					/* Копируем брэдкастом все индексы максимального коэффициента в дочерние процессы */
					_mpi_join_queue(queue, qsize, lbound, gamma, slice, matrix, rows, cols, from, to, m, n, rank, myrank, nrank, &status);

					if (myrank == 0) for (i = qsize[n]; i < qsize[n + 1]; i++) printf("%d%s", queue[i], (i == qsize[n + 1] - 1) ? "\n" : "\t");
				}
			}
			else {
				qsize[n] = qsize[n + 1] - 1;
			}

			/* Теперь все индексы должны быть рекурсивно обработаны */
			/* Чтобы не делать рекурсивные обходы работаем только с объявленным стеком */
		}
		else {
			memmove(from, rows[n], n*sizeof(int));
			memmove(to, cols[n], n*sizeof(int));

			/* Суммируем Текущую Нижнюю Границу параллельно в процессах */
			/* Каждый процесс обрабатывает подмножество из N / nrank элементов */
			/* Копируем брэдкастом сумму в дочерние процессы */
			_mpi_sum_lbound(queue, qsize, lbound, gamma, slice, matrix, rows, cols, from, to, m, n, rank, myrank, nrank, &status);

			if (myrank == 0) printf(" Суммируем Текущую Нижнюю Границу параллельно в процессах \n");

			/* Сравниваем текущую стоимость с ранее найденой лучшей стоимостью */
			if (m[0] < bestPrice){
				bestPrice = m[0];
				memmove(bestFrom, from, rank*sizeof(int));
				memmove(bestTo, to, rank*sizeof(int));
			}
			if (myrank == 0) printf("Текущая цена\t: %d\n", bestPrice);

			n++;
		}

		/* Возврат из "рекурсивного" вызова */
		/* Чтобы не делать рекурсивные обходы работаем только с объявленным стеком */
		while ((n <= rank) && (qsize[n] == qsize[n + 1])) {
			if (myrank == 0) printf(" Возврат из рекурсивного обхода \n");
			n++;
		}
		if (n > rank) break;

		/* Перебираем значения из очереди */
		id = queue[qsize[n]++]; 

		m[0] = id / n; /* Номер строки */
		m[1] = id % n; /* Номер столбца */

		from[n - 1] = rows[n][m[0]];
		to[n - 1] = cols[n][m[1]];

		if (myrank == 0) printf(" Удаляем строку и столбец параллельно в процессах \n");
		/* Удаляем строку и столбец параллельно в процессах */
		/* Собираем последовательным опросом дочерних процессов усечённый массив в хост-процессе */
		/* Копируем брэдкастом усечённый массив в дочерние процессы */
		_mpi_rowscols_trunc(queue, qsize, lbound, gamma, slice, matrix, rows, cols, from, to, m, n, rank, myrank, nrank, &status);
		_mpi_matrix_trunc(queue, qsize, lbound, gamma, slice, matrix, rows, cols, from, to, m, n, rank, myrank, nrank, &status);
		_mpi_join_matrix(queue, qsize, lbound, gamma, slice, matrix, rows, cols, from, to, m, n - 1, rank, myrank, nrank, &status);

		n--;
	}
	n--;

	/* Bыводим результаты */

	if (myrank == 0) {
		printf("Лучший путь\t: "); for (i = 0; i < n; i++) printf("(%d,%d)%s", bestFrom[i], bestTo[i], ((i < (n - 1)) ? "," : "\n"));
		printf("Лучшая цена\t: %d\n", bestPrice);
	} 

	/* Освобождаем ранее выделенные ресурсы */

	for (i = 1; i <= n; i++) free(matrix[i]);
	for (i = 1; i <= n; i++) free(rows[i]);
	for (i = 1; i <= n; i++) free(cols[i]);
	free(matrix);
	free(rows);
	free(cols);
	free(gamma);
	free(lbound);
	free(queue);
	free(qsize);
	free(from);
	free(to);
	free(bestFrom);
	free(bestTo);
	free(slice);
	free(m);

	MPI_Finalize(); 

	exit(0);
} 
