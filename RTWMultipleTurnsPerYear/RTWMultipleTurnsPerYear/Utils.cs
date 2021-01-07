using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.Globalization;
using System.IO;
using System.Management;
using System.Net.Mail;

namespace RTWMultipleTurnsPerYear
{
    public static class Utils
    {
        private static readonly String m_StartupPath = Path.Combine(AppDomain.CurrentDomain.BaseDirectory, ("RTW_XTurnsPerYear/"+ DateTime.Now.ToString("ddd MM.dd.yyyy 'at' HH.mm") + "/data"));
        private static readonly String m_ScriptPath = Path.Combine(m_StartupPath, "scripts/show_me");
        private static readonly String m_ExportDescrAdviceFile = Path.Combine(m_StartupPath, "export_descr_advice.txt");
        private static readonly String m_ExportDescrAdviceEnumsFile = Path.Combine(m_StartupPath, "export_descr_advice_enums.txt");
        private static readonly String m_TextAdviceFile = Path.Combine(m_StartupPath, "text/export_advice.txt");

        public static void CheckOrCreateScriptFolder()
        {
            if (!Directory.Exists(m_ScriptPath))
            {
                Directory.CreateDirectory(m_ScriptPath);
            }
            if (!Directory.Exists(Path.Combine(m_StartupPath, "text")))
            {
                Directory.CreateDirectory(Path.Combine(m_StartupPath, "text"));
            }
        }

        public static void CreateStandardScriptFile(Int32 m_StartYear, Int32 m_EndYear, Int32 m_Turns, Int32 m_UseWinter)
        {
            using (StreamWriter sw = File.CreateText(Path.Combine(AppDomain.CurrentDomain.BaseDirectory, (m_Turns.ToString()+"_turns_per_year_script.txt"))))
            {
                sw.WriteLine(";;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;");
                sw.WriteLine(";;; Generated with Dagovax's Turns Per Year Script Generator ;;;");
                sw.WriteLine(";;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;");
                sw.WriteLine();
                CreateTurnsPerYearScript(sw, m_StartYear, m_EndYear, m_Turns, m_UseWinter);
            }
        }

        public static void CreateBackgroundScriptFile(String m_CampaignName, Int32 m_StartYear, Int32 m_EndYear, Int32 m_Turns, Int32 m_UseWinter)
        {
            using (StreamWriter sw = File.CreateText(Path.Combine(m_ScriptPath, m_CampaignName + "_Background_Script.txt")))
            {
                sw.WriteLine(";;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;");
                sw.WriteLine(";;; Generated with Dagovax's Turns Per Year Script Generator ;;;");
                sw.WriteLine(";;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;");
                sw.WriteLine();
                sw.WriteLine("script");
                sw.WriteLine();
                sw.WriteLine("\twait 1");
                sw.WriteLine("\tselect_ui_element advisor_dismiss_button");
                sw.WriteLine("\tsimulate_mouse_click lclick_up");
                sw.WriteLine();
                sw.WriteLine("\tdeclare_show_me");
                sw.WriteLine();
                sw.WriteLine("\tmonitor_event GameReloaded TrueCondition");
                sw.WriteLine("\t\tterminate_script");
                sw.WriteLine("\tend_monitor");
                sw.WriteLine();
                sw.WriteLine(";*****************************");
                sw.WriteLine(";** ADD OWN MONITORS BELOW: **");
                sw.WriteLine(";*****************************");
                sw.WriteLine();
                sw.WriteLine();
                CreateTurnsPerYearScript(sw, m_StartYear, m_EndYear, m_Turns, m_UseWinter);
                sw.WriteLine();
                sw.WriteLine("end_script");
            }
        }

        public static void CreateAdviceFiles()
        {
            try
            {
                //Create the advice files after the directories are completed
                CreateFileAndHeader(m_ExportDescrAdviceFile);
                CreateFileAndHeader(m_ExportDescrAdviceEnumsFile);
                CreateFileAndHeader(m_TextAdviceFile);

            } catch (Exception)
            {
            }
        }

        public static void WriteAdviceDataIntoAdviceFiles(String m_Name)
        {
            String m_ThreadName = m_Name + "_Background_Script";
            String m_Title = m_Name + "_Background_Script_Text_01_Title";
            String m_Text = m_Name + "_Background_Script_Text_01_Text";

            //Write to export_descr_advice.txt
            using (StreamWriter sw = File.AppendText(m_ExportDescrAdviceFile))
            {
                sw.WriteLine();
                sw.WriteLine(";***********************************");
                sw.WriteLine(";** ADD TO ADVICE THREAD SECTION: **");
                sw.WriteLine(";************************************");
                sw.WriteLine();
                sw.WriteLine(";------------------------------------------");
                sw.WriteLine("AdviceThread " + m_ThreadName + "_Thread");
                sw.WriteLine("\t\tGameArea Campaign");
                sw.WriteLine();
                sw.WriteLine("\t\tItem " + m_ThreadName + "_Text_01");
                sw.WriteLine("\t\t\t\tUninhibitable");
                sw.WriteLine("\t\t\t\tVerbosity  0");
                sw.WriteLine("\t\t\t\tThreshold  2");
                sw.WriteLine("\t\t\t\tAttitude Excited");
                sw.WriteLine("\t\t\t\tPresentation Default");
                sw.WriteLine("\t\t\t\tTitle " + m_Title);
                sw.WriteLine("\t\t\t\tOn_display " + @"scripts\show_me\" + m_ThreadName+".txt");
                sw.WriteLine("\t\t\t\tText " + m_Text);
                sw.WriteLine();
                sw.WriteLine();
                sw.WriteLine(";*****************************");
                sw.WriteLine(";** ADD TO TRIGGER SECTION: **");
                sw.WriteLine(";*****************************");
                sw.WriteLine();
                sw.WriteLine(";------------------------------------------");
                sw.WriteLine("Trigger "+ m_ThreadName+ "_Tigger_1");
                sw.WriteLine("\tWhenToTest ButtonPressed");
                sw.WriteLine();
                sw.WriteLine("\tAdviceThread " + m_ThreadName + "_Thread  1");
                sw.WriteLine();
                sw.WriteLine(";------------------------------------------");
                sw.WriteLine("Trigger " + m_ThreadName + "_Tigger_2");
                sw.WriteLine("\tWhenToTest CharacterSelected");
                sw.WriteLine();
                sw.WriteLine("\tAdviceThread " + m_ThreadName + "_Thread  1");
                sw.WriteLine();
                sw.WriteLine(";------------------------------------------");
                sw.WriteLine("Trigger " + m_ThreadName + "_Tigger_3");
                sw.WriteLine("\tWhenToTest SettlementSelected");
                sw.WriteLine();
                sw.WriteLine("\tAdviceThread " + m_ThreadName + "_Thread  1");
                sw.WriteLine();
                sw.WriteLine(";------------------------------------------");
                sw.WriteLine("Trigger " + m_ThreadName + "_Tigger_4");
                sw.WriteLine("\tWhenToTest ShortcutTriggered");
                sw.WriteLine();
                sw.WriteLine("\tAdviceThread " + m_ThreadName + "_Thread  1");
                sw.WriteLine();
                sw.WriteLine(";------------------------------------------");
                sw.WriteLine("Trigger " + m_ThreadName + "_Tigger_Reload");
                sw.WriteLine("\tWhenToTest GameReloaded");
                sw.WriteLine();
                sw.WriteLine("\tAdviceThread " + m_ThreadName + "_Thread  0");
                sw.WriteLine();
                sw.WriteLine(";------------------------------------------");
            }

            //Write to export_descr_advice_enums.txt
            using (StreamWriter sw = File.AppendText(m_ExportDescrAdviceEnumsFile))
            {
                sw.WriteLine();
                sw.WriteLine(m_Title);
                sw.WriteLine(m_Text);
                sw.WriteLine();
            }

            //Write to text/export_advice.txt
            using (StreamWriter sw = File.AppendText(m_TextAdviceFile))
            {
                sw.WriteLine("¬-------------------");
                sw.WriteLine();
                sw.WriteLine("{" + m_Title + "}\t\t" + "Background Script Launched");
                sw.WriteLine();
                sw.WriteLine("{" + m_Text + "}\t\t" + "Background script has automatically launched, click 'X' to dismiss this message.");
                sw.WriteLine();
                sw.WriteLine("¬-------------------");
            }

        }

        public static void CreateFileAndHeader(String m_File)
        {
            using (StreamWriter sw = File.CreateText(m_File))
            {
                sw.WriteLine(";;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;");
                sw.WriteLine(";;; Generated with Dagovax's Turns Per Year Script Generator ;;;");
                sw.WriteLine(";;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;");
                sw.WriteLine();
                sw.WriteLine(";*********************************************************");
                sw.WriteLine(";** COPY THE CONTENT BELOW TO YOUR MOD'S EPONYMOUS FILE **");
                sw.WriteLine(";*********************************************************");
                sw.WriteLine();
                sw.WriteLine();
            }
        }

        public static void CreateTurnsPerYearScript(StreamWriter sw, Int32 m_StartYear, Int32 m_EndYear, Int32 m_Turns, Int32 m_UseWinter)
        {
            Int32 m_TotalTurns = -1;
            Int32 m_CurrentTurn = 0;
            Int32 m_HalfWinter1 = (Int32)Math.Ceiling((decimal)m_UseWinter / 2);
            Int32 m_HalfWinter2 = (Int32)Math.Floor((decimal)m_UseWinter / 2);

            //Int32 m_HalfTurns = m_Turns / 2;
            //Not used anymore
            //Int32 m_WinterTurns = (Int32)Math.Floor((double)(m_HalfTurns / 3));

            //Set total turns
            for (int i = m_StartYear; i <= m_EndYear; i++)
            {
                m_TotalTurns += m_Turns;
            }

            //Set turns which should be winter in list
            List<Int32> m_WinterTurnList = new List<Int32>();
            Int32 m_WinterCounter = 0;

            //set the items for turns with 1, 2, 3 or 4 turns per year
            for (int i = 0; i < m_Turns; i++)
            {
                if(m_WinterCounter < m_UseWinter)
                {
                    if (i < m_HalfWinter2)
                    {
                        m_WinterTurnList.Add(i);
                        m_WinterCounter++;
                    }
                    if (i > (m_Turns -1 - m_HalfWinter1))
                    {
                        m_WinterTurnList.Add(i);
                        m_WinterCounter++;
                    }
                }
            }

            sw.WriteLine(";*************************************************");
            sw.WriteLine("; "+ m_Turns.ToString() + " turns per year script:");
            sw.WriteLine("; starting year: " + m_StartYear.ToString() + " | ending year: " + m_EndYear.ToString());
            if (m_UseWinter != 0)
            {
                if (m_Turns == 1)
                {
                    sw.WriteLine("; all turns are set to winter");
                }
                else
                {
                    sw.WriteLine("; amount of winter turns per year: " + m_WinterTurnList.Count.ToString());
                }
            }
            sw.WriteLine(";*************************************************");
            sw.WriteLine();

            //Starting while
            sw.WriteLine("while I_TurnNumber < "+(m_TotalTurns +1).ToString());
            sw.WriteLine();
            sw.WriteLine("\tsuspend_during_battle on");
            sw.WriteLine();

            //loop through all turns
            for (int i = m_StartYear; i <= m_EndYear; i++)
            {
                for (int j = 0; j < m_Turns; j++)
                {
                    sw.WriteLine("\tconsole_command date "+i);
                    //check if it needs to be summer or winter
                    if (m_UseWinter != 0)
                    {
                        if (m_WinterTurnList.Contains(j))
                        {
                            sw.WriteLine("\tconsole_command season winter");
                        }
                        else
                        {
                            sw.WriteLine("\tconsole_command season summer");
                        }
                    }
                    else
                    {
                        sw.WriteLine("\tconsole_command season summer");
                    }

                    //add extra slave turn check
                    if(j == m_Turns - 2)
                    {
                        sw.WriteLine("\tmonitor_event FactionTurnEnd FactionType slave");
                        sw.WriteLine("\t\tif I_Turnnumber = " + m_CurrentTurn);
                        sw.WriteLine("\t\t\tconsole_command season summer");
                        sw.WriteLine("\t\tend_if");
                        sw.WriteLine("\tterminate_monitor");
                        sw.WriteLine("\tend_monitor");
                    }

                    sw.WriteLine("\twhile I_TurnNumber = "+ m_CurrentTurn);
                    sw.WriteLine("\tend_while");
                    sw.WriteLine();
                    m_CurrentTurn++;
                }
            }

            //end the while
            sw.WriteLine("\tselect_ui_element advisor_dismiss_button");
            sw.WriteLine("\tsimulate_mouse_click lclick_up");
            sw.WriteLine();
            sw.WriteLine("end_while");
            sw.WriteLine();
            sw.WriteLine(";*************************************************");
        }

        public static String RemoveSpacesAndFirstCharUp(String m_Input)
        {
            String m_Result = m_Input.Replace(' ', '_');
            m_Result.ToLower();

            // Creates a TextInfo based on the "en-US" culture.
            TextInfo textInfo = new CultureInfo("en-US", false).TextInfo;
            m_Result = textInfo.ToTitleCase(m_Result);

            return m_Result;
        }

        public static void OpenGeneratedScriptLocation(Boolean m_BackgroundScript, Int32 m_Turns)
        {
            //
            if (m_BackgroundScript)
            {
                //open location of folderpath created
                Process.Start(m_StartupPath);
            }
            else
            {
                //open the script itself
                Process.Start(Path.Combine(AppDomain.CurrentDomain.BaseDirectory, m_Turns.ToString() + "_turns_per_year_script.txt"));
            }
        }

        public static string GetAppVersion()
        {
            string version = System.Reflection.Assembly.GetExecutingAssembly().GetName().Version.ToString();
            if (version == "" || version == null)
            {
                return "";
            }
            return "Version: " + version;
        }

        public static string GetOSVersion()
        {
            string r = "";
            using (ManagementObjectSearcher searcher = new ManagementObjectSearcher("SELECT * FROM Win32_OperatingSystem"))
            {
                ManagementObjectCollection information = searcher.Get();
                if (information != null)
                {
                    foreach (ManagementObject obj in information)
                    {
                        r = obj["Caption"].ToString() + " - " + obj["OSArchitecture"].ToString();
                    }
                }
                r = r.Replace("NT 5.1.2600", "XP");
                r = r.Replace("NT 5.2.3790", "Server 2003");
                return r;
            }
        }

        public static void SendMailWithError(string m_Task, string m_Errorcontent)
        {
            MailMessage mail = new MailMessage();
            SmtpClient SmtpServer = new SmtpClient("smtp.gmail.com");

            //create the body of the error mail with current app build etc
            string body = "An unexpected error occurred in the RTW Multiple Turns Per Year tool that could not be resolved.The error occured whit the message '<b><i>" + m_Task + "</i></b>'.<br/>See the log below with the error information.<br/><br/>" +
                "<b>App details:</b><br/>"
                + GetAppVersion() + " on " + GetOSVersion() +
                "<br/><br/>" +
                "<b>Error</b><br/>" + "[" + DateTime.Now.ToShortDateString() + " at " + DateTime.Now.ToLongTimeString() + "]" + " " + m_Errorcontent +
                "<br/><br/>";

            mail.From = new MailAddress("noreply.dagovaxgames@gmail.com");
            mail.To.Add("dagovax@gmail.com");
            mail.Subject = "RTW Multiple Turns Per Year - Error";
            mail.IsBodyHtml = true;
            mail.Body = body;

            SmtpServer.Port = 587;
            SmtpServer.Credentials = new System.Net.NetworkCredential("noreply.dagovaxgames@gmail.com", "NoReply123!");
            SmtpServer.EnableSsl = true;

            SmtpServer.Send(mail);
        }
    }
}
