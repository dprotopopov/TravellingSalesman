using System;
using System.Globalization;
using System.Windows.Forms;

namespace TravellingSalesman
{
    public partial class Settings : Form
    {
        public Settings()
        {
            InitializeComponent();
        }

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

        private void ValueChanged(object sender, EventArgs e)
        {
            textBox1.Text = (GridSize*BlockSize).ToString(CultureInfo.InvariantCulture);
        }
    }
}