using System.Collections.Generic;
using System.Threading.Tasks;

namespace TravellingSalesman
{
    public interface ILittleAlgorithm
    {
        string[,] Matrix { get; set; }
        string Log { get; set; }
        IList<string[]> Solution { get; set; }
        Task<int> Run();
    }
}