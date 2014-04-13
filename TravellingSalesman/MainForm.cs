using System;
using System.Drawing;
using System.Globalization;
using System.Linq;
using System.Windows.Forms;

namespace TravellingSalesman
{
    public partial class MainForm : Form
    {
        private readonly MatrixIO _dataGridViewManual = new MatrixIO
        {
            ColumnHeadersHeightSizeMode = DataGridViewColumnHeadersHeightSizeMode.AutoSize,
            Dock = DockStyle.Fill,
            Name = "dataGridViewManual",
            RowTemplate = {Height = 20},
            TabIndex = 0
        };

        private readonly Settings _settings = new Settings();

        public MainForm()
        {
            InitializeComponent();
            splitContainer1.Panel1.Controls.Add(_dataGridViewManual);
            timer1.Interval = 1000;
            timer1.Start();
        }

        private void settingsToolStripMenuItem_Click(object sender, EventArgs e)
        {
            if (_settings.ShowDialog() == DialogResult.OK)
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

        private async void runToolStripMenuItem_Click(object sender, EventArgs e)
        {
            ILittleAlgorithm algorithm;
            if (_settings.IsCudaEngine)
            {
                algorithm = new CudaLittleAlgorithm();
            }
            else if (_settings.IsMpiEngine)
            {
                algorithm = new MpiLittleAlgorithm(_settings.NumberOfProcess);
            }
            else
                throw new NotImplementedException();

            int n = 0;
            string[,] thedata = _dataGridViewManual.TheData;
            for (int i = 0; i < thedata.GetLength(0); i++)
                for (int j = 0; j < thedata.GetLength(1); j++)
                {
                    if (string.IsNullOrEmpty(thedata[i, j])) continue;
                    n = Math.Max(n, i);
                    n = Math.Max(n, j);
                }

            foreach (
                DataGridViewCell cell in
                    from DataGridViewRow row in _dataGridViewManual.Rows
                    from DataGridViewCell cell in row.Cells
                    select cell)
                cell.Style.BackColor = Color.Yellow;
            for (int i = 0; i < thedata.GetLength(0) && i < thedata.GetLength(1); i++)
                _dataGridViewManual.Rows[i].Cells[i].Style.BackColor = Color.Red;

            algorithm.Matrix = new string[n + 1, n + 1];
            for (int i = 0; i <= n; i++)
                for (int j = 0; j <= n; j++)
                    algorithm.Matrix[i, j] = thedata[i, j];
            int exitCode = await algorithm.Run();
            if (exitCode == 0)
            {
                foreach (var pair in algorithm.Solution)
                    _dataGridViewManual.Rows[Convert.ToInt32(pair[0])].Cells[Convert.ToInt32(pair[1])].Style.BackColor =
                        Color.Green;
            }
            textBox1.Text = algorithm.Log;
        }
    }
}