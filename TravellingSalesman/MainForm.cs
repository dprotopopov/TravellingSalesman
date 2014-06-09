using System;
using System.Drawing;
using System.Globalization;
using System.Linq;
using System.Windows.Forms;
using MiniMax.Forms;
using MyFormula;
using MyLibrary.Collections;
using TravellingSalesman.Cuda;
using TravellingSalesman.Floyd;
using TravellingSalesman.Little;
using TravellingSalesman.Mpi;

namespace TravellingSalesman
{
    public partial class MainForm : Form
    {
        private static readonly Random Rnd = new Random();

        private static readonly BuildChooseDialog CudaBuildChooseDialog =
            new BuildChooseDialog(typeof (MyCudaNvidiaFormula));

        private static readonly BuildChooseDialog MpiBuildChooseDialog =
            new BuildChooseDialog(typeof (MyMpiFormula));

        private static readonly RandomDialog RandomDialog = new RandomDialog();
        private static readonly SameDialog SameDialog = new SameDialog();

        private static readonly Settings Settings = new Settings
        {
            CudaBuildChooseDialog = CudaBuildChooseDialog,
            MpiBuildChooseDialog = MpiBuildChooseDialog,
        };

        private readonly MatrixIO _dataGridViewIntermedian = new MatrixIO
        {
            ColumnHeadersHeightSizeMode = DataGridViewColumnHeadersHeightSizeMode.AutoSize,
            Dock = DockStyle.Fill,
            Name = "dataGridViewIntermedian",
            RowTemplate = {Height = 20},
            TabIndex = 0
        };

        private readonly MatrixIO _dataGridViewMatrix = new MatrixIO
        {
            ColumnHeadersHeightSizeMode = DataGridViewColumnHeadersHeightSizeMode.AutoSize,
            Dock = DockStyle.Fill,
            Name = "dataGridViewMatrix",
            RowTemplate = {Height = 20},
            TabIndex = 0
        };

        public MainForm()
        {
            InitializeComponent();
            tabPage1.Controls.Add(_dataGridViewMatrix);
            tabPage2.Controls.Add(_dataGridViewIntermedian);
            timer1.Interval = 1000;
            timer1.Start();
        }

        private void settingsToolStripMenuItem_Click(object sender, EventArgs e)
        {
            if (Settings.ShowDialog() == DialogResult.OK)
            {
                // good
            }
        }

        private void timer1_Tick(object sender, EventArgs e)
        {
            toolStripLabel1.Text = DateTime.Now.ToString(CultureInfo.InvariantCulture);
        }

        private void exitToolStripMenuItem_Click(object sender, EventArgs e)
        {
            Close();
        }

        private async void runLittleToolStripMenuItem_Click(object sender, EventArgs e)
        {
            ILittleAlgorithm little;
            if (Settings.IsCudaEngine)
            {
                little = new CudaLittleAlgorithm(Settings.GridSize, Settings.BlockSize);
                textBox1.Text = Settings.CudaBuildChooseDialog.ToString();
            }
            else if (Settings.IsMpiEngine)
            {
                little = new MpiLittleAlgorithm(Settings.NumberOfProcess);
                textBox1.Text = Settings.MpiBuildChooseDialog.ToString();
            }
            else
                throw new NotImplementedException();

            int n = 0;
            string[,] matrix = _dataGridViewMatrix.TheData;
            string[,] intermedian = _dataGridViewIntermedian.TheData;
            for (int i = 0; i < matrix.GetLength(0); i++)
                for (int j = 0; j < matrix.GetLength(1); j++)
                {
                    if (string.IsNullOrEmpty(matrix[i, j])) continue;
                    n = Math.Max(n, i);
                    n = Math.Max(n, j);
                }

            little.Matrix = new string[n + 1, n + 1];
            for (int i = 0; i <= n; i++)
                for (int j = 0; j <= n; j++)
                    little.Matrix[i, j] = matrix[i, j];

            foreach (
                DataGridViewCell cell in
                    from DataGridViewRow row in _dataGridViewMatrix.Rows
                    from DataGridViewCell cell in row.Cells
                    select cell)
                cell.Style.BackColor = Color.Yellow;
            for (int i = 0; i < matrix.GetLength(0) && i < matrix.GetLength(1); i++)
                _dataGridViewMatrix.Rows[i].Cells[i].Style.BackColor = Color.Red;

            DateTime start = DateTime.Now;
            int exitCode = await little.Run(true);
            DateTime end = DateTime.Now;

            if (exitCode == 0)
            {
                foreach (var pair in little.Solution)
                    _dataGridViewMatrix.Rows[Convert.ToInt32(pair[0])].Cells[Convert.ToInt32(pair[1])].Style.BackColor =
                        Color.Green;
                var pairs = new StackListQueue<string[]>(little.Solution);
                for (int i = 0; i < pairs.Count();)
                {
                    string[] pair = pairs.ElementAt(i);
                    string s = intermedian[Convert.ToInt32(pair[0]), Convert.ToInt32(pair[1])];
                    if (!string.IsNullOrEmpty(s))
                    {
                        pairs.Insert(i, new[] {s, pair[1]});
                        pairs.Insert(i, new[] {pair[0], s});
                        pairs.RemoveAt(i + 2);
                    }
                    else i++;
                }
                textBox2.Text = string.Join(Environment.NewLine,
                    pairs.Select(p => string.Format("({0},{1})", p[0], p[1])));
            }
            textBox1.AppendText(little.Log);
            var timeSpan = new TimeSpan(end.Ticks - start.Ticks);
            MessageBox.Show(timeSpan.ToString());
        }

        private void randomToolStripMenuItem_Click(object sender, EventArgs e)
        {
            if (RandomDialog.ShowDialog() != DialogResult.OK) return;
            int n = RandomDialog.MatrixRank;
            int p = RandomDialog.Probability;
            var matrix = new string[n, n];
            var intermedian = new string[n, n];
            for (int i = 0; i < n; i++)
                for (int j = 0; j < n; j++)
                    if (i != j && Rnd.Next(100) <= p)
                        matrix[i, j] = Rnd.Next(Int32.MaxValue/(n*n*n)).ToString(CultureInfo.InvariantCulture);
            _dataGridViewMatrix.TheData = matrix;
            _dataGridViewIntermedian.TheData = intermedian;
        }

        private async void runFloydToolStripMenuItem_Click(object sender, EventArgs e)
        {
            IFloydAlgorithm floyd;
            if (Settings.IsCudaEngine)
            {
                floyd = new CudaFloydAlgorithm(Settings.GridSize, Settings.BlockSize);
                textBox1.Text = Settings.CudaBuildChooseDialog.ToString();
            }
            else if (Settings.IsMpiEngine)
            {
                floyd = new MpiFloydAlgorithm(Settings.NumberOfProcess);
                textBox1.Text = Settings.MpiBuildChooseDialog.ToString();
            }
            else
                throw new NotImplementedException();
            int n = 0;
            string[,] matrix = _dataGridViewMatrix.TheData;
            for (int i = 0; i < matrix.GetLength(0); i++)
                for (int j = 0; j < matrix.GetLength(1); j++)
                {
                    if (string.IsNullOrEmpty(matrix[i, j])) continue;
                    n = Math.Max(n, i);
                    n = Math.Max(n, j);
                }

            floyd.Matrix = new string[n + 1, n + 1];
            floyd.Intermedian = new string[n + 1, n + 1];

            for (int i = 0; i <= n; i++)
                for (int j = 0; j <= n; j++)
                    floyd.Matrix[i, j] = matrix[i, j];

            foreach (
                DataGridViewCell cell in
                    from DataGridViewRow row in _dataGridViewMatrix.Rows
                    from DataGridViewCell cell in row.Cells
                    select cell)
                cell.Style.BackColor = Color.Yellow;
            for (int i = 0; i < matrix.GetLength(0) && i < matrix.GetLength(1); i++)
                _dataGridViewMatrix.Rows[i].Cells[i].Style.BackColor = Color.Red;

            foreach (
                DataGridViewCell cell in
                    from DataGridViewRow row in _dataGridViewIntermedian.Rows
                    from DataGridViewCell cell in row.Cells
                    select cell)
                cell.Style.BackColor = Color.Yellow;
            for (int i = 0; i < matrix.GetLength(0) && i < matrix.GetLength(1); i++)
                _dataGridViewIntermedian.Rows[i].Cells[i].Style.BackColor = Color.Red;

            DateTime start = DateTime.Now;
            int exitCode = await floyd.Run(true);
            DateTime end = DateTime.Now;

            if (exitCode == 0)
            {
                _dataGridViewMatrix.TheData = floyd.Matrix;
                _dataGridViewIntermedian.TheData = floyd.Intermedian;
            }
            textBox1.AppendText(floyd.Log);
            var timeSpan = new TimeSpan(end.Ticks - start.Ticks);
            MessageBox.Show(timeSpan.ToString());
        }

        private async void runFloydLittleToolStripMenuItem_Click(object sender, EventArgs e)
        {
            IFloydAlgorithm floyd;
            ILittleAlgorithm little;
            if (Settings.IsCudaEngine)
            {
                floyd = new CudaFloydAlgorithm(Settings.GridSize, Settings.BlockSize);
                little = new CudaLittleAlgorithm(Settings.GridSize, Settings.BlockSize)
                {
                    InputFileName = floyd.OutputFileName
                };
                textBox1.Text = Settings.CudaBuildChooseDialog.ToString();
            }
            else if (Settings.IsMpiEngine)
            {
                floyd = new MpiFloydAlgorithm(Settings.NumberOfProcess);
                little = new MpiLittleAlgorithm(Settings.NumberOfProcess)
                {
                    InputFileName = floyd.OutputFileName
                };
                textBox1.Text = Settings.MpiBuildChooseDialog.ToString();
            }
            else
                throw new NotImplementedException();

            int n = 0;
            string[,] matrix = _dataGridViewMatrix.TheData;
            for (int i = 0; i < matrix.GetLength(0); i++)
                for (int j = 0; j < matrix.GetLength(1); j++)
                {
                    if (string.IsNullOrEmpty(matrix[i, j])) continue;
                    n = Math.Max(n, i);
                    n = Math.Max(n, j);
                }
            floyd.Matrix = new string[n + 1, n + 1];
            floyd.Intermedian = new string[n + 1, n + 1];

            for (int i = 0; i <= n; i++)
                for (int j = 0; j <= n; j++)
                    floyd.Matrix[i, j] = matrix[i, j];

            foreach (
                DataGridViewCell cell in
                    from DataGridViewRow row in _dataGridViewMatrix.Rows
                    from DataGridViewCell cell in row.Cells
                    select cell)
                cell.Style.BackColor = Color.Yellow;
            for (int i = 0; i < matrix.GetLength(0) && i < matrix.GetLength(1); i++)
                _dataGridViewMatrix.Rows[i].Cells[i].Style.BackColor = Color.Red;

            foreach (
                DataGridViewCell cell in
                    from DataGridViewRow row in _dataGridViewIntermedian.Rows
                    from DataGridViewCell cell in row.Cells
                    select cell)
                cell.Style.BackColor = Color.Yellow;
            for (int i = 0; i < matrix.GetLength(0) && i < matrix.GetLength(1); i++)
                _dataGridViewIntermedian.Rows[i].Cells[i].Style.BackColor = Color.Red;

            DateTime start = DateTime.Now;
            int exitCode = await floyd.Run(true);
            little.Matrix = floyd.Matrix;
            exitCode = exitCode == 0 ? await little.Run(false) : exitCode;
            DateTime end = DateTime.Now;

            if (exitCode == 0)
            {
                _dataGridViewMatrix.TheData = floyd.Matrix;
                _dataGridViewIntermedian.TheData = floyd.Intermedian;
                foreach (var pair in little.Solution)
                    _dataGridViewMatrix.Rows[Convert.ToInt32(pair[0])].Cells[Convert.ToInt32(pair[1])].Style.BackColor =
                        Color.Green;
                var pairs = new StackListQueue<string[]>(little.Solution);
                for (int i = 0; i < pairs.Count();)
                {
                    string[] pair = pairs.ElementAt(i);
                    string s = floyd.Intermedian[Convert.ToInt32(pair[0]), Convert.ToInt32(pair[1])];
                    if (!string.IsNullOrEmpty(s))
                    {
                        pairs.Insert(i, new[] {s, pair[1]});
                        pairs.Insert(i, new[] {pair[0], s});
                        pairs.RemoveAt(i + 2);
                    }
                    else i++;
                }
                textBox2.Text = string.Join(Environment.NewLine,
                    pairs.Select(p => string.Format("({0},{1})", p[0], p[1])));
            }
            textBox1.AppendText(floyd.Log);
            textBox1.AppendText(little.Log);
            var timeSpan = new TimeSpan(end.Ticks - start.Ticks);
            MessageBox.Show(timeSpan.ToString());
        }

        private void sameToolStripMenuItem_Click(object sender, EventArgs e)
        {
            if (SameDialog.ShowDialog() != DialogResult.OK) return;
            int n = SameDialog.MatrixRank;
            var matrix = new string[n, n];
            var intermedian = new string[n, n];
            for (int i = 0; i < n; i++)
                for (int j = 0; j < n; j++)
                    if (i != j)
                        matrix[i, j] = (1).ToString(CultureInfo.InvariantCulture);
            _dataGridViewMatrix.TheData = matrix;
            _dataGridViewIntermedian.TheData = intermedian;
        }
    }
}