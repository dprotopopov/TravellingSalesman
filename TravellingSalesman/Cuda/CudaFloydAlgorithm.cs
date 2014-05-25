using TravellingSalesman.Floyd;

namespace TravellingSalesman.Cuda
{
    public class CudaFloydAlgorithm : FloydAlgorithm
    {
        public CudaFloydAlgorithm()
        {
            ExeFileName = "cudafloyd.exe";
        }

        public override string Command
        {
            get
            {
                return string.Format("/C {0} {1} {2} {3} 1> {4} 2>&1", ExeFileName, InputFileName, OutputFileName,
                    IntermedianFileName,
                    LogFileName);
            }
        }
    }
}