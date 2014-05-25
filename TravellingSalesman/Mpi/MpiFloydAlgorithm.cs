using TravellingSalesman.Floyd;

namespace TravellingSalesman.Mpi
{
    public class MpiFloydAlgorithm : FloydAlgorithm
    {
        public MpiFloydAlgorithm(int numberOfProcess = 10)
        {
            ExeFileName = "mpifloyd.exe";
            NumberOfProcess = numberOfProcess;
        }

        public int NumberOfProcess { get; set; }

        public override string Command
        {
            get
            {
                return string.Format("/C mpiexec.exe -n {0} {1} {2} {3} {4} 1> {5} 2>&1", NumberOfProcess, ExeFileName,
                    InputFileName, OutputFileName, IntermedianFileName,
                    LogFileName);
            }
        }
    }
}