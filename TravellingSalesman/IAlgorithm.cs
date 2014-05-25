using System.Collections.Generic;
using System.Threading.Tasks;

namespace TravellingSalesman
{
    public interface IAlgorithm
    {
        string[,] Matrix { get; set; }
        string[,] Intermedian { get; set; }
        IList<string[]> Solution { get; set; }
        string Log { get; set; }
        string InputFileName { get; set; }
        string OutputFileName { get; set; }
        string IntermedianFileName { get; set; }
        string ExeFileName { get; set; }
        string LogFileName { get; set; }
        Task<int> Run(bool createInputFile);
    }
}