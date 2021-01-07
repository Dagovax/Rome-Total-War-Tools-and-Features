using System.Windows.Forms;
using System;

namespace RTWMultipleTurnsPerYear
{
    public partial class Main : Form
    {
        public Main()
        {
            InitializeComponent();
            m_EndYearComboBox.SelectedIndex = 1;
            m_StartYearComboBox.SelectedIndex = 0;
        }

        private void m_ContactLink_LinkClicked(object sender, LinkLabelLinkClickedEventArgs e)
        {
            //Contact requested
            Contact contact = new Contact();
            contact.ShowDialog();
        }

        private void m_StartYearInput_TextChanged(object sender, System.EventArgs e)
        {
            //disable dropdown event
            m_StartYearComboBox.SelectedIndexChanged -= m_StartYearComboBox_SelectedIndexChanged;

            //Change the visibility etc of other buttons and edit fields when this imput is empty
            if (m_StartYearInput.Text == string.Empty)
            {
                m_GenerateButton.Enabled = false;
                m_WinterTurnInput.Visible = false;
                m_WinterTurnLabel.Visible = false;
                m_CreateBackgroundscript.Visible = false;
            }
            else
            {
                if (m_TurnsInput.Text != string.Empty && m_EndYearInput.Text != string.Empty)
                {
                    m_GenerateButton.Enabled = true;
                    m_WinterTurnInput.Visible = true;
                    m_WinterTurnLabel.Visible = true;
                    m_CreateBackgroundscript.Visible = true;
                }
            }

            if (m_StartYearInput.Text.StartsWith("-"))
            {
                m_StartYearComboBox.SelectedIndex = 0;
            }
            else
            {
                m_StartYearComboBox.SelectedIndex = 1;
            }

            m_StartYearComboBox.SelectedIndexChanged += m_StartYearComboBox_SelectedIndexChanged;
        }

        private void m_EndYearInput_TextChanged(object sender, System.EventArgs e)
        {
            m_EndYearComboBox.SelectedIndexChanged -= m_EndYearComboBox_SelectedIndexChanged;

            //Check if starting year is empty. Otherwise, this should not be visible!
            if (m_StartYearInput.Text == string.Empty)
            {
                //This will activate the onchange event
                m_GenerateButton.Enabled = false;
            }

            if(m_EndYearInput.Text == string.Empty)
            {
                //turn off turn input
                m_WinterTurnInput.Visible = false;
                m_WinterTurnLabel.Visible = false;
                m_CreateBackgroundscript.Visible = false;
                m_GenerateButton.Enabled = false;
            }
            else
            {
                if (m_TurnsInput.Text != string.Empty && m_StartYearInput.Text != string.Empty)
                {
                    m_GenerateButton.Enabled = true;
                    m_WinterTurnInput.Visible = true;
                    m_WinterTurnLabel.Visible = true;
                    m_CreateBackgroundscript.Visible = true;
                }
            }

            if (m_EndYearInput.Text.StartsWith("-"))
            {
                m_EndYearComboBox.SelectedIndex = 0;
            }
            else
            {
                m_EndYearComboBox.SelectedIndex = 1;
            }

            m_EndYearComboBox.SelectedIndexChanged += m_EndYearComboBox_SelectedIndexChanged;
        }

        private void m_TurnsInput_TextChanged(object sender, EventArgs e)
        {
            //Check if starting year is empty. Otherwise, this should not be visible!
            if (m_StartYearInput.Text == string.Empty)
            {
                //This will activate the onchange event
                m_StartYearInput.Text = string.Empty;
            }
            else
            {
                if (m_TurnsInput.Text == string.Empty)
                {
                    m_WinterTurnInput.Visible = false;
                    m_WinterTurnLabel.Visible = false;
                    m_CreateBackgroundscript.Visible = false;
                    m_CreateBackgroundscript.Checked = false;
                    m_GenerateButton.Enabled = false;
                }
                else
                {
                    m_WinterTurnInput.Visible = true;
                    m_WinterTurnLabel.Visible = true;
                    m_CreateBackgroundscript.Visible = true;
                    m_GenerateButton.Enabled = true;
                    m_WinterTurnInput.Maximum = Int32.Parse(m_TurnsInput.Text);
                }
            }
        }

        private void m_WinterTurnInput_TextChanged(object sender, EventArgs e)
        {

        }

        private void m_StartYearInput_KeyPress(object sender, KeyPressEventArgs e)
        {
            if (!char.IsControl(e.KeyChar) && !char.IsDigit(e.KeyChar) && !(e.KeyChar == '-'))
            {
                e.Handled = true;
            }

            // only allow one decimal point at the beginning
            if ((e.KeyChar == '-') && ((sender as TextBox).Text.IndexOf('-') > -1))
            {
                e.Handled = true;
            }

            if ((e.KeyChar == '-') && (sender as TextBox).SelectionStart != 0)
            {
                e.Handled = true;
            }
        }

        private void m_EndYearInput_KeyPress(object sender, KeyPressEventArgs e)
        {
            if (!char.IsControl(e.KeyChar) && !char.IsDigit(e.KeyChar) && !(e.KeyChar == '-'))
            {
                e.Handled = true;
            }

            // only allow one decimal point at the beginning
            if ((e.KeyChar == '-') && ((sender as TextBox).Text.IndexOf('-') > -1))
            {
                e.Handled = true;
            }

            if ((e.KeyChar == '-') && (sender as TextBox).SelectionStart != 0)
            {
                e.Handled = true;
            }
        }

        private void m_TurnsInput_KeyPress(object sender, KeyPressEventArgs e)
        {
            if (!char.IsControl(e.KeyChar) && !char.IsDigit(e.KeyChar))
            {
                e.Handled = true;
            }
        }
        private void m_WinterTurnInput_KeyPress(object sender, KeyPressEventArgs e)
        {
            if (!char.IsControl(e.KeyChar) && !char.IsDigit(e.KeyChar))
            {
                e.Handled = true;
            }
        }

        private void m_WinterTurnInput_KeyDown(object sender, KeyEventArgs e)
        {

        }

        private void m_CreateBackgroundscript_CheckedChanged(object sender, EventArgs e)
        {
            m_ScriptNameLabel.Visible = m_CreateBackgroundscript.Checked;
            m_ScriptNameInput.Visible = m_CreateBackgroundscript.Checked;
        }

        private void m_GenerateButton_Click(object sender, System.EventArgs e)
        {
            Int32 m_StartYear = Int32.Parse(m_StartYearInput.Text);
            Int32 m_EndYear = Int32.Parse(m_EndYearInput.Text);
            Int32 m_Turns = Int32.Parse(m_TurnsInput.Text);
            Int32 m_WinterAmount = Int32.Parse(m_WinterTurnInput.Text);
            String m_BackgroundScriptName = m_ScriptNameInput.Text;

            //Check if end year is later then start year
            if(m_StartYear > m_EndYear)
            {
                MessageBox.Show("End year can not be earlier than the start year!\n\nChange the dates please");
                m_EndYearInput.Focus();
                m_EndYearInput.SelectAll();
            }
            else if (m_CreateBackgroundscript.Checked && m_ScriptNameInput.Text == string.Empty)
            {
                MessageBox.Show("Enter a name to be used in the background script!");
                m_ScriptNameInput.Focus();
                m_ScriptNameInput.SelectAll();
            }
            else if ((Int32)(m_WinterTurnInput.Value) > Int32.Parse(m_TurnsInput.Text))
            {
                MessageBox.Show("Amount of winter turns can not be higher than the maximum turns in a year!");
                m_WinterTurnInput.Focus();
            }
            else
            {
                //Generate the script, use the generator dialog
                Generator m_Generator = new Generator(m_StartYear, m_EndYear, m_Turns, m_WinterAmount, m_CreateBackgroundscript.Checked, m_ScriptNameInput.Text);
                m_Generator.Show();
                this.Hide();
                m_Generator.Refresh();
                m_Generator.FormClosed += M_Generator_FormClosed;
            }
        }

        private void M_Generator_FormClosed(object sender, FormClosedEventArgs e)
        {
            CloseApplication();
        }

        private void CloseApplication()
        {
            Application.Exit();
            Environment.Exit(0);
        }

        private void m_StartYearComboBox_SelectedIndexChanged(object sender, EventArgs e)
        {
            //Disable the input event
            m_StartYearInput.TextChanged -= m_StartYearInput_TextChanged;

            ComboBox combo = sender as ComboBox;
            if(combo.SelectedIndex == 0)
            {
                m_StartYearInput.Text = m_StartYearInput.Text.Insert(0, "-");
            }
            else
            {
                try
                {
                    m_StartYearInput.Text = m_StartYearInput.Text.Substring(1);
                } catch (ArgumentOutOfRangeException)
                {
                }
            }

            //enable event again
            m_StartYearInput.TextChanged += m_StartYearInput_TextChanged;
        }

        private void m_EndYearComboBox_SelectedIndexChanged(object sender, EventArgs e)
        {
            m_EndYearInput.TextChanged -= m_EndYearInput_TextChanged;

            ComboBox combo = sender as ComboBox;
            if(combo.SelectedIndex == 0)
            {
                m_EndYearInput.Text = m_EndYearInput.Text.Insert(0, "-");
            }
            else
            {
                try
                {
                    m_EndYearInput.Text = m_EndYearInput.Text.Substring(1);
                } catch (ArgumentOutOfRangeException)
                {
                }
            }
            m_EndYearInput.TextChanged += m_EndYearInput_TextChanged;
        }
    }
}
