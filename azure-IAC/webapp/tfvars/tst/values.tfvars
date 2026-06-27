location = "centralus"
environment = "tst"
sku_capacity_default = 2
sku_size = "P1v3"
namespace = "tst"
analytics_workspace_name = "webapp-law-tst"
app_insights_name = "quantam-appins-tst"
virtual_network_name = "pcm-network-cus-quantam-vnet-tst"
subnet_name = "snet-quantam-app-centralus-tst"
pep_subnet_name = "snet-quantam-pep-centralus-tst"
#custom_hostname = "quantamtest-cloud.optum.com"
subscription_id = "14b710f0-0020-4b63-887d-22a232c0324c"

# NOTE: This storage account is required by BOTH the webapp AND the functions modules.
# The blob/file DNS zones and VNet links created here are shared by:
#   - func-quantam-medicaappservice-apis-centralus-stg
#   - func-quantam-2-0-apis-centralus-stg
# DO NOT comment out this block — removing it will break function app startup (403 on host lock lease).
storage_accounts = {
  tststorage = {
    name                      = "quantamst"
    shared_access_key_enabled = true
    endpoint_service_types    = ["blob", "file"]
    containers = [
      { name = "quantam-import", access_type = "private" },
      { name = "quantam-2-import", access_type = "private" }
    ]
    shares        = []
    webapp_access = ["quantam2_0", "quantam", "trackingapi", "medicaappservice", "quantam_appservices"]
  }
}
