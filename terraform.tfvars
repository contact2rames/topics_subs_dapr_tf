environment = "qa"
rg = "yyyyy-poc-qa-xxxxx-rg"
container_app_environment = "yyyyy-poc-q-xxxxx-conenv-01"
servicebus_ns = "yyyyy-poc-q-xxxxx-svbus-01"
servicebus_connection_string = ""

topics = {
  "haridwar_batchalert" = {
    name = "Demo_poc_batchalert"

    subscriptions = [
      {
        name        = "Demo_poc_Alert_BatchData"
        filter      = "SubId='Demo_poc_Alert_BatchData'"
        filter_type = "SqlFilter"
      },
      {
        name        = "Demo_poc_Alert_BatchLastRecord"
        filter      = "SubId='Demo_poc_Alert_BatchLastRecord'"
        filter_type = "SqlFilter"
      }
    ]
  }

  "sumerpur_batchalert" = {
    name = "Demo_smp_poc_batchalert"

    subscriptions = [
      {
        name        = "Demo_Smp_poc_Alert_BatchData"
        filter      = "SubId='Demo_Smp_poc_Alert_BatchData'"
        filter_type = "SqlFilter"
      },
      {
        name        = "Demo_Smp_poc_Alert_BatchLastRecord"
        filter      = "SubId='Demo_Smp_poc_Alert_BatchLastRecord'"
        filter_type = "SqlFilter"
      }
    ]
  }

  "haridwar_dsummarizer" = {
    name = "Demo_poc_dsummarizer"

    subscriptions = [
      {
        name        = "Demo_poc_BarcodeTracking"
        filter      = "SubId='Demo_poc_BarcodeTracking'"
        filter_type = "SqlFilter"
      },
      {
        name        = "Demo_poc_BarcodeTracking_Test"
      },
      {
        name        = "Demo_poc_BatchCalculation"
        filter      = "SubId='Demo_poc_BatchCalculation'"
        filter_type = "SqlFilter"
      },
      {
        name        = "Demo_poc_BatchLastRecord"
        filter      = "SubId='Demo_poc_BatchLastRecord'"
        filter_type = "SqlFilter"
      },
      {
        name        = "Demo_poc_EGA_SummarizerToZone"
      },
      {
        name        = "Demo_poc_FinalSummary"
        filter      = "SubId='Demo_poc_FinalSummary'"
        filter_type = "SqlFilter"
      },
      {
        name        = "Demo_poc_RawData"
        filter      = "SubId='Demo_poc_RawData'"
        filter_type = "SqlFilter"
      },
      {
        name        = "Demo_poc_Recipes"
        filter      = "SubId='Demo_poc_Recipes'"
        filter_type = "SqlFilter"
      },
      {
        name        = "Demo_poc_SummarizerToZone"
        filter      = "SubId='Demo_poc_SummarizerToZone'"
        filter_type = "SqlFilter"
      },
      {
        name        = "Demo_poc_SummarizerToZone_ST"
        filter      = "SubId='Demo_poc_SummarizerToZone'"
        filter_type = "SqlFilter"
      },
      {
        name        = "Demo_poc_SummarySave"
        filter      = "SubId='Demo_poc_FinalSummary'"
        filter_type = "SqlFilter"
      }
    ]
  }

  "sumerpur_dsummarizer" = {
    name = "Demo_smp_poc_dsummarizer"

    subscriptions = [
      {
        name        = "Demo_Smp_poc_BarcodeTracking"
        filter      = "SubId='Demo_Smp_poc_BarcodeTracking'"
        filter_type = "SqlFilter"
      },
      {
        name        = "Demo_Smp_poc_BarcodeTracking_Test"
      },
      {
        name        = "Demo_Smp_poc_BatchCalculation"
        filter      = "SubId='Demo_Smp_poc_BatchCalculation'"
        filter_type = "SqlFilter"
      },
      {
        name        = "Demo_Smp_poc_BatchLastRecord"
        filter      = "SubId='Demo_Smp_poc_BatchLastRecord'"
        filter_type = "SqlFilter"
      },
      {
        name        = "Demo_Smp_poc_EGA_SummarizerToZone"
      },
      {
        name        = "Demo_Smp_poc_FinalSummary"
        filter      = "SubId='Demo_Smp_poc_FinalSummary'"
        filter_type = "SqlFilter"
      },
      {
        name        = "Demo_Smp_poc_RawData"
        filter      = "SubId='Demo_Smp_poc_RawData'"
        filter_type = "SqlFilter"
      },
      {
        name        = "Demo_Smp_poc_Recipes"
        filter      = "SubId='Demo_Smp_poc_Recipes'"
        filter_type = "SqlFilter"
      },
      {
        name        = "Demo_Smp_poc_SummarizerToZone"
        filter      = "SubId='Demo_Smp_poc_SummarizerToZone'"
        filter_type = "SqlFilter"
      },
      {
        name        = "Demo_Smp_poc_SummarizerToZone_ST"
        filter      = "SubId='NA'"
        filter_type = "SqlFilter"
      },
      {
        name        = "Demo_Smp_poc_SummarySave"
        filter      = "SubId='Demo_Smp_poc_FinalSummary'"
        filter_type = "SqlFilter"
      }
    ]
  }

  "haridwar_zw_mw" = {
    name = "Demo_poc_zone_and_material_calculation"

    subscriptions = [
      {
        name        = "Demo_Ega_SfgMaterialDayData"
        filter      = "SubId='Demo_Ega_SfgMaterialDayData'"
        filter_type = "SqlFilter"
      },
      {
        name        = "Demo_Ega_SfgMaterialMonthData"
        filter      = "SubId='Demo_Ega_SfgMaterialMonthData'"
        filter_type = "SqlFilter"
      },
      {
        name        = "Demo_Ega_SfgMaterialShiftData"
        filter      = "SubId='Demo_Ega_SfgMaterialShiftData'"
        filter_type = "SqlFilter"
      },
      {
        name        = "Demo_Ega_SfgMaterialWeekData"
        filter      = "SubId='Demo_Ega_SfgMaterialWeekData'"
        filter_type = "SqlFilter"
      },
      {
        name        = "Demo_poc_BarcodeAndEventData"
        filter      = "SubId='Demo_poc_BarcodeAndEventData'"
        filter_type = "SqlFilter"
      },
      {
        name        = "Demo_poc_BarcodeSummaryData"
        filter      = "SubId='Demo_poc_BarcodeSummaryData'"
        filter_type = "SqlFilter"
      },
      {
        name        = "Demo_poc_BCMR"
        filter      = "SubId='Demo_poc_BCMR'"
        filter_type = "SqlFilter"
      },
      {
        name        = "Demo_poc_ECMR"
        filter      = "SubId='Demo_poc_ECMR'"
        filter_type = "SqlFilter"
      },
      {
        name        = "Demo_poc_EGAR"
        filter      = "SubId='Demo_poc_EGAR'"
        filter_type = "SqlFilter"
      },
      {
        name        = "Demo_poc_MaterialDayData"
        filter      = "SubId='Demo_poc_MaterialDayData'"
        filter_type = "SqlFilter"
      },
      {
        name        = "Demo_poc_MaterialDayData_Cascade"
        filter      = "SubId='Demo_poc_MaterialDayData_Cascade'"
        filter_type = "SqlFilter"
      },
      {
        name        = "Demo_poc_MaterialDayData_Sigma"
        filter      = "SubId='Demo_poc_MaterialDayData_Sigma'"
        filter_type = "SqlFilter"
      },
      {
        name        = "Demo_poc_MaterialMonthlyData"
        filter      = "SubId='Demo_poc_MaterialMonthlyData'"
        filter_type = "SqlFilter"
      },
      {
        name        = "Demo_poc_MaterialMonthlyData_Cascade"
        filter      = "SubId='Demo_poc_MaterialMonthlyData_Cascade'"
        filter_type = "SqlFilter"
      },
      {
        name        = "Demo_poc_MaterialMonthlyData_Sigma"
        filter      = "SubId='Demo_poc_MaterialMonthlyData_Sigma'"
        filter_type = "SqlFilter"
      },
      {
        name        = "Demo_poc_MaterialShiftData"
        filter      = "SubId='Demo_poc_MaterialShiftData'"
        filter_type = "SqlFilter"
      },
      {
        name        = "Demo_poc_MaterialShiftData_Cascade"
        filter      = "SubId='Demo_poc_MaterialShiftData_Cascade'"
        filter_type = "SqlFilter"
      },
      {
        name        = "Demo_poc_MaterialShiftData_Sigma"
        filter      = "SubId='Demo_poc_MaterialShiftData_Sigma'"
        filter_type = "SqlFilter"
      },
      {
        name        = "Demo_poc_MaterialWeekData"
        filter      = "SubId='Demo_poc_MaterialWeekData'"
        filter_type = "SqlFilter"
      },
      {
        name        = "Demo_poc_MaterialWeekData_Cascade"
        filter      = "SubId='Demo_poc_MaterialWeekData_Cascade'"
        filter_type = "SqlFilter"
      },
      {
        name        = "Demo_poc_MaterialWeekData_Sigma"
        filter      = "SubId='Demo_poc_MaterialWeekData_Sigma'"
        filter_type = "SqlFilter"
      },
      {
        name        = "Demo_poc_MMR"
        filter      = "SubId='Demo_poc_MMR'"
        filter_type = "SqlFilter"
      },
      {
        name        = "Demo_poc_SfgMaterialDayData"
        filter      = "SubId='Demo_poc_SfgMaterialDayData'"
        filter_type = "SqlFilter"
      },
      {
        name        = "Demo_poc_SfgMaterialDayData_Cascade"
        filter      = "SubId='Demo_poc_SfgMaterialDayData_Cascade'"
        filter_type = "SqlFilter"
      },
      {
        name        = "Demo_poc_SfgMaterialDayData_Sigma"
        filter      = "SubId='Demo_poc_SfgMaterialDayData_Sigma'"
        filter_type = "SqlFilter"
      },
      {
        name        = "Demo_poc_SfgMaterialMonthData_Sigma"
        filter      = "SubId='Demo_poc_SfgMaterialMonthData_Sigma'"
        filter_type = "SqlFilter"
      },
      {
        name        = "Demo_poc_SfgMaterialMonthly_Cascade"
        filter      = "SubId='Demo_poc_SfgMaterialMonthly_Cascade'"
        filter_type = "SqlFilter"
      },
      {
        name        = "Demo_poc_SfgMaterialMonthlyData"
        filter      = "SubId='Demo_poc_SfgMaterialMonthlyData'"
        filter_type = "SqlFilter"
      },
      {
        name        = "Demo_poc_SfgMaterialShift_Cascade"
        filter      = "SubId='Demo_poc_SfgMaterialShift_Cascade'"
        filter_type = "SqlFilter"
      },
      {
        name        = "Demo_poc_SfgMaterialShiftData"
        filter      = "SubId='Demo_poc_SfgMaterialShiftData'"
        filter_type = "SqlFilter"
      },
      {
        name        = "Demo_poc_SfgMaterialShiftData_Sigma"
        filter      = "SubId='Demo_poc_SfgMaterialShiftData_Sigma'"
        filter_type = "SqlFilter"
      },
      {
        name        = "Demo_poc_SfgMaterialShiftData_ST"
        filter      = "SubId='NA'"
        filter_type = "SqlFilter"
      },
      {
        name        = "Demo_poc_SfgMaterialWeekData"
        filter      = "SubId='Demo_poc_SfgMaterialWeekData'"
        filter_type = "SqlFilter"
      },
      {
        name        = "Demo_poc_SfgMaterialWeekData_Cascade"
        filter      = "SubId='Demo_poc_SfgMaterialWeekData_Cascade'"
        filter_type = "SqlFilter"
      },
      {
        name        = "Demo_poc_SfgMaterialWeekData_Sigma"
        filter      = "SubId='Demo_poc_SfgMaterialWeekData_Sigma'"
        filter_type = "SqlFilter"
      },
      {
        name        = "Demo_poc_SfgSummaryDayData"
        filter      = "SubId='Demo_poc_SfgSummaryDayData'"
        filter_type = "SqlFilter"
      },
      {
        name        = "Demo_poc_SfgSummaryMonthlyData"
        filter      = "SubId='Demo_poc_SfgSummaryMonthlyData'"
        filter_type = "SqlFilter"
      },
      {
        name        = "Demo_poc_SfgSummaryShiftData"
        filter      = "SubId='Demo_poc_SfgSummaryShiftData'"
        filter_type = "SqlFilter"
      },
      {
        name        = "Demo_poc_SfgSummaryWeekData"
        filter      = "SubId='Demo_poc_SfgSummaryWeekData'"
        filter_type = "SqlFilter"
      },
      {
        name        = "Demo_poc_SMR"
        filter      = "SubId='Demo_poc_SMR'"
        filter_type = "SqlFilter"
      },
      {
        name        = "Demo_poc_SummaryDayData"
        filter      = "SubId='Demo_poc_SummaryDayData'"
        filter_type = "SqlFilter"
      },
      {
        name        = "Demo_poc_SummaryMonthlyData"
        filter      = "SubId='Demo_poc_SummaryMonthlyData'"
        filter_type = "SqlFilter"
      },
      {
        name        = "Demo_poc_SummaryShiftData"
        filter      = "SubId='Demo_poc_SummaryShiftData'"
        filter_type = "SqlFilter"
      },
      {
        name        = "Demo_poc_SummaryWeekData"
        filter      = "SubId='Demo_poc_SummaryWeekData'"
        filter_type = "SqlFilter"
      },
      {
        name        = "Demo_poc_ZBR"
        filter      = "SubId='Demo_poc_ZBR'"
        filter_type = "SqlFilter"
      },
      {
        name        = "Demo_poc_ZMR"
        filter      = "SubId='Demo_poc_ZMR'"
        filter_type = "SqlFilter"
      },
      {
        name        = "Demo_poc_ZoneDataWithSummary"
        filter      = "SubId='Demo_poc_ZoneDataWithSummary'"
        filter_type = "SqlFilter"
      },
      {
        name        = "Demo_poc_ZoneDataWithSummary_st"
      },
      {
        name        = "Demo_poc_ZoneDayData"
        filter      = "SubId='Demo_poc_ZoneDayData'"
        filter_type = "SqlFilter"
      },
      {
        name        = "Demo_poc_ZoneMonthlyData"
        filter      = "SubId='Demo_poc_ZoneMonthlyData'"
        filter_type = "SqlFilter"
      },
      {
        name        = "Demo_poc_ZoneShiftData"
        filter      = "SubId='Demo_poc_ZoneShiftData'"
        filter_type = "SqlFilter"
      },
      {
        name        = "Demo_poc_ZoneWeekData"
        filter      = "SubId='Demo_poc_ZoneWeekData'"
        filter_type = "SqlFilter"
      },
      {
        name        = "Demo-Hrw-automation-jobs"
        filter      = "SubId='Demo-Hrw-automation-jobs'"
        filter_type = "SqlFilter"
      }
    ]
  }

  "sumerpur_zw_mw" = {
    name = "Demo_smp_poc_zone_and_material_calculation"

    subscriptions = [
      {
        name        = "Demo_Smp_Ega_SfgMaterialDayData"
        filter      = "SubId='Demo_Smp_Ega_SfgMaterialDayData'"
        filter_type = "SqlFilter"
      },
      {
        name        = "Demo_Smp_Ega_SfgMaterialMonthData"
        filter      = "SubId='Demo_Smp_Ega_SfgMaterialMonthData'"
        filter_type = "SqlFilter"
      },
      {
        name        = "Demo_Smp_Ega_SfgMaterialShiftData"
        filter      = "SubId='Demo_Smp_Ega_SfgMaterialShiftData'"
        filter_type = "SqlFilter"
      },
      {
        name        = "Demo_Smp_Ega_SfgMaterialWeekData"
        filter      = "SubId='Demo_Smp_Ega_SfgMaterialWeekData'"
        filter_type = "SqlFilter"
      },
      {
        name        = "Demo_Smp_poc_BarcodeAndEventData"
        filter      = "SubId='Demo_Smp_poc_BarcodeAndEventData'"
        filter_type = "SqlFilter"
      },
      {
        name        = "Demo_Smp_poc_BarcodeSummaryData"
        filter      = "SubId='Demo_Smp_poc_BarcodeSummaryData'"
        filter_type = "SqlFilter"
      },
      {
        name        = "Demo_Smp_poc_BCMR"
        filter      = "SubId='Demo_Smp_poc_BCMR'"
        filter_type = "SqlFilter"
      },
      {
        name        = "Demo_Smp_poc_ECMR"
        filter      = "SubId='Demo_Smp_poc_ECMR'"
        filter_type = "SqlFilter"
      },
      {
        name        = "Demo_Smp_poc_EGAR"
        filter      = "SubId='Demo_Smp_poc_EGAR'"
        filter_type = "SqlFilter"
      },
      {
        name        = "Demo_Smp_poc_MaterialDayData"
        filter      = "SubId='Demo_Smp_poc_MaterialDayData'"
        filter_type = "SqlFilter"
      },
      {
        name        = "Demo_Smp_poc_MaterialDayData_Cascade"
        filter      = "SubId='Demo_Smp_poc_MaterialDayData_Cascade'"
        filter_type = "SqlFilter"
      },
      {
        name        = "Demo_Smp_poc_MaterialDayData_Sigma"
        filter      = "SubId='Demo_Smp_poc_MaterialDayData_Sigma'"
        filter_type = "SqlFilter"
      },
      {
        name        = "Demo_Smp_poc_MaterialMonthlyData"
        filter      = "SubId='Demo_Smp_poc_MaterialMonthlyData'"
        filter_type = "SqlFilter"
      },
      {
        name        = "Demo_Smp_poc_MaterialMonthlyData_Cascade"
        filter      = "SubId='Demo_Smp_poc_MaterialMonthlyData_Cascade'"
        filter_type = "SqlFilter"
      },
      {
        name        = "Demo_Smp_poc_MaterialMonthlyData_Sigma"
        filter      = "SubId='Demo_Smp_poc_MaterialMonthlyData_Sigma'"
        filter_type = "SqlFilter"
      },
      {
        name        = "Demo_Smp_poc_MaterialShiftData"
        filter      = "SubId='Demo_Smp_poc_MaterialShiftData'"
        filter_type = "SqlFilter"
      },
      {
        name        = "Demo_Smp_poc_MaterialShiftData_Cascade"
        filter      = "SubId='Demo_Smp_poc_MaterialShiftData_Cascade'"
        filter_type = "SqlFilter"
      },
      {
        name        = "Demo_Smp_poc_MaterialShiftData_Sigma"
        filter      = "SubId='Demo_Smp_poc_MaterialShiftData_Sigma'"
        filter_type = "SqlFilter"
      },
      {
        name        = "Demo_Smp_poc_MaterialWeekData"
        filter      = "SubId='Demo_Smp_poc_MaterialWeekData'"
        filter_type = "SqlFilter"
      },
      {
        name        = "Demo_Smp_poc_MaterialWeekData_Cascade"
        filter      = "SubId='Demo_Smp_poc_MaterialWeekData_Cascade'"
        filter_type = "SqlFilter"
      },
      {
        name        = "Demo_Smp_poc_MaterialWeekData_Sigma"
        filter      = "SubId='Demo_Smp_poc_MaterialWeekData_Sigma'"
        filter_type = "SqlFilter"
      },
      {
        name        = "Demo_Smp_poc_MMR"
        filter      = "SubId='Demo_Smp_poc_MMR'"
        filter_type = "SqlFilter"
      },
      {
        name        = "Demo_Smp_poc_SfgMaterialDayData"
        filter      = "SubId='Demo_Smp_poc_SfgMaterialDayData'"
        filter_type = "SqlFilter"
      },
      {
        name        = "Demo_Smp_poc_SfgMaterialDayData_Cascade"
        filter      = "SubId='Demo_Smp_poc_SfgMaterialDayData_Cascade'"
        filter_type = "SqlFilter"
      },
      {
        name        = "Demo_Smp_poc_SfgMaterialDayData_Sigma"
        filter      = "SubId='Demo_Smp_poc_SfgMaterialDayData_Sigma'"
        filter_type = "SqlFilter"
      },
      {
        name        = "Demo_Smp_poc_SfgMaterialMonthData_Sigma"
        filter      = "SubId='Demo_Smp_poc_SfgMaterialMonthData_Sigma'"
        filter_type = "SqlFilter"
      },
      {
        name        = "Demo_Smp_poc_SfgMaterialMonthly_Cascade"
        filter      = "SubId='Demo_Smp_poc_SfgMaterialMonthly_Cascade'"
        filter_type = "SqlFilter"
      },
      {
        name        = "Demo_Smp_poc_SfgMaterialMonthlyData"
        filter      = "SubId='Demo_Smp_poc_SfgMaterialMonthlyData'"
        filter_type = "SqlFilter"
      },
      {
        name        = "Demo_Smp_poc_SfgMaterialShift_Cascade"
        filter      = "SubId='Demo_Smp_poc_SfgMaterialShift_Cascade'"
        filter_type = "SqlFilter"
      },
      {
        name        = "Demo_Smp_poc_SfgMaterialShiftData"
        filter      = "SubId='Demo_Smp_poc_SfgMaterialShiftData'"
        filter_type = "SqlFilter"
      },
      {
        name        = "Demo_Smp_poc_SfgMaterialShiftData_Sigma"
        filter      = "SubId='Demo_Smp_poc_SfgMaterialShiftData_Sigma'"
        filter_type = "SqlFilter"
      },
      {
        name        = "Demo_Smp_poc_SfgMaterialShiftData_ST"
        filter      = "SubId='NA'"
        filter_type = "SqlFilter"
      },
      {
        name        = "Demo_Smp_poc_SfgMaterialWeekData"
        filter      = "SubId='Demo_Smp_poc_SfgMaterialWeekData'"
        filter_type = "SqlFilter"
      },
      {
        name        = "Demo_Smp_poc_SfgMaterialWeekData_Cascade"
        filter      = "SubId='Demo_Smp_poc_SfgMaterialWeekData_Cascade'"
        filter_type = "SqlFilter"
      },
      {
        name        = "Demo_Smp_poc_SfgMaterialWeekData_Sigma"
        filter      = "SubId='Demo_Smp_poc_SfgMaterialWeekData_Sigma'"
        filter_type = "SqlFilter"
      },
      {
        name        = "Demo_Smp_poc_SfgSummaryDayData"
        filter      = "SubId='Demo_Smp_poc_SfgSummaryDayData'"
        filter_type = "SqlFilter"
      },
      {
        name        = "Demo_Smp_poc_SfgSummaryMonthlyData"
        filter      = "SubId='Demo_Smp_poc_SfgSummaryMonthlyData'"
        filter_type = "SqlFilter"
      },
      {
        name        = "Demo_Smp_poc_SfgSummaryShiftData"
        filter      = "SubId='Demo_Smp_poc_SfgSummaryShiftData'"
        filter_type = "SqlFilter"
      },
      {
        name        = "Demo_Smp_poc_SfgSummaryWeekData"
        filter      = "SubId='Demo_Smp_poc_SfgSummaryWeekData'"
        filter_type = "SqlFilter"
      },
      {
        name        = "Demo_Smp_poc_SMR"
        filter      = "SubId='Demo_Smp_poc_SMR'"
        filter_type = "SqlFilter"
      },
      {
        name        = "Demo_Smp_poc_SummaryDayData"
        filter      = "SubId='Demo_Smp_poc_SummaryDayData'"
        filter_type = "SqlFilter"
      },
      {
        name        = "Demo_Smp_poc_SummaryMonthlyData"
        filter      = "SubId='Demo_Smp_poc_SummaryMonthlyData'"
        filter_type = "SqlFilter"
      },
      {
        name        = "Demo_Smp_poc_SummaryShiftData"
        filter      = "SubId='Demo_Smp_poc_SummaryShiftData'"
        filter_type = "SqlFilter"
      },
      {
        name        = "Demo_Smp_poc_SummaryWeekData"
        filter      = "SubId='Demo_Smp_poc_SummaryWeekData'"
        filter_type = "SqlFilter"
      },
      {
        name        = "Demo_Smp_poc_ZBR"
        filter      = "SubId='Demo_Smp_poc_ZBR'"
        filter_type = "SqlFilter"
      },
      {
        name        = "Demo_Smp_poc_ZMR"
        filter      = "SubId='Demo_Smp_poc_ZMR'"
        filter_type = "SqlFilter"
      },
      {
        name        = "Demo_Smp_poc_ZoneDataWithSummary"
        filter      = "SubId='Demo_Smp_poc_ZoneDataWithSummary'"
        filter_type = "SqlFilter"
      },
      {
        name        = "Demo_Smp_poc_ZoneDataWithSummary_st"
      },
      {
        name        = "Demo_Smp_poc_ZoneDayData"
        filter      = "SubId='Demo_Smp_poc_ZoneDayData'"
        filter_type = "SqlFilter"
      },
      {
        name        = "Demo_Smp_poc_ZoneMonthlyData"
        filter      = "SubId='Demo_Smp_poc_ZoneMonthlyData'"
        filter_type = "SqlFilter"
      },
      {
        name        = "Demo_Smp_poc_ZoneShiftData"
        filter      = "SubId='Demo_Smp_poc_ZoneShiftData'"
        filter_type = "SqlFilter"
      },
      {
        name        = "Demo_Smp_poc_ZoneWeekData"
        filter      = "SubId='Demo_Smp_poc_ZoneWeekData'"
        filter_type = "SqlFilter"
      },
      {
        name        = "Demo-Smp-automation-jobs"
        filter      = "SubId='Demo-Smp-automation-jobs'"
        filter_type = "SqlFilter"
      }
    ]
  }
}

pubsubs-hrw = {
  "Demo-hrw-poc-bts-pubsub" = {
    topic       = "Demo_poc_dsummarizer"
    consumer_id = "Demo_poc_BarcodeTracking"
  }

  "Demo-hrw-poc-ds-rawdata-pubsub" = {
    topic       = "Demo_poc_dsummarizer"
    consumer_id = "Demo_poc_RawData"
  }

  "Demo-hrw-poc-ega-zonewise-pubsub" = {
    topic       = "Demo_poc_dsummarizer"
    consumer_id = "Demo_poc_EGA_SummarizerToZone"
  }

  "Demo-hrw-poc-materialwise-pubsub" = {
    topic       = "Demo_poc_zone_and_material_calculation"
    consumer_id = "Demo_poc_ZoneDataWithSummary"
  }

  "Demo-hrw-poc-zonewise-alert-pubsub" = {
    topic       = "Demo_poc_batchalert"
    consumer_id = "Demo_poc_Alert_BatchData"
  }

  "Demo-hrw-poc-zonewise-pubsub" = {
    topic       = "Demo_poc_dsummarizer"
    consumer_id = "Demo_poc_SummarizerToZone"
  }
}