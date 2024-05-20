## iam: 

### Role: osi-pipeline-role 

```
Policy:
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": [
                "es:DescribeDomain",
                "es:ESHttp*"
            ],
            "Resource": [
                "arn:aws:es:us-east-1:654654242714:domain/observability-aos"
            ],
            "Effect": "Allow"
        }
    ]
}

```


## osi-pipeline-otellogs

### Configuration:

```
version: "2"
otel-logs-pipeline:
  source:
    otel_logs_source:
      path: "/v1/logs"
  processor:
    - parse_json:
        source: "body"                  
    - parse_json:
        source: "kubernetes"                  
    - parse_json:
        source: "annotations"                  
    - parse_json:
        source: "labels"              
    - delete_entries:
        with_keys: ["body", "kubernetes", "annotations","labels"]
    - date:
        from_time_received: true
        destination: "@timestamp"           
  sink:
    - opensearch:                  
        index: "sample_app_logs"
        hosts: ["https://search-opentelemetry-3stz66dj5ne6fgs2vxe34kqtoy.us-east-1.es.amazonaws.com"]
        aws:                  
          sts_role_arn: "arn:aws:iam::975049940976:role/osi-pipeline-role"
          region: "us-east-1"

```


## osi-pipeline-otelmetrics

### Configuration:

```
version: "2"
otel-metrics-pipeline:
  source:
    otel_metrics_source:
      path: "/v1/metrics"
  processor:
    - otel_metrics:
  sink:
    - opensearch:
        index: "sample_app_metrics"
        hosts: ["https://search-opentelemetry-3stz66dj5ne6fgs2vxe34kqtoy.us-east-1.es.amazonaws.com"]
        aws:                  
          sts_role_arn: "arn:aws:iam::975049940976:role/osi-pipeline-role"
          region: "us-east-1"

```



## osi-pipeline-oteltraces

### Configuration:

```
version: "2"
entry-pipeline:
  source:
    otel_trace_source:
      path: "/v1/traces"
  processor:
    - trace_peer_forwarder:
  sink:
    - pipeline:
        name: "span-pipeline"
    - pipeline:
        name: "service-map-pipeline"
span-pipeline:
  source:
    pipeline:
      name: "entry-pipeline"
  processor:
    - otel_traces:
  sink:
    - opensearch:
        index_type: "trace-analytics-raw"
        hosts: ["https://search-opentelemetry-3stz66dj5ne6fgs2vxe34kqtoy.us-east-1.es.amazonaws.com"]
        aws:                  
          sts_role_arn: "arn:aws:iam::975049940976:role/osi-pipeline-role"
          region: "us-east-1"
service-map-pipeline:
  source:
    pipeline:
      name: "entry-pipeline"
  processor:
    - service_map:
  sink:
    - opensearch:
        index_type: "trace-analytics-service-map"
        hosts: ["https://search-opentelemetry-3stz66dj5ne6fgs2vxe34kqtoy.us-east-1.es.amazonaws.com"]
        aws:                  
          sts_role_arn: "arn:aws:iam::975049940976:role/osi-pipeline-role"
          region: "us-east-1"
```

