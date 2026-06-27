namespace       = "tst"
location        = "centralus"
subscription_id = "14b710f0-0020-4b63-887d-22a232c0324c"

resource_groups = {
  app = {
    name = "rg-quantam-centralus-tst" 
    tags = {
      "aide-id"      = "uhgwm110-026049"
      "environment"  = "tst"
      "service-tier" = "p2"
    }
  }
}