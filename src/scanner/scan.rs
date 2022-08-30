use crate::rpc::client::create_client;
use crate::rpc::client::monitor_page_complete;
use crate::rpc::client::monitor_page_start;

use crate::packages::spider::website::Website;
use crate::rpc::client::website::ScanInitParams;
use ua_generator::ua::spoof_ua;

/// crawl all pages and send request as links are found. TODO: move to stream instead of callback uses gRPC callback in spider.
pub async fn scan(
    domain: String,
    user_id: u32,
    respect_robots_txt: bool,
    agent: String,
    subdomains: bool,
    tld: bool,
) -> Result<(), core::fmt::Error> {
    let mut client = create_client().await.unwrap();
    let mut website: Website = Website::new(&domain);

    website.configuration.respect_robots_txt = respect_robots_txt;
    website.configuration.delay = 0;
    website.configuration.subdomains = subdomains;
    website.configuration.tld = tld;
    website.configuration.user_agent = if !agent.is_empty() { &agent } else { spoof_ua() }.into();

    // send scan start tracking user for following request
    monitor_page_start(
        &mut client,
        ScanInitParams {
            domain: domain.into(),
            user_id,
        },
    )
    .await
    .unwrap_or_else(|e| println!("{} - crawl start failed.", e));

    website.crawl_grpc(&mut client, user_id).await;

    // send scan complete
    monitor_page_complete(
        &mut client,
        ScanInitParams {
            domain: website.domain,
            user_id,
        },
    )
    .await
    .unwrap_or_else(|e| println!("{} - crawl completed failed.", e));

    Ok(())
}
