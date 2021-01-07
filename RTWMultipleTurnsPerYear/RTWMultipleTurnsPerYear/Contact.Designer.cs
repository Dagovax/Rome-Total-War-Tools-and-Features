namespace RTWMultipleTurnsPerYear
{
    partial class Contact
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
            System.ComponentModel.ComponentResourceManager resources = new System.ComponentModel.ComponentResourceManager(typeof(Contact));
            this.m_ContactLabel = new System.Windows.Forms.Label();
            this.m_MailButton = new System.Windows.Forms.Button();
            this.m_ModDBButton = new System.Windows.Forms.Button();
            this.SuspendLayout();
            // 
            // m_ContactLabel
            // 
            this.m_ContactLabel.AutoSize = true;
            this.m_ContactLabel.Font = new System.Drawing.Font("Microsoft Sans Serif", 10F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.m_ContactLabel.Location = new System.Drawing.Point(12, 29);
            this.m_ContactLabel.Name = "m_ContactLabel";
            this.m_ContactLabel.Size = new System.Drawing.Size(346, 17);
            this.m_ContactLabel.TabIndex = 0;
            this.m_ContactLabel.Text = "How do you want to contact Dagovax with a question?";
            // 
            // m_MailButton
            // 
            this.m_MailButton.Location = new System.Drawing.Point(200, 102);
            this.m_MailButton.Name = "m_MailButton";
            this.m_MailButton.Size = new System.Drawing.Size(108, 23);
            this.m_MailButton.TabIndex = 1;
            this.m_MailButton.Text = "Mail";
            this.m_MailButton.UseVisualStyleBackColor = true;
            this.m_MailButton.Click += new System.EventHandler(this.m_MailButton_Click);
            // 
            // m_ModDBButton
            // 
            this.m_ModDBButton.Location = new System.Drawing.Point(70, 102);
            this.m_ModDBButton.Name = "m_ModDBButton";
            this.m_ModDBButton.Size = new System.Drawing.Size(108, 23);
            this.m_ModDBButton.TabIndex = 2;
            this.m_ModDBButton.Text = "ModDB";
            this.m_ModDBButton.UseVisualStyleBackColor = true;
            this.m_ModDBButton.Click += new System.EventHandler(this.m_ModDBButton_Click);
            // 
            // Contact
            // 
            this.AutoScaleDimensions = new System.Drawing.SizeF(6F, 13F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            this.BackColor = System.Drawing.SystemColors.ActiveCaption;
            this.ClientSize = new System.Drawing.Size(370, 137);
            this.Controls.Add(this.m_ModDBButton);
            this.Controls.Add(this.m_MailButton);
            this.Controls.Add(this.m_ContactLabel);
            this.FormBorderStyle = System.Windows.Forms.FormBorderStyle.FixedDialog;
            this.Icon = ((System.Drawing.Icon)(resources.GetObject("$this.Icon")));
            this.Name = "Contact";
            this.StartPosition = System.Windows.Forms.FormStartPosition.CenterParent;
            this.Text = "Contact";
            this.ResumeLayout(false);
            this.PerformLayout();

        }

        #endregion

        private System.Windows.Forms.Label m_ContactLabel;
        private System.Windows.Forms.Button m_MailButton;
        private System.Windows.Forms.Button m_ModDBButton;
    }
}