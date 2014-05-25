using System;
using System.Diagnostics;
using System.IO;
using System.Linq;
using System.Text;
using System.Text.RegularExpressions;
using System.Threading.Tasks;

namespace TravellingSalesman.Floyd
{
    public abstract class FloydAlgorithm : Algorithm, IFloydAlgorithm
    {
        protected FloydAlgorithm()
        {
            InputFileName = Path.GetTempPath() + Guid.NewGuid() + ".csv";
            OutputFileName = Path.GetTempPath() + Guid.NewGuid() + ".csv";
            IntermedianFileName = Path.GetTempPath() + Guid.NewGuid() + ".csv";
            LogFileName = Path.GetTempPath() + Guid.NewGuid() + ".log";
        }

        public override async Task<int> Run(bool createInputFile)
        {
            if (!createInputFile) throw new NotImplementedException();

            using (StreamWriter writer = File.CreateText(InputFileName))
            {
                for (int i = 0; i < Matrix.GetLength(0); i++)
                    for (int j = 0; j < Matrix.GetLength(1); j++)
                    {
                        await writer.WriteAsync(Matrix[i, j]);
                        if (j < Matrix.GetLength(1) - 1) await writer.WriteAsync(";");
                        else await writer.WriteLineAsync();
                    }
                writer.Close();
            }

            Debug.WriteLine(Command);
            Process process = Process.Start("cmd", Command);

            if (process != null)
            {
                process.WaitForExit();
                if (process.ExitCode == 0)
                {
                    var regex = new Regex(@"\s*(?<data>\d*)\s*([;]|\Z)");
                    using (StreamReader reader = File.OpenText(OutputFileName))
                    {
                        int row = 0;
                        for (string line = await reader.ReadLineAsync();;
                            line = await reader.ReadLineAsync())
                        {
                            int col = 0;
                            foreach (
                                Match match in
                                    regex.Matches(line)
                                        .Cast<Match>()
                                        .Where(match => row < Matrix.GetLength(0) && col < Matrix.GetLength(1)))
                                Matrix[row, col++] = match.Groups["data"].Value;
                            if (reader.EndOfStream) break;
                            row++;
                        }
                        reader.Close();
                    }
                    using (StreamReader reader = File.OpenText(IntermedianFileName))
                    {
                        int row = 0;
                        for (string line = await reader.ReadLineAsync();;
                            line = await reader.ReadLineAsync())
                        {
                            int col = 0;
                            foreach (
                                Match match in
                                    regex.Matches(line)
                                        .Cast<Match>()
                                        .Where(match => row < Intermedian.GetLength(0) && col < Intermedian.GetLength(1))
                                )
                                Intermedian[row, col++] = match.Groups["data"].Value;
                            if (reader.EndOfStream) break;
                            row++;
                        }
                        reader.Close();
                    }
                }
            }
            using (StreamReader reader = File.OpenText(LogFileName))
            {
                var result = new char[reader.BaseStream.Length];
                await reader.ReadAsync(result, 0, (int) reader.BaseStream.Length);
                reader.Close();
                var sb = new StringBuilder();
                foreach (char ch in result)
                    sb.Append(ch);
                Log = sb.ToString();
            }
            return process != null ? process.ExitCode : -1;
        }
    }
}