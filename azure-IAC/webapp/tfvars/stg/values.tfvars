location = "centralus"
environment = "stg"
sku_capacity_default = 2
sku_size = "P1v3"
namespace = "stg"
analytics_workspace_name = "webapp-law-stg"
app_insights_name = "quantam-appins-stg"
virtual_network_name = "pcm-network-cus-quantam-vnet-stg"
subnet_name = "snet-quantam-app-centralus-stg"
pep_subnet_name = "snet-quantam-pep-centralus-stg"
subscription_id = "14b710f0-0020-4b63-887d-22a232c0324c"
resource_group_name = "pc-managed-networking"

# quantam2-0 config
quantam2_0_prod_url  = "https://ase-quantam-2-0-centralus-prod.azurewebsites.net"
quantam2_0_stage_url = "https://ase-quantam-2-0-centralus-stg.azurewebsites.net"
quantam2_0_test_url  = "https://ase-quantam-2-0-centralus-tst.azurewebsites.net"
system_from_email    = "WebTrax_System_Do_Not_Reply@uhc.com"

# trackingapi config
sam_api_base_url        = "https://testelr.appservice.elr01.optum.com/"
sam_api_daily_endpoint  = "api/AuditQuantamSamples/response_daily"
sam_api_weekly_endpoint = "api/AuditQuantamSamples/response_weekly"
app_timezone            = "Central Standard Time"

# quantamserviceapis non-sensitive AppSettings
quantam_appservices_app_settings = {
  NasPathNychhRecording   = "\\\\nas00593pn\\Data\\UBH_SHARED\\Reporting & Analysis Team\\WebTrax Files\\Recording.csv"
  NasPathNychhCallAudits  = "\\\\nas00593pn\\Data\\UBH_SHARED\\Reporting & Analysis Team\\WebTrax Files\\Quantam_Common_Paid\\NYCHH Call\\NYCHH_Call_Audits.csv"
  NasDataPathAarp         = "\\\\nas00593pn\\Data\\UBH_SHARED\\Reporting & Analysis Team\\WebTrax Files\\AARPHealth"
  NasArchivePathAarp      = "\\\\nas00593pn\\Data\\UBH_SHARED\\Reporting & Analysis Team\\WebTrax Files\\AARPHealth\\Archive"
  MailRecipientsAarp      = "Quantam_DevOps_Team@ds.uhc.com"
  MailSupportAarp         = "WebTrax_DevOps_Team_DL@ds.uhc.com"
  NasDataPathFwae         = "\\\\nas00593pn\\Data\\UBH_SHARED\\Reporting & Analysis Team\\WebTrax Files\\FWAE"
  NasArchivePathFwae      = "\\\\nas00593pn\\Data\\UBH_SHARED\\Reporting & Analysis Team\\WebTrax Files\\FWAE\\Archive"
  MailRecipientsFwae      = "Quantam_DevOps_Team@ds.uhc.com"
  MailSupportFwae         = "WebTrax_DevOps_Team_DL@ds.uhc.com"
  NasDataPathOpiCob       = "\\\\nas00593pn\\Data\\UBH_SHARED\\Reporting & Analysis Team\\WebTrax Files\\Quantam_Common_Paid"
  NasArchivePathOpiCob    = "\\\\nas00593pn\\Data\\UBH_SHARED\\Reporting & Analysis Team\\WebTrax Files\\Quantam_Common_Paid\\Archive_CobOutreach"
  MailRecipientsOpiCob    = "Quantam_DevOps_Team@ds.uhc.com"
  MailSupportOpiCob       = "WebTrax_DevOps_Team_DL@ds.uhc.com"
  NasDataPathPmr          = "\\\\nas00593pn\\Data\\UBH_SHARED\\Reporting & Analysis Team\\WebTrax Files\\PMR"
  NasArchivePathPmr       = "\\\\nas00593pn\\Data\\UBH_SHARED\\Reporting & Analysis Team\\WebTrax Files\\PMR\\Archive"
  MailRecipientsPmr       = "Quantam_DevOps_Team@ds.uhc.com"
  MailSupportPmr          = "WebTrax_DevOps_Team_DL@ds.uhc.com"
  NasDataPathWePostPay    = "\\\\nas00593pn\\Data\\UBH_SHARED\\Reporting & Analysis Team\\WebTrax Files\\FWAE\\WE_Post_Pay"
  NasArchivePathWePostPay = "\\\\nas00593pn\\Data\\UBH_SHARED\\Reporting & Analysis Team\\WebTrax Files\\FWAE\\WE_Post_Pay\\Archive"
  MailRecipientsWePostPay = "WebTrax_DevOps_Team_DL@ds.uhc.com"
  MailSupportWePostPay    = "WebTrax_DevOps_Team_DL@ds.uhc.com"
  MailRecipientsMedicaBne = "Quantam_DevOps_Team@ds.uhc.com"
  MailSupportMedicaBne    = "WebTrax_DevOps_Team_DL@ds.uhc.com"
  SmtpServer              = "azssmtp.ctc01.cloudapp.optum.com"
  MailRecipientsFcac      = "Quantam_DevOps_Team@ds.uhc.com"
  MailSupportFcac         = ""
}

# quantam-web non-sensitive app settings (plain values — no KV needed)
quantam_ssrs_wtx                = "http://orbit-ssrs-prod-int.optum.com/ReportServer"
quantam_ssrs_prod               = "http://orbit-ssrs-prod-int.optum.com/ReportServer"
quantam_ops2_url                = "http://ops2-stage.mhars1.optum.com"
quantam_wtxdb_environment       = "WebTrax Stage Server"
quantam_chart_image_handler     = "storage=file;timeout=20;"
quantam_disable_email_env       = "stage"
quantam2_0_url                  = "https://ase-quantam-2-0-centralus-stg.azurewebsites.net"         # fallback; keyvault.yaml overrides with custom domain
quantam_time_tracker_uri        = "https://ase-quantam-trackingapi-centralus-stg.azurewebsites.net" # fallback; keyvault.yaml overrides with custom domain
quantam_error_log_fallback_path = ""  # set if Azure Files / UNC path is available

# medicaappservice non-sensitive config (matches appsettings.json structure)
medica_smtp_host    = "azssmtp.ctc01.cloudapp.optum.com"
medica_nas_base_url = "https://azurenas.optum.com/nas"

# ImportServiceSettings — ask dev team to confirm TST-specific paths/recipients
medica_import_service_settings = {
  MellonPrenotes = {
    Recipients  = "diwanshu_pal@optum.com"
    Support     = "WebTrax_DevOps_Team_DL@ds.uhc.com"
    DataPath    = "\\\\nas00593pn\\Reporting & Analysis Team\\WebTrax Files\\MedicaMellonPrenotes"
    ArchivePath = "\\\\nas00593pn\\Reporting & Analysis Team\\WebTrax Files\\MedicaMellonPrenotes\\Archive"
  }
  MellonReturns = {
    Recipients  = "diwanshu_pal@optum.com"
    Support     = "WebTrax_DevOps_Team_DL@ds.uhc.com"
    DataPath    = "\\\\nas00593pn\\Reporting & Analysis Team\\WebTrax Files\\MedicaMellonReturns"
    ArchivePath = "\\\\nas00593pn\\Reporting & Analysis Team\\WebTrax Files\\MedicaMellonReturns\\Archive"
  }
  NonpayTermAccountMaintenance = {
    Recipients = "diwanshu_pal@optum.com"
    Support    = "WebTrax_DevOps_Team_DL@ds.uhc.com"
  }
  NonpayTermCallNeeded = {
    Recipients = "aiesha_shaik200@optum.com"
    Support    = "WebTrax_DevOps_Team_DL@ds.uhc.com"
  }
  NonpayTermFinalResearchDay2 = {
    Recipients  = "diwanshu_pal@optum.com"
    Support     = "WebTrax_DevOps_Team_DL@ds.uhc.com"
    DataPath    = "\\\\nasgw023pn\\Ovations_Medica\\B&E\\Medica Team\\Inventory\\Billing\\Non-PayTerms\\ARM Term Balance Reports"
    ArchivePath = "\\\\nasgw023pn\\Ovations_Medica\\B&E\\Medica Team\\Inventory\\Billing\\Non-PayTerms\\ARM Term Balance Reports\\Archive"
  }
  NonpayTermFinalResearchDay3 = {
    Recipients = "anu_priya@optum.com"
    Support    = "WebTrax_DevOps_Team_DL@ds.uhc.com"
  }
  NonpayTermInitialResearch = {
    Recipients       = "diwanshu_pal@optum.com"
    Support          = "WebTrax_DevOps_Team_DL@ds.uhc.com"
    DataPath         = "\\\\nasgw023pn\\Ovations_Medica\\B&E\\Medica Team\\Inventory\\Billing\\Non-PayTerms\\ARM Term Balance Reports"
    ArchivePath      = "\\\\nasgw023pn\\Ovations_Medica\\B&E\\Medica Team\\Inventory\\Billing\\Non-PayTerms\\ARM Term Balance Reports\\Archive"
    RemoveReviewPath = "\\\\nasgw023pn\\Ovations_Medica\\B&E\\Medica Team\\Inventory\\Billing\\Non-PayTerms\\Remove review date reports\\"
    ReportingPath    = "\\\\nasgw023pn\\Ovations_Medica\\B&E\\Medica Team\\Inventory\\Billing\\Non-PayTerms\\Nonpay terms reporting\\"
  }
  SSA_Debit = {
    Recipients  = "Quantam_DevOps_Team@ds.uhc.com"
    Support     = ""
    DataPath    = "\\\\nas00593pn\\Reporting & Analysis Team\\WebTrax Files\\MedicaSSADebit"
    ArchivePath = "\\\\nas00593pn\\Reporting & Analysis Team\\WebTrax Files\\MedicaSSADebit\\Archive"
    DataPathTRR = "\\\\nasgw023pn\\Ovations_Medica\\B&E\\Medica Team\\Inventory\\Billing\\TRR\\Automation\\185 codes\\185 Codes Droid completed"
  }
  SSA_TRR = {
    Recipients     = "anu_priya@optum.com"
    Support        = "WebTrax_DevOps_Team_DL@ds.uhc.com"
    DataPathSSA    = "\\\\nasgw023pn\\Ovations_Medica\\B&E\\Medica Team\\Inventory\\Billing\\TRR\\Automation\\SSA codes"
    ArchivePathSSA = "\\\\nasgw023pn\\Ovations_Medica\\B&E\\Medica Team\\Inventory\\Billing\\TRR\\Automation\\SSA codes\\SSA Codes Imported to Webtrax"
    DataPath185    = "\\\\nasgw023pn\\Ovations_Medica\\B&E\\Medica Team\\Inventory\\Billing\\TRR\\Automation\\185 codes\\185 Codes Droid completed"
    ArchivePath185 = "\\\\nasgw023pn\\Ovations_Medica\\B&E\\Medica Team\\Inventory\\Billing\\TRR\\Automation\\185 codes\\185 Codes Droid completed\\185 codes Imported to Webtrax"
  }
  TermedMembers = {
    Recipients      = "aiesha_shaik200@optum.com"
    Support         = "WebTrax_DevOps_Team_DL@ds.uhc.com"
    DataPathTerm    = "\\\\nasgw023pn\\Ovations_Medica\\B&E\\Medica Team\\RECON\\Reply Reports\\Weekly Death Terms"
    ArchivePathTerm = "\\\\nasgw023pn\\Ovations_Medica\\B&E\\Medica Team\\RECON\\Reply Reports\\Weekly Death Terms\\Loaded to WebTrax"
    DataPathEP      = "\\\\nasgw023pn\\Ovations_Medica\\B&E\\Medica Team\\Medica Individually Billed Accounts\\Billing Reports to be worked\\New Terms and Changes Report"
    ArchivePathEP   = "\\\\nasgw023pn\\Ovations_Medica\\B&E\\Medica Team\\Medica Individually Billed Accounts\\Billing Reports to be worked\\New Terms and Changes Report\\Loaded to WebTrax"
  }
  MedicaBEQueueArchival = {
    Support = "WebTrax_DevOps_Team_DL@ds.uhc.com"
  }
  MedicaDOC360 = {
    DataPath = "\\\\nasgw023pn\\Ovations_Medica\\B&E\\Medica Team\\Medica Individually Billed Accounts\\Billing Reports to be worked\\Aging\\Formatting\\WAITING FOR DROID\\"
  }
}

# NOTE: This storage account is required by BOTH the webapp AND the functions modules.
# The blob/file DNS zones and VNet links created here are shared by:
#   - func-quantam-medicaappservice-apis-centralus-stg
#   - func-quantam-2-0-apis-centralus-stg
# DO NOT comment out this block — removing it will break function app startup (403 on host lock lease).
storage_accounts = {
  stgstorage = {
    name                      = "quantamwebstg"
    shared_access_key_enabled = true
    endpoint_service_types    = ["blob", "file"]
    containers = [
      #{ name = "quantam-import", access_type = "private" },
      #{ name = "quantam-2-import", access_type = "private" }
    ]
    shares        = []
    webapp_access = ["quantam2_0", "quantam", "trackingapi", "medicaappservice", "quantam_appservices"]
  }
}