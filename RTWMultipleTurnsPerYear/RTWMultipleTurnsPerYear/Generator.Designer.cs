namespace RTWMultipleTurnsPerYear
{
    partial class Generator
    {
        /// <summary>
        /// Required designer variable.
        /// </summary>
        private System.ComponentModel.IContainer components = null;

        /// <summary>
        /// Clean up any resources being used.
        /// </summary>
        /// <param name="disposing">true if managed resources should be disposed; otherwise, false.</param>
        protected override void Dispose(bool disposing)
        {
            if (disposing && (components != null))
            {
                components.Dispose();
            }
            base.Dispose(disposing);
        }

        #region Windows Form Designer generated code

        /// <summary>
        /// Required method for Designer support - do not modify
        /// the contents of this method with the code editor.
        /// </summary>
        private void InitializeComponent()
        {
            System.ComponentModel.ComponentResourceManager resources = new System.ComponentModel.ComponentResourceManager(typeof(Generator));
            this.m_ProgressBar = new System.Windows.Forms.ProgressBar();
            this.backgroundWorker = new System.ComponentModel.BackgroundWorker();
            this.m_GeneratingLabel = new System.Windows.Forms.Label();
            this.m_WorkLabel = new System.Windows.Forms.Label();
            this.SuspendLayout();
            // 
            // m_ProgressBar
            // 
            this.m_ProgressBar.Anchor = System.Windows.Forms.AnchorStyles.Bottom;
            this.m_ProgressBar.Location = new System.Drawing.Point(12, 86);
            this.m_ProgressBar.Name = "m_ProgressBar";
            this.m_ProgressBar.Size = new System.Drawing.Size(351, 23);
            this.m_ProgressBar.Step = 1;
            this.m_ProgressBar.Style = System.Windows.Forms.ProgressBarStyle.Continuous;
            this.m_ProgressBar.TabIndex = 0;
            // 
            // backgroundWorker
            // 
            this.backgroundWorker.WorkerReportsProgress = true;
            this.backgroundWorker.DoWork += new System.ComponentModel.DoWorkEventHandler(this.backgroundWorker_DoWork);
            this.backgroundWorker.ProgressChanged += new System.ComponentModel.ProgressChangedEventHandler(this.backgroundWorker_ProgressChanged);
            this.backgroundWorker.RunWorkerCompleted += new System.ComponentModel.RunWorkerCompletedEventHandler(this.backgroundWorker_RunWorkerCompleted);
            // 
            // m_GeneratingLabel
            // 
            this.m_GeneratingLabel.BackColor = System.Drawing.Color.Transparent;
            this.m_GeneratingLabel.FlatStyle = System.Windows.Forms.FlatStyle.Flat;
            this.m_GeneratingLabel.Location = new System.Drawing.Point(10, 61);
            this.m_GeneratingLabel.Name = "m_GeneratingLabel";
            this.m_GeneratingLabel.Size = new System.Drawing.Size(41, 21);
            this.m_GeneratingLabel.TabIndex = 1;
            this.m_GeneratingLabel.Text = "Status:";
            // 
            // m_WorkLabel
            // 
            this.m_WorkLabel.BackColor = System.Drawing.Color.Transparent;
            this.m_WorkLabel.FlatStyle = System.Windows.Forms.FlatStyle.Flat;
            this.m_WorkLabel.Location = new System.Drawing.Point(57, 61);
            this.m_WorkLabel.Name = "m_WorkLabel";
            this.m_WorkLabel.Size = new System.Drawing.Size(306, 21);
            this.m_WorkLabel.TabIndex = 2;
            // 
            // Generator
            // 
            this.AutoScaleDimensions = new System.Drawing.SizeF(6F, 13F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            this.BackColor = System.Drawing.SystemColors.ActiveCaption;
            this.ClientSize = new System.Drawing.Size(375, 121);
            this.Controls.Add(this.m_WorkLabel);
            this.Controls.Add(this.m_GeneratingLabel);
            this.Controls.Add(this.m_ProgressBar);
            this.FormBorderStyle = System.Windows.Forms.FormBorderStyle.FixedToolWindow;
            this.Icon = ((System.Drawing.Icon)(resources.GetObject("$this.Icon")));
            this.Name = "Generator";
            this.StartPosition = System.Windows.Forms.FormStartPosition.CenterScreen;
            this.Text = "Generating Script...";
            this.ResumeLayout(false);

        }

        #endregion

        private System.Windows.Forms.ProgressBar m_ProgressBar;
        private System.ComponentModel.BackgroundWorker backgroundWorker;
        private System.Windows.Forms.Label m_GeneratingLabel;
        private System.Windows.Forms.Label m_WorkLabel;
    }
}