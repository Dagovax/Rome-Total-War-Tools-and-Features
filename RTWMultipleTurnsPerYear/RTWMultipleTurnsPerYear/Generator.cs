using System;
using System.ComponentModel;
using System.Windows.Forms;

namespace RTWMultipleTurnsPerYear
{
    public partial class Generator : Form
    {
        private Int32 m_StartDate { get; set; }
        private Int32 m_EndDate { get; set; }
        private Int32 m_Turns { get; set; }
        private Int32 m_WinterTurns { get; set; }
        private Boolean m_CreateBackgroundscript { get; set; }
        private String m_ScriptName { get; set; }
        private Boolean m_MonitorEvent { get; set; }


    public Generator(int start, int end, int turns, int winter, bool script, string name, bool monitorEvent)
        {
            m_StartDate = start;
            m_EndDate = end;
            m_Turns = turns;
            m_WinterTurns = winter;
            m_CreateBackgroundscript = script;
            m_ScriptName = Utils.RemoveSpacesAndFirstCharUp(name);
            m_MonitorEvent = monitorEvent;

            InitializeComponent();
            backgroundWorker.RunWorkerAsync();
        }

        private void backgroundWorker_DoWork(object sender, DoWorkEventArgs e)
        {
            try
            {
                //Do all the work!

                //First set title label
                backgroundWorker.ReportProgress(1);
                System.Threading.Thread.Sleep(500);
                backgroundWorker.ReportProgress(2);
                System.Threading.Thread.Sleep(500);
                backgroundWorker.ReportProgress(3);
                System.Threading.Thread.Sleep(500);
                backgroundWorker.ReportProgress(4);
                System.Threading.Thread.Sleep(500);

                //Check folders and files
                if (!m_CreateBackgroundscript)
                {
                    //Skip a lot of steps and create the standard file
                    backgroundWorker.ReportProgress(80);
                    System.Threading.Thread.Sleep(1000);
                    Utils.CreateStandardScriptFile(m_StartDate, m_EndDate, m_Turns, m_WinterTurns, m_MonitorEvent);
                    backgroundWorker.ReportProgress(90);
                    System.Threading.Thread.Sleep(1500);
                }
                else
                {
                    //Create backgroundscript and needed files
                    backgroundWorker.ReportProgress(10);
                    System.Threading.Thread.Sleep(2000);

                    //Create folders if exists
                    Utils.CheckOrCreateScriptFolder();
                    backgroundWorker.ReportProgress(15);
                    System.Threading.Thread.Sleep(500);

                    //Create advice files
                    backgroundWorker.ReportProgress(25);
                    Utils.CreateAdviceFiles();
                    System.Threading.Thread.Sleep(1500);

                    //Write advice data
                    backgroundWorker.ReportProgress(30);
                    Utils.WriteAdviceDataIntoAdviceFiles(m_ScriptName);
                    System.Threading.Thread.Sleep(1500);

                    //Create the script itself
                    backgroundWorker.ReportProgress(95);
                    Utils.CreateBackgroundScriptFile(m_ScriptName, m_StartDate, m_EndDate, m_Turns, m_WinterTurns, m_MonitorEvent);
                    System.Threading.Thread.Sleep(2000);
                }

                //open file/folder
                Utils.OpenGeneratedScriptLocation(m_CreateBackgroundscript, m_Turns);
                backgroundWorker.ReportProgress(99);
                System.Threading.Thread.Sleep(1000);

                //work done!
                backgroundWorker.ReportProgress(100);
            } catch (Exception er)
            {
                Utils.SendMailWithError(er.Message, er.ToString());
                MessageBox.Show("An unexpected error occured. Try running the program as administrator.\n\nA mail containing the error was sent to the developer \nso he is aware of the problem.");
                this.Close();
            }
        }

        private void backgroundWorker_ProgressChanged(object sender, ProgressChangedEventArgs e)
        {
            //Handle progress
            switch (e.ProgressPercentage)
            {
                case 1:
                    m_WorkLabel.Text = "Changed the start year to " + m_StartDate.ToString();
                    break;
                case 2:
                    m_WorkLabel.Text = "Changed the end year to " + m_EndDate.ToString();
                    break;
                case 3:
                    m_WorkLabel.Text = "Set the amount of turns to be used to " + m_Turns.ToString();
                    break;
                case 4:
                    m_WorkLabel.Text = "Set the use of winter to " + m_WinterTurns.ToString();
                    break;

                //Backgroundscript specific
                case 10:
                    m_WorkLabel.Text = "Setting up task to create backgroundscript files...";
                    break;
                case 15:
                    m_WorkLabel.Text = "Created needed directories";
                    break;
                case 25:
                    m_WorkLabel.Text = "Creating export_descr_advice files...";
                    break;
                case 30:
                    m_WorkLabel.Text = "Writing advice data into files...";
                    break;

                //Standard script specific
                case 80:
                    m_WorkLabel.Text = "Skipping unwanted tasks...";
                    break;
                case 90:
                    m_WorkLabel.Text = "Created standard script file named '" + (m_Turns.ToString() + "_turns_per_year_script.txt'");
                    break;
                case 95:
                    m_WorkLabel.Text = "Creating backgroundscript located in scripts/show_me folder...";
                    break;

                case 99:
                    m_WorkLabel.Text = "Opening script or folder location...";
                    break;
                case 100:
                    m_WorkLabel.Text = "All Done!";
                    break;
                default:
                    m_WorkLabel.Text = "Current completed work is " + e.ProgressPercentage + "%";
                    break;
            }

            m_ProgressBar.Value = e.ProgressPercentage;
        }

        private void backgroundWorker_RunWorkerCompleted(object sender, RunWorkerCompletedEventArgs e)
        {
            //When the backgroundworker is completed
            this.Close();
        }
    }
}
