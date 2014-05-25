using System.Collections.Generic;
using System.Threading.Tasks;

namespace TravellingSalesman
{
    public abstract class Algorithm : IAlgorithm
    {
        public abstract string Command { get; }
        public string InputFileName { get; set; }
        public string OutputFileName { get; set; }
        public string IntermedianFileName { get; set; }
        public string ExeFileName { get; set; }
        public string LogFileName { get; set; }
        public string[,] Matrix { get; set; }
        public string[,] Intermedian { get; set; }
        public IList<string[]> Solution { get; set; }
        public string Log { get; set; }
        public abstract Task<int> Run(bool createInputFile);
    }
}