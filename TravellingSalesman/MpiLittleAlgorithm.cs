namespace TravellingSalesman
{
    public class MpiLittleAlgorithm : LittleAlgorithm
    {
        public MpiLittleAlgorithm(int numberOfProcess = 10)
        {
            ExeFileName = "mpilittle.exe";
            NumberOfProcess = numberOfProcess;
        }

        public int NumberOfProcess { get; set; }

        public override string Command
        {
            get
            {
                return string.Format("/C mpiexec.exe -n {0} {1} {2} {3} 1> {4} 2>&1", NumberOfProcess, ExeFileName,
                    InputFileName, OutputFileName,
                    LogFileName);
            }
        }
    }
}