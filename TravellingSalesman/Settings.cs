using System;
using System.Globalization;
using System.Windows.Forms;
using MiniMax.Forms;

namespace TravellingSalesman
{
    public partial class Settings : Form
    {
        public Settings()
        {
            InitializeComponent();
        }

        public BuildChooseDialog CudaBuildChooseDialog { get; set; }

        public int NumberOfProcess
        {
            get { return Convert.ToInt32(numericUpDownNumberOfProcess.Value); }
            set { numericUpDownNumberOfProcess.Value = value; }
        }

        public int GridSize
        {
            get { return Convert.ToInt32(numericUpDownGridSize.Value); }
            set { numericUpDownGridSize.Value = value; }
        }

        public int BlockSize
        {
            get { return Convert.ToInt32(numericUpDownBlockSize.Value); }
            set { numericUpDownBlockSize.Value = value; }
        }

        public bool IsCudaEngine
        {
            get { return radioButtonCudaEngine.Checked; }
        }

        public bool IsMpiEngine
        {
            get { return radioButtonMpiEngine.Checked; }
        }

        public BuildChooseDialog MpiBuildChooseDialog { get; set; }

        private void ValueChanged(object sender, EventArgs e)
        {
            textBox1.Text = (GridSize*BlockSize).ToString(CultureInfo.InvariantCulture);
        }

        private void buttonCudaChoose_Click(object sender, EventArgs e)
        {
            if (CudaBuildChooseDialog.ShowDialog() != DialogResult.OK) return;
            MyLibrary.Collections.Properties values = CudaBuildChooseDialog.Values;
            if (values == null) return;
            GridSize = 1;
            BlockSize = Convert.ToInt32(values["N"]);
        }

        private void button3_Click(object sender, EventArgs e)
        {
            if (MpiBuildChooseDialog.ShowDialog() != DialogResult.OK) return;
            MyLibrary.Collections.Properties values = MpiBuildChooseDialog.Values;
            if (values == null) return;
            NumberOfProcess = Convert.ToInt32(values["P"]);
        }
    }
}