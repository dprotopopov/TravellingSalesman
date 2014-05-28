using TravellingSalesman.Floyd;

namespace TravellingSalesman.Cuda
{
    public class CudaFloydAlgorithm : FloydAlgorithm
    {
        public CudaFloydAlgorithm(int gridSize, int blockSize)
        {
            ExeFileName = "cudafloyd.exe";
            BlockSize = blockSize;
            GridSize = gridSize;
        }

        public int GridSize { get; set; }
        public int BlockSize { get; set; }

        public override string Command
        {
            get
            {
                return string.Format("/C {0} -g {1} -b {2} {3} {4} {5} 1> {6} 2>&1", ExeFileName, BlockSize, GridSize,
                    InputFileName, OutputFileName,
                    IntermedianFileName,
                    LogFileName);
            }
        }
    }
}