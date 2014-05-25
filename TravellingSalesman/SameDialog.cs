using System;
using System.Windows.Forms;

namespace TravellingSalesman
{
    public partial class SameDialog : Form
    {
        public SameDialog()
        {
            InitializeComponent();
        }

        public int MatrixRank
        {
            get { return Convert.ToInt32(numericUpDown1.Value); }
        }
    }
}