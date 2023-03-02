  -- Sessions TABLE
CREATE TABLE
  projeto_google_analytics.sessions AS(
  SELECT
    DISTINCT CONCAT(fullVisitorId, CAST(visitId AS STRING)) AS session_id,
    TIMESTAMP_SECONDS(visitStartTime) AS visit_start_time,
    fullVisitorId AS visitor_id,
    IFNULL(totals.newVisits,0) AS is_new_visit,
    IFNULL(totals.bounces, 0) AS bounce,
    trafficSource.source AS utm_source,
    trafficSource.campaign AS utm_campaign,
    trafficSource.adContent AS utm_content,
    trafficSource.medium AS utm_medium,
    device.deviceCategory AS device_type,
    trafficSource.referralPath AS referral_path
  FROM
    `bigquery-public-data.google_analytics_sample.ga_sessions_*`,
    UNNEST (hits) AS hits
  WHERE
    _TABLE_SUFFIX BETWEEN '20160801'
    AND '20170801'); 
    

--Pageviews TABLE
CREATE TABLE
  projeto_google_analytics.pageviews AS(
  SELECT
    ROW_NUMBER() OVER() AS pageview_id,
    TIMESTAMP_TRUNC(TIMESTAMP_ADD(TIMESTAMP_SECONDS(visitStartTime), INTERVAL hits.time MILLISECOND),SECOND)AS page_timestamp,
    CONCAT(fullVisitorId, CAST(visitId AS STRING)) AS session_id,
    hits.page.pagePath AS page_url,
    CASE hits.eCommerceAction.action_type
      WHEN '0' THEN 'visit'
      WHEN '1' THEN 'product_list'
      WHEN '2' THEN 'product_detail'
      WHEN '3' THEN 'add_to_cart'
      WHEN '4' THEN 'remove_from_cart'
      WHEN '5' THEN 'checkout'
      WHEN '6' THEN 'order_complete'
      WHEN '7' THEN 'refund'
      WHEN '8' THEN 'checkout_options'
  END
    AS action_desc,
    IFNULL(totals.bounces, 0) AS bounce
  FROM
    `bigquery-public-data.google_analytics_sample.ga_sessions_*`,
    UNNEST (hits) AS hits
  WHERE
    _TABLE_SUFFIX BETWEEN '20160801'
    AND '20170801');
