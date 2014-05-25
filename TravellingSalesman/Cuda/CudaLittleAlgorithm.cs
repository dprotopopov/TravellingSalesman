using TravellingSalesman.Little;

namespace TravellingSalesman.Cuda
{
    public class CudaLittleAlgorithm : LittleAlgorithm
    {
        public CudaLittleAlgorithm()
        {
            ExeFileName = "cudalittle.exe";
        }

        public override string Command
        {
            get
            {
                return string.Format("/C {0} {1} {2} 1> {3} 2>&1", ExeFileName, InputFileName, OutputFileName,
                    LogFileName);
            }
        }
    }
}