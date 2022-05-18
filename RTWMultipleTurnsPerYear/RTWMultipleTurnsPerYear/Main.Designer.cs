namespace RTWMultipleTurnsPerYear
{
    partial class Main
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
      System.ComponentModel.ComponentResourceManager resources = new System.ComponentModel.ComponentResourceManager(typeof(Main));
      this.m_GenerateButton = new System.Windows.Forms.Button();
      this.m_ContactLink = new System.Windows.Forms.LinkLabel();
      this.m_StartYearInput = new System.Windows.Forms.TextBox();
      this.m_EndYearInput = new System.Windows.Forms.TextBox();
      this.m_StartYearLabel = new System.Windows.Forms.Label();
      this.m_EndYearLabel = new System.Windows.Forms.Label();
      this.m_StartYearComboBox = new System.Windows.Forms.ComboBox();
      this.m_EndYearComboBox = new System.Windows.Forms.ComboBox();
      this.m_TurnsLabel = new System.Windows.Forms.Label();
      this.m_TurnsInput = new System.Windows.Forms.TextBox();
      this.m_ScriptNameInput = new System.Windows.Forms.TextBox();
      this.m_ScriptNameLabel = new System.Windows.Forms.Label();
      this.m_CreateBackgroundscript = new System.Windows.Forms.CheckBox();
      this.m_WinterTurnLabel = new System.Windows.Forms.Label();
      this.m_WinterTurnInput = new System.Windows.Forms.NumericUpDown();
      this.m_MonitorEvent = new System.Windows.Forms.CheckBox();
      ((System.ComponentModel.ISupportInitialize)(this.m_WinterTurnInput)).BeginInit();
      this.SuspendLayout();
      // 
      // m_GenerateButton
      // 
      this.m_GenerateButton.Anchor = ((System.Windows.Forms.AnchorStyles)((System.Windows.Forms.AnchorStyles.Bottom | System.Windows.Forms.AnchorStyles.Left)));
      this.m_GenerateButton.Cursor = System.Windows.Forms.Cursors.Hand;
      this.m_GenerateButton.Enabled = false;
      this.m_GenerateButton.Font = new System.Drawing.Font("Calibri", 12F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
      this.m_GenerateButton.Location = new System.Drawing.Point(161, 167);
      this.m_GenerateButton.Name = "m_GenerateButton";
      this.m_GenerateButton.Size = new System.Drawing.Size(133, 28);
      this.m_GenerateButton.TabIndex = 0;
      this.m_GenerateButton.Text = "Generate";
      this.m_GenerateButton.UseVisualStyleBackColor = true;
      this.m_GenerateButton.Click += new System.EventHandler(this.m_GenerateButton_Click);
      // 
      // m_ContactLink
      // 
      this.m_ContactLink.AutoSize = true;
      this.m_ContactLink.BackColor = System.Drawing.Color.Transparent;
      this.m_ContactLink.Font = new System.Drawing.Font("Microsoft Sans Serif", 8.25F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
      this.m_ContactLink.LinkColor = System.Drawing.Color.Aqua;
      this.m_ContactLink.Location = new System.Drawing.Point(374, 9);
      this.m_ContactLink.Name = "m_ContactLink";
      this.m_ContactLink.Size = new System.Drawing.Size(44, 13);
      this.m_ContactLink.TabIndex = 1;
      this.m_ContactLink.TabStop = true;
      this.m_ContactLink.Text = "Contact";
      this.m_ContactLink.LinkClicked += new System.Windows.Forms.LinkLabelLinkClickedEventHandler(this.m_ContactLink_LinkClicked);
      // 
      // m_StartYearInput
      // 
      this.m_StartYearInput.Location = new System.Drawing.Point(90, 51);
      this.m_StartYearInput.Name = "m_StartYearInput";
      this.m_StartYearInput.Size = new System.Drawing.Size(68, 20);
      this.m_StartYearInput.TabIndex = 2;
      this.m_StartYearInput.Text = "270";
      this.m_StartYearInput.TextChanged += new System.EventHandler(this.m_StartYearInput_TextChanged);
      this.m_StartYearInput.KeyPress += new System.Windows.Forms.KeyPressEventHandler(this.m_StartYearInput_KeyPress);
      // 
      // m_EndYearInput
      // 
      this.m_EndYearInput.Location = new System.Drawing.Point(90, 77);
      this.m_EndYearInput.Name = "m_EndYearInput";
      this.m_EndYearInput.Size = new System.Drawing.Size(68, 20);
      this.m_EndYearInput.TabIndex = 3;
      this.m_EndYearInput.Text = "14";
      this.m_EndYearInput.TextChanged += new System.EventHandler(this.m_EndYearInput_TextChanged);
      this.m_EndYearInput.KeyPress += new System.Windows.Forms.KeyPressEventHandler(this.m_EndYearInput_KeyPress);
      // 
      // m_StartYearLabel
      // 
      this.m_StartYearLabel.AutoSize = true;
      this.m_StartYearLabel.BackColor = System.Drawing.Color.Transparent;
      this.m_StartYearLabel.ForeColor = System.Drawing.Color.White;
      this.m_StartYearLabel.Location = new System.Drawing.Point(27, 54);
      this.m_StartYearLabel.Name = "m_StartYearLabel";
      this.m_StartYearLabel.RightToLeft = System.Windows.Forms.RightToLeft.No;
      this.m_StartYearLabel.Size = new System.Drawing.Size(55, 13);
      this.m_StartYearLabel.TabIndex = 4;
      this.m_StartYearLabel.Text = "Start year:";
      this.m_StartYearLabel.TextAlign = System.Drawing.ContentAlignment.MiddleLeft;
      // 
      // m_EndYearLabel
      // 
      this.m_EndYearLabel.AutoSize = true;
      this.m_EndYearLabel.BackColor = System.Drawing.Color.Transparent;
      this.m_EndYearLabel.ForeColor = System.Drawing.Color.White;
      this.m_EndYearLabel.Location = new System.Drawing.Point(30, 80);
      this.m_EndYearLabel.Name = "m_EndYearLabel";
      this.m_EndYearLabel.Size = new System.Drawing.Size(52, 13);
      this.m_EndYearLabel.TabIndex = 5;
      this.m_EndYearLabel.Text = "End year:";
      // 
      // m_StartYearComboBox
      // 
      this.m_StartYearComboBox.DropDownStyle = System.Windows.Forms.ComboBoxStyle.DropDownList;
      this.m_StartYearComboBox.FormattingEnabled = true;
      this.m_StartYearComboBox.Items.AddRange(new object[] {
            "BC",
            "AD"});
      this.m_StartYearComboBox.Location = new System.Drawing.Point(164, 50);
      this.m_StartYearComboBox.Name = "m_StartYearComboBox";
      this.m_StartYearComboBox.Size = new System.Drawing.Size(43, 21);
      this.m_StartYearComboBox.TabIndex = 7;
      this.m_StartYearComboBox.SelectedIndexChanged += new System.EventHandler(this.m_StartYearComboBox_SelectedIndexChanged);
      // 
      // m_EndYearComboBox
      // 
      this.m_EndYearComboBox.DropDownStyle = System.Windows.Forms.ComboBoxStyle.DropDownList;
      this.m_EndYearComboBox.FormattingEnabled = true;
      this.m_EndYearComboBox.Items.AddRange(new object[] {
            "BC",
            "AD"});
      this.m_EndYearComboBox.Location = new System.Drawing.Point(164, 77);
      this.m_EndYearComboBox.Name = "m_EndYearComboBox";
      this.m_EndYearComboBox.Size = new System.Drawing.Size(43, 21);
      this.m_EndYearComboBox.TabIndex = 8;
      this.m_EndYearComboBox.SelectedIndexChanged += new System.EventHandler(this.m_EndYearComboBox_SelectedIndexChanged);
      // 
      // m_TurnsLabel
      // 
      this.m_TurnsLabel.AutoSize = true;
      this.m_TurnsLabel.BackColor = System.Drawing.Color.Transparent;
      this.m_TurnsLabel.ForeColor = System.Drawing.Color.White;
      this.m_TurnsLabel.Location = new System.Drawing.Point(232, 53);
      this.m_TurnsLabel.Name = "m_TurnsLabel";
      this.m_TurnsLabel.RightToLeft = System.Windows.Forms.RightToLeft.No;
      this.m_TurnsLabel.Size = new System.Drawing.Size(125, 13);
      this.m_TurnsLabel.TabIndex = 10;
      this.m_TurnsLabel.Text = "Amount of turns per year:";
      // 
      // m_TurnsInput
      // 
      this.m_TurnsInput.Location = new System.Drawing.Point(363, 50);
      this.m_TurnsInput.Name = "m_TurnsInput";
      this.m_TurnsInput.RightToLeft = System.Windows.Forms.RightToLeft.No;
      this.m_TurnsInput.Size = new System.Drawing.Size(45, 20);
      this.m_TurnsInput.TabIndex = 9;
      this.m_TurnsInput.TextChanged += new System.EventHandler(this.m_TurnsInput_TextChanged);
      this.m_TurnsInput.KeyPress += new System.Windows.Forms.KeyPressEventHandler(this.m_TurnsInput_KeyPress);
      // 
      // m_ScriptNameInput
      // 
      this.m_ScriptNameInput.Location = new System.Drawing.Point(117, 137);
      this.m_ScriptNameInput.Name = "m_ScriptNameInput";
      this.m_ScriptNameInput.Size = new System.Drawing.Size(223, 20);
      this.m_ScriptNameInput.TabIndex = 11;
      this.m_ScriptNameInput.Text = "Imperial_Campaign";
      this.m_ScriptNameInput.Visible = false;
      // 
      // m_ScriptNameLabel
      // 
      this.m_ScriptNameLabel.AutoSize = true;
      this.m_ScriptNameLabel.BackColor = System.Drawing.Color.Transparent;
      this.m_ScriptNameLabel.ForeColor = System.Drawing.Color.White;
      this.m_ScriptNameLabel.Location = new System.Drawing.Point(27, 140);
      this.m_ScriptNameLabel.Name = "m_ScriptNameLabel";
      this.m_ScriptNameLabel.Size = new System.Drawing.Size(88, 13);
      this.m_ScriptNameLabel.TabIndex = 12;
      this.m_ScriptNameLabel.Text = "Campaign Name:";
      this.m_ScriptNameLabel.Visible = false;
      // 
      // m_CreateBackgroundscript
      // 
      this.m_CreateBackgroundscript.AutoSize = true;
      this.m_CreateBackgroundscript.BackColor = System.Drawing.Color.Transparent;
      this.m_CreateBackgroundscript.ForeColor = System.Drawing.Color.White;
      this.m_CreateBackgroundscript.Location = new System.Drawing.Point(266, 114);
      this.m_CreateBackgroundscript.Name = "m_CreateBackgroundscript";
      this.m_CreateBackgroundscript.RightToLeft = System.Windows.Forms.RightToLeft.Yes;
      this.m_CreateBackgroundscript.Size = new System.Drawing.Size(143, 17);
      this.m_CreateBackgroundscript.TabIndex = 14;
      this.m_CreateBackgroundscript.Text = "Create Backgroundscript";
      this.m_CreateBackgroundscript.UseVisualStyleBackColor = false;
      this.m_CreateBackgroundscript.Visible = false;
      this.m_CreateBackgroundscript.CheckedChanged += new System.EventHandler(this.m_CreateBackgroundscript_CheckedChanged);
      // 
      // m_WinterTurnLabel
      // 
      this.m_WinterTurnLabel.AutoSize = true;
      this.m_WinterTurnLabel.BackColor = System.Drawing.Color.Transparent;
      this.m_WinterTurnLabel.ForeColor = System.Drawing.Color.White;
      this.m_WinterTurnLabel.Location = new System.Drawing.Point(245, 76);
      this.m_WinterTurnLabel.Name = "m_WinterTurnLabel";
      this.m_WinterTurnLabel.RightToLeft = System.Windows.Forms.RightToLeft.No;
      this.m_WinterTurnLabel.Size = new System.Drawing.Size(112, 13);
      this.m_WinterTurnLabel.TabIndex = 15;
      this.m_WinterTurnLabel.Text = "Amount of winter turns";
      this.m_WinterTurnLabel.Visible = false;
      // 
      // m_WinterTurnInput
      // 
      this.m_WinterTurnInput.Location = new System.Drawing.Point(363, 74);
      this.m_WinterTurnInput.Name = "m_WinterTurnInput";
      this.m_WinterTurnInput.Size = new System.Drawing.Size(46, 20);
      this.m_WinterTurnInput.TabIndex = 13;
      this.m_WinterTurnInput.Visible = false;
      // 
      // m_MonitorEvent
      // 
      this.m_MonitorEvent.AutoSize = true;
      this.m_MonitorEvent.BackColor = System.Drawing.Color.Transparent;
      this.m_MonitorEvent.ForeColor = System.Drawing.Color.White;
      this.m_MonitorEvent.Location = new System.Drawing.Point(218, 98);
      this.m_MonitorEvent.Name = "m_MonitorEvent";
      this.m_MonitorEvent.RightToLeft = System.Windows.Forms.RightToLeft.Yes;
      this.m_MonitorEvent.Size = new System.Drawing.Size(191, 17);
      this.m_MonitorEvent.TabIndex = 16;
      this.m_MonitorEvent.Text = "Use monitor_event instead of while";
      this.m_MonitorEvent.UseVisualStyleBackColor = false;
      this.m_MonitorEvent.Visible = false;
      // 
      // Main
      // 
      this.AutoScaleDimensions = new System.Drawing.SizeF(6F, 13F);
      this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
      this.BackgroundImage = global::RTWMultipleTurnsPerYear.Properties.Resources.logo_rtw;
      this.BackgroundImageLayout = System.Windows.Forms.ImageLayout.Stretch;
      this.ClientSize = new System.Drawing.Size(430, 207);
      this.Controls.Add(this.m_MonitorEvent);
      this.Controls.Add(this.m_WinterTurnInput);
      this.Controls.Add(this.m_WinterTurnLabel);
      this.Controls.Add(this.m_CreateBackgroundscript);
      this.Controls.Add(this.m_ScriptNameLabel);
      this.Controls.Add(this.m_ScriptNameInput);
      this.Controls.Add(this.m_TurnsLabel);
      this.Controls.Add(this.m_TurnsInput);
      this.Controls.Add(this.m_EndYearComboBox);
      this.Controls.Add(this.m_StartYearComboBox);
      this.Controls.Add(this.m_EndYearLabel);
      this.Controls.Add(this.m_StartYearLabel);
      this.Controls.Add(this.m_EndYearInput);
      this.Controls.Add(this.m_StartYearInput);
      this.Controls.Add(this.m_ContactLink);
      this.Controls.Add(this.m_GenerateButton);
      this.FormBorderStyle = System.Windows.Forms.FormBorderStyle.FixedToolWindow;
      this.Icon = ((System.Drawing.Icon)(resources.GetObject("$this.Icon")));
      this.Name = "Main";
      this.StartPosition = System.Windows.Forms.FormStartPosition.CenterScreen;
      this.Text = "Rome: Total War | Multiple Turns Per Year Generator";
      ((System.ComponentModel.ISupportInitialize)(this.m_WinterTurnInput)).EndInit();
      this.ResumeLayout(false);
      this.PerformLayout();

        }

        #endregion

        private System.Windows.Forms.Button m_GenerateButton;
        private System.Windows.Forms.LinkLabel m_ContactLink;
        private System.Windows.Forms.TextBox m_StartYearInput;
        private System.Windows.Forms.TextBox m_EndYearInput;
        private System.Windows.Forms.Label m_StartYearLabel;
        private System.Windows.Forms.Label m_EndYearLabel;
        private System.Windows.Forms.ComboBox m_StartYearComboBox;
        private System.Windows.Forms.ComboBox m_EndYearComboBox;
        private System.Windows.Forms.Label m_TurnsLabel;
        private System.Windows.Forms.TextBox m_TurnsInput;
        private System.Windows.Forms.TextBox m_ScriptNameInput;
        private System.Windows.Forms.Label m_ScriptNameLabel;
        private System.Windows.Forms.CheckBox m_CreateBackgroundscript;
        private System.Windows.Forms.Label m_WinterTurnLabel;
        private System.Windows.Forms.NumericUpDown m_WinterTurnInput;
    private System.Windows.Forms.CheckBox m_MonitorEvent;
  }
}