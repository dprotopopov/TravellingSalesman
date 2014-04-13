using System.Windows.Forms;

namespace TravellingSalesman
{
    public partial class Settings : Form
    {
        public Settings()
        {
            InitializeComponent();
        }

        public Settings(int median, int noise, int sci)
            : this()
        {
        }

        public int NumberOfProcess
        {
            get { return (int) numericUpDownNumberOfProcess.Value; }
            set { numericUpDownNumberOfProcess.Value = value; }
        }

        public int VideoMemorySize
        {
            get { return (int) numericUpDownVideoMemorySize.Value; }
            set { numericUpDownVideoMemorySize.Value = value; }
        }

        public bool IsCudaEngine
        {
            get { return radioButtonCudaEngine.Checked; }
        }

        public bool IsMpiEngine
        {
            get { return radioButtonMpiEngine.Checked; }
        }
    }
}