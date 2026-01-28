use serde::{Deserialize, Serialize};
use std::error::Error;

#[derive(Debug, Serialize, Deserialize)]
struct SearchResponse {
    items: Vec<Repository>,
    total_count: u64,
}

#[derive(Debug, Serialize, Deserialize)]
struct Repository {
    name: String,
    full_name: String,
    html_url: String,
    description: Option<String>,
    stargazers_count: u64,
    language: Option<String>,
}

#[tokio::main]
async fn main() -> Result<(), Box<dyn Error>> {
    let queries = vec![
        "github search language:rust",
        "github index language:rust",
        "github crawler language:rust",
        "github scraper language:rust",
        "git search language:rust",
        "git index language:rust",
        "git crawler language:rust",
        "repository indexer language:rust",
    ];

    for query in queries {
        println!("\n=== Searching: {} ===", query);
        search_repos(query).await?;
    }

    Ok(())
}

async fn search_repos(query: &str) -> Result<(), Box<dyn Error>> {
    let url = format!(
        "https://api.github.com/search/repositories?q={}&sort=stars&order=desc&per_page=10",
        urlencoding::encode(query)
    );

    let client = reqwest::Client::new();
    let response = client
        .get(&url)
        .header("User-Agent", "rust-github-finder")
        .send()
        .await?;

    let search_result: SearchResponse = response.json().await?;

    println!("Found {} repositories\n", search_result.total_count);

    for repo in search_result.items {
        println!("📦 {}", repo.full_name);
        println!("   ⭐ {} stars", repo.stargazers_count);
        if let Some(desc) = repo.description {
            println!("   📝 {}", desc);
        }
        if let Some(lang) = repo.language {
            println!("   💻 {}", lang);
        }
        println!("   🔗 {}", repo.html_url);
        println!();
    }

    Ok(())
}
