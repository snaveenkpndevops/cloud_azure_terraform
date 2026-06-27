namespace       = "stg"
location        = "centralus"
subscription_id = "14b710f0-0020-4b63-887d-22a232c0324c"


resource_groups = {
  app = {
    name = "rg-quantam-centralus-stg" 
    tags = {
      "aide-id"      = "uhgwm110-026049"
      "environment"  = "stg"
      "service-tier" = "p2"
    }
  }
}