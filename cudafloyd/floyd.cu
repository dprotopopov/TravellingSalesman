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

__global__ void global_init(long *prev, long *next, int *intermedian, int m, int n){
	for (int id = blockDim.x*blockIdx.x + threadIdx.x; id < n*n; id += blockDim.x*gridDim.x) {
		intermedian[id] = -1;
	}
}

__global__ void global_floyd(long *prev, long *next, int *intermedian, int m, int n){
	for (int id = blockDim.x*blockIdx.x + threadIdx.x; id < n*n; id += blockDim.x*gridDim.x) {
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
}

__host__ void host_floyd(int gridSize, int blockSize, long *matrix, int *intermedian, int n)
{
	cudaError_t err;
	long *device_prev;
	long *device_next;
	int *device_intermedian;

	err = cudaMalloc((void**)&device_prev, n*n * sizeof(long));
	err = cudaMalloc((void**)&device_next, n*n * sizeof(long));
	err = cudaMalloc((void**)&device_intermedian, n*n * sizeof(int));

	err = cudaMemcpy(device_prev, matrix, n*n*sizeof(long), cudaMemcpyHostToDevice);

	int blocks = (gridSize > 0)? gridSize : min(max(1, (int)pow((double)n*n, 0.333333333333333)), 15);
	int threads = (blockSize > 0)? blockSize : min(max(1, (int)pow((double)n*n, 0.333333333333333)), 15);
	global_init <<< blocks, threads >>>(device_prev, device_next, device_intermedian, -1, n);

	for(int m = 0; m < n ; m++){
		global_floyd <<< blocks, threads >>>(device_prev, device_next, device_intermedian, m, n);
		err = cudaMemcpy(matrix, device_next, n*n*sizeof(long), cudaMemcpyDeviceToHost);
		for (int i = 0; i < n; i++){
			for (int j = 0; j < n; j++){
				printf("%ld%s", matrix[i*n + j], ((j == n - 1) ? "\n" : ";"));
			}
		}
		printf("\n");
		long * t = device_prev; device_prev = device_next; device_next = t;
	}

	err = cudaMemcpy(matrix, device_prev, n*n*sizeof(long), cudaMemcpyDeviceToHost);
	err = cudaMemcpy(intermedian, device_intermedian, n*n*sizeof(int), cudaMemcpyDeviceToHost);

	err = cudaFree(device_prev);
	err = cudaFree(device_next);
	err = cudaFree(device_intermedian);

	err = err;
}

int main(int argc, char* argv[])
{
	int gridSize = 0;
	int blockSize = 0;

	printf("Title :\t%s\n", title); fflush(stdout);

	if (argc < 4) {
		printf("Usage :\t%s [-g <gridSize>] [-b <blockSize>] <inputfilename> <outputfilename> <intermedianfilename>\n", argv[0]); fflush(stdout);
		printf("\tinputfilename - source matrix of path prices or empty\n"); fflush(stdout);
		printf("\toutputfilename - output floyd's matrix of path prices\n"); fflush(stdout);
		printf("\tintermedianfilename - output matrix of intermedian points or empty\n"); fflush(stdout);
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
	char *intermedianFileName = argv[argId++];

	printf("Input File Name :\t%s\n", inputFileName); fflush(stdout);
	printf("Output File Name :\t%s\n", outputFileName); fflush(stdout);
	printf("Intermedian File Name :\t%s\n", intermedianFileName); fflush(stdout);

	char buffer[4096];
	char *tok;
	char *p;
	int n;         /* Ранг текущего массива */
	long *matrix;  /* Массив цен */
	int *intermedian;  /* Массивов промежуточных точек */
	int i, j;

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
	intermedian = (int *)malloc(n*n*sizeof(int));

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

	host_floyd(gridSize, blockSize, matrix, intermedian, n);

	cudaDeviceReset();

	/* Bыводим результаты */
	fs = fopen(outputFileName, "w");
	if (fs == NULL) {
		fprintf(stderr, "File open error (%s)\n", outputFileName); fflush(stderr);
		exit(-1);
	}
	for (i = 0; i < n; i++){
		for (j = 0; j < n; j++){
			if (matrix[i*n + j] != LONG_MAX)
				fprintf(fs, "%ld%s", matrix[i*n + j], ((j == n - 1) ? "\n" : ";"));
			else
				fprintf(fs, "%s", ((j == n - 1) ? "\n" : ";"));
		}
	}
	fclose(fs);

	/* Bыводим результаты */
	fs = fopen(intermedianFileName, "w");
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

	free(matrix);
	free(intermedian);

	exit(0);
}