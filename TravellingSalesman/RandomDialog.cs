using System;
using System.Windows.Forms;

namespace TravellingSalesman
{
    public partial class RandomDialog : Form
    {
        public RandomDialog()
        {
            InitializeComponent();
        }

        public int MatrixRank
        {
            get { return Convert.ToInt32(numericUpDown1.Value); }
        }

        public int Probability
        {
            get { return Convert.ToInt32(trackBar1.Value); }
        }
    }
}