{
  "version": "Notebook/1.0",
  "fallbackResourceIds": [
    "${law_id}"
  ],
  "items": [
    {
      "type": 1,
      "content": {
        "json": "# MOT Platform Observability\nAzure-native SRE dashboard for Front Door, Frontend, APIM and Container Apps"
      }
    },
    {
      "type": 1,
      "content": {
        "json": "## Executive Overview"
      }
    },
    {
      "type": 3,
      "content": {
        "version": "KqlItem/1.0",
        "query": "AzureDiagnostics | where Category == \"FrontDoorAccessLog\" | summarize Requests=count()",
        "size": 0,
        "title": "Front Door Requests",
        "queryType": 0,
        "resourceType": "microsoft.operationalinsights/workspaces",
        "crossComponentResources": [
          "${law_id}"
        ],
        "visualization": "stat"
      },
      "gridSettings": {
        "x": 0,
        "y": 2,
        "w": 3,
        "h": 2
      }
    },
    {
      "type": 3,
      "content": {
        "version": "KqlItem/1.0",
        "query": "AzureDiagnostics | where Category == \"GatewayLogs\" | summarize Requests=count()",
        "size": 0,
        "title": "APIM Requests",
        "queryType": 0,
        "resourceType": "microsoft.operationalinsights/workspaces",
        "crossComponentResources": [
          "${law_id}"
        ],
        "visualization": "stat"
      },
      "gridSettings": {
        "x": 3,
        "y": 2,
        "w": 3,
        "h": 2
      }
    },
    {
      "type": 3,
      "content": {
        "version": "KqlItem/1.0",
        "query": "AppServiceHTTPLogs | summarize Requests=count()",
        "size": 0,
        "title": "Frontend Requests",
        "queryType": 0,
        "resourceType": "microsoft.operationalinsights/workspaces",
        "crossComponentResources": [
          "${law_id}"
        ],
        "visualization": "stat"
      },
      "gridSettings": {
        "x": 6,
        "y": 2,
        "w": 3,
        "h": 2
      }
    },
    {
      "type": 3,
      "content": {
        "version": "KqlItem/1.0",
        "query": "ContainerAppSystemLogs_CL | summarize Events=count()",
        "size": 0,
        "title": "Container Events",
        "queryType": 0,
        "resourceType": "microsoft.operationalinsights/workspaces",
        "crossComponentResources": [
          "${law_id}"
        ],
        "visualization": "stat"
      },
      "gridSettings": {
        "x": 9,
        "y": 2,
        "w": 3,
        "h": 2
      }
    },
    {
      "type": 1,
      "content": {
        "json": "## Traffic Trends"
      }
    },
    {
      "type": 3,
      "content": {
        "version": "KqlItem/1.0",
        "query": "AzureDiagnostics | where Category == \"FrontDoorAccessLog\" | summarize Requests=count() by bin(TimeGenerated, 5m)",
        "size": 0,
        "title": "Front Door Traffic",
        "queryType": 0,
        "resourceType": "microsoft.operationalinsights/workspaces",
        "crossComponentResources": [
          "${law_id}"
        ],
        "visualization": "timechart"
      },
      "gridSettings": {
        "x": 0,
        "y": 5,
        "w": 6,
        "h": 4
      }
    },
    {
      "type": 3,
      "content": {
        "version": "KqlItem/1.0",
        "query": "AzureDiagnostics | where Category == \"GatewayLogs\" | summarize Requests=count() by bin(TimeGenerated, 5m)",
        "size": 0,
        "title": "APIM Traffic",
        "queryType": 0,
        "resourceType": "microsoft.operationalinsights/workspaces",
        "crossComponentResources": [
          "${law_id}"
        ],
        "visualization": "timechart"
      },
      "gridSettings": {
        "x": 6,
        "y": 5,
        "w": 6,
        "h": 4
      }
    },
    {
      "type": 3,
      "content": {
        "version": "KqlItem/1.0",
        "query": "AppServiceHTTPLogs | summarize Requests=count() by bin(TimeGenerated, 5m)",
        "size": 0,
        "title": "Frontend Traffic",
        "queryType": 0,
        "resourceType": "microsoft.operationalinsights/workspaces",
        "crossComponentResources": [
          "${law_id}"
        ],
        "visualization": "timechart"
      },
      "gridSettings": {
        "x": 0,
        "y": 10,
        "w": 6,
        "h": 4
      }
    },
    {
      "type": 3,
      "content": {
        "version": "KqlItem/1.0",
        "query": "ContainerAppSystemLogs_CL | summarize Events=count() by bin(TimeGenerated, 5m)",
        "size": 0,
        "title": "Container Events Trend",
        "queryType": 0,
        "resourceType": "microsoft.operationalinsights/workspaces",
        "crossComponentResources": [
          "${law_id}"
        ],
        "visualization": "timechart"
      },
      "gridSettings": {
        "x": 6,
        "y": 10,
        "w": 6,
        "h": 4
      }
    },
    {
      "type": 1,
      "content": {
        "json": "## Platform Health"
      }
    },
    {
      "type": 3,
      "content": {
        "version": "KqlItem/1.0",
        "query": "AzureDiagnostics | where Category == \"FrontDoorHealthProbeLog\" | summarize Probes=count() by bin(TimeGenerated, 5m)",
        "size": 0,
        "title": "Front Door Health Probes",
        "queryType": 0,
        "resourceType": "microsoft.operationalinsights/workspaces",
        "crossComponentResources": [
          "${law_id}"
        ],
        "visualization": "timechart"
      },
      "gridSettings": {
        "x": 0,
        "y": 15,
        "w": 6,
        "h": 4
      }
    },
    {
      "type": 3,
      "content": {
        "version": "KqlItem/1.0",
        "query": "AzureDiagnostics | where Category == \"GatewayLogs\" | summarize GatewayEvents=count() by bin(TimeGenerated, 5m)",
        "size": 0,
        "title": "APIM Gateway Activity",
        "queryType": 0,
        "resourceType": "microsoft.operationalinsights/workspaces",
        "crossComponentResources": [
          "${law_id}"
        ],
        "visualization": "timechart"
      },
      "gridSettings": {
        "x": 6,
        "y": 15,
        "w": 6,
        "h": 4
      }
    },
    {
      "type": 3,
      "content": {
        "version": "KqlItem/1.0",
        "query": "AppServiceHTTPLogs | summarize Requests=count() by scStatus",
        "size": 0,
        "title": "Frontend HTTP Status Overview",
        "queryType": 0,
        "resourceType": "microsoft.operationalinsights/workspaces",
        "crossComponentResources": [
          "${law_id}"
        ],
        "visualization": "barchart"
      },
      "gridSettings": {
        "x": 0,
        "y": 20,
        "w": 6,
        "h": 4
      }
    },
    {
      "type": 3,
      "content": {
        "version": "KqlItem/1.0",
        "query": "ContainerAppConsoleLogs_CL | summarize Logs=count() by ContainerAppName_s",
        "size": 0,
        "title": "Container Logs by App",
        "queryType": 0,
        "resourceType": "microsoft.operationalinsights/workspaces",
        "crossComponentResources": [
          "${law_id}"
        ],
        "visualization": "barchart"
      },
      "gridSettings": {
        "x": 6,
        "y": 20,
        "w": 6,
        "h": 4
      }
    },
    {
      "type": 1,
      "content": {
        "json": "## Troubleshooting"
      }
    },
    {
      "type": 3,
      "content": {
        "version": "KqlItem/1.0",
        "query": "AzureDiagnostics | where Category == \"FrontDoorAccessLog\" | order by TimeGenerated desc | take 20",
        "size": 0,
        "title": "Latest Front Door Logs",
        "queryType": 0,
        "resourceType": "microsoft.operationalinsights/workspaces",
        "crossComponentResources": [
          "${law_id}"
        ],
        "visualization": "table"
      },
      "gridSettings": {
        "x": 0,
        "y": 25,
        "w": 6,
        "h": 5
      }
    },
    {
      "type": 3,
      "content": {
        "version": "KqlItem/1.0",
        "query": "AzureDiagnostics | where Category == \"GatewayLogs\" | order by TimeGenerated desc | take 20",
        "size": 0,
        "title": "Latest APIM Logs",
        "queryType": 0,
        "resourceType": "microsoft.operationalinsights/workspaces",
        "crossComponentResources": [
          "${law_id}"
        ],
        "visualization": "table"
      },
      "gridSettings": {
        "x": 6,
        "y": 25,
        "w": 6,
        "h": 5
      }
    },
    {
      "type": 3,
      "content": {
        "version": "KqlItem/1.0",
        "query": "AppServiceHTTPLogs | order by TimeGenerated desc | take 20",
        "size": 0,
        "title": "Latest Frontend HTTP Logs",
        "queryType": 0,
        "resourceType": "microsoft.operationalinsights/workspaces",
        "crossComponentResources": [
          "${law_id}"
        ],
        "visualization": "table"
      },
      "gridSettings": {
        "x": 0,
        "y": 31,
        "w": 6,
        "h": 5
      }
    },
    {
      "type": 3,
      "content": {
        "version": "KqlItem/1.0",
        "query": "ContainerAppConsoleLogs_CL | order by TimeGenerated desc | take 20",
        "size": 0,
        "title": "Latest Container Console Logs",
        "queryType": 0,
        "resourceType": "microsoft.operationalinsights/workspaces",
        "crossComponentResources": [
          "${law_id}"
        ],
        "visualization": "table"
      },
      "gridSettings": {
        "x": 6,
        "y": 31,
        "w": 6,
        "h": 5
      }
    }
  ]
}