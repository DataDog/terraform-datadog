# Configure the Datadog provider
# provider "datadog" {
#   version = "2.8.0"
#   api_url = var.datadog_api_url
#   api_key = var.datadog_api_key
#   app_key = var.datadog_app_key
# }

resource "datadog_monitor" "high_cpu_user" {
  type                = "metric alert"
  name                = "High user CPU utilization {{host.name}}"
  query               = <<EOF
avg(last_5m):avg:system.cpu.user{${var.selected_tags}} by {cloud_provider,env,host} > ${var.thresholds.alert}
EOF
  message = <<EOF
{{#is_alert}}
Alert | User CPU is high

Instructions:

- Check stuffs

${var.notifications.alert}
{{/is_alert}}

{{#is_warning}}
Warning | User CPU is high

Instructions:

- Check other stuffs

${var.notifications.warn}
{{/is_warning}} 

{{#is_recovery}}
We are recovering!

${var.notifications.recovery}
{{/is_recovery}}

Alert details: 

- cloud_provider: {{cloud_provider.name}}
- env: {{env.name}}
- host: {{host.name}}

${var.notifications.default}

EOF
  thresholds = {
    critical          = var.thresholds.alert
    warning           = var.thresholds.warn
  }
  notify_no_data      = true
  no_data_timeframe   = 120
  include_tags        = true
  tags                = ["standard:true", "terraform:true"]
}