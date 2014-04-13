﻿using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.IO;
using System.Text;
using System.Text.RegularExpressions;
using System.Threading.Tasks;

namespace TravellingSalesman
{
    public abstract class LittleAlgorithm : ILittleAlgorithm
    {
        public abstract string Command { get; }
        public string InputFileName { get; set; }
        public string OutputFileName { get; set; }
        public string ExeFileName { get; set; }
        public string LogFileName { get; set; }
        public string[,] Matrix { get; set; }
        public string Log { get; set; }
        public IList<string[]> Solution { get; set; }

        public async Task<int> Run()
        {
            InputFileName = Path.GetTempPath() + Guid.NewGuid() + ".csv";
            OutputFileName = Path.GetTempPath() + Guid.NewGuid() + ".csv";
            LogFileName = Path.GetTempPath() + Guid.NewGuid() + ".log";
            Solution = new List<string[]>();

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
                    using (StreamReader reader = File.OpenText(OutputFileName))
                    {
                        var regex = new Regex(@"\s*(?<from>\d+)\s*;\s*(?<to>\d+)\s*");
                        for (string line = await reader.ReadLineAsync();
                            true;
                            line = await reader.ReadLineAsync())
                        {
                            Match match = regex.Match(line);
                            Solution.Add(new[] {match.Groups["from"].Value, match.Groups["to"].Value});
                            if (reader.EndOfStream) break;
                        }
                        reader.Close();
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