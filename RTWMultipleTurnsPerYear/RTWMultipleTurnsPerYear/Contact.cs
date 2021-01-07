using System;
using System.Windows.Forms;

namespace RTWMultipleTurnsPerYear
{
    public partial class Contact : Form
    {
        public Contact()
        {
            InitializeComponent();
        }

        private void m_MailButton_Click(object sender, EventArgs e)
        {
            //Open Mail
            System.Diagnostics.Process.Start("mailto:dagovax@gmail.com");
            this.Close();
        }

        private void m_ModDBButton_Click(object sender, EventArgs e)
        {
            //Go to moddb
            System.Diagnostics.Process.Start("https://www.moddb.com/members/dagovax");
            this.Close();
        }
    }
}
