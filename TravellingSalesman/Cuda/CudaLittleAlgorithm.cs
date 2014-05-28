using TravellingSalesman.Little;

namespace TravellingSalesman.Cuda
{
    public class CudaLittleAlgorithm : LittleAlgorithm
    {
        public CudaLittleAlgorithm(int gridSize, int blockSize)
        {
            ExeFileName = "cudalittle.exe";
            BlockSize = blockSize;
            GridSize = gridSize;
        }

        public int GridSize { get; set; }
        public int BlockSize { get; set; }

        public override string Command
        {
            get
            {
                return string.Format("/C {0} -g {1} -b {2} {3} {4} 1> {5} 2>&1", ExeFileName, BlockSize, GridSize,
                    InputFileName, OutputFileName,
                    LogFileName);
            }
        }
    }
}